#!/usr/bin/env python3
"""复用 OrbStack / 容器内 psql 的 SQL 练习入口，只使用 Python 标准库。"""
import csv
import errno
import io
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import socket
import subprocess
import sys
import time
from decimal import Decimal, InvalidOperation

ROOT = Path(__file__).resolve().parent
PROJECT = "prompts-sql-learning"
NULL = "__SQL_LAB_NULL__"


def docker(*args, input=None):
    executable = shutil.which("docker")
    bundled = Path.home() / ".orbstack/bin/docker"
    if not executable and bundled.is_file():
        executable = str(bundled)
    if not executable:
        raise RuntimeError("未找到 OrbStack 的 Docker 命令。请先打开已安装的 OrbStack，完成首次初始化后重试。")
    result = subprocess.run(
        [executable, "--context", "orbstack", *args], input=input,
        text=True, capture_output=True, cwd=ROOT,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result.stdout


def compose(*args, input=None):
    if not (ROOT / ".env").is_file():
        raise RuntimeError("请先运行 python3 lab.py up，生成本地配置并启动练习数据库。")
    return docker("compose", "--project-name", PROJECT, "--file", str(ROOT / "compose.yaml"),
                  "--env-file", str(ROOT / ".env"), *args, input=input)


def psql(sql, csv_output=False):
    args = ["exec", "-T", "postgres", "psql", "-X", "-U", "sql_learner", "-d", "sql_learning",
            "-v", "ON_ERROR_STOP=1", "-P", "pager=off"]
    if csv_output:
        args += ["--quiet", "--csv", "-P", "footer=off", "-P", f"null={NULL}"]
    return compose(*args, input=sql)


def read(path):
    return (ROOT / path).read_text()


def practice_sql(sql):
    # 临时表优先解析，所有练习和检查均不依赖 TablePlus 中的练习进度。
    schema = read("schema.sql").replace("CREATE TABLE ", "CREATE TEMP TABLE ")
    return "BEGIN;\nSET LOCAL TIME ZONE 'UTC';\nSET LOCAL search_path TO pg_temp;\n" + schema + "\n" + read("seed.sql") + "\n" + sql + "\nROLLBACK;\n"


def blocks(sql):
    markers = list(re.finditer(r"^-- (Q\d{2})\b[^\n]*", sql, re.M))
    return [(marker[1], sql[marker.end():markers[i + 1].start() if i + 1 < len(markers) else len(sql)])
            for i, marker in enumerate(markers)]


def comparable(value):
    if value is None or value == NULL:
        return None
    try:
        return Decimal(str(value))
    except InvalidOperation:
        return str(value)


def check(path):
    exercises = blocks(read(path))
    if not exercises or not 1 <= int(exercises[0][0][1:]) <= 24:
        raise RuntimeError("检查文件必须保留某一天的完整 8 个 Q 编号。")
    start = (int(exercises[0][0][1:]) - 1) // 8 * 8 + 1
    ids = [f"Q{i:02}" for i in range(start, start + 8)]
    if [question for question, _ in exercises] != ids:
        raise RuntimeError("请保留当天全部 8 个 Q 编号，且不要重复或调整顺序。")
    empty = [question for question, sql in exercises if not re.sub(r"--[^\n]*", "", sql).strip()]
    if empty:
        raise RuntimeError("未作答：" + "、".join(empty) + "。请先填写对应 TODO。")
    expected = json.loads(read("expected.json"))
    # 每题一个结果表；psql 的标记分隔各题，CRUD 在同一连接内依次执行。
    script = "\n".join(f"\\echo __SQL_LAB_{question}__\n{sql}" for question, sql in exercises)
    # Q06～Q08 结束后以及所有查询题结束后，种子数据应与开始时完全一致。
    tables = ["users", "words", "learning_sessions", "word_reviews"]
    snapshot = "\n".join(
        f"SELECT '{table}' AS table_name, json_agg(t ORDER BY id)::text AS data FROM {table} t;"
        for table in tables
    )
    script = f"\\echo __SQL_LAB_BEFORE__\n{snapshot}\n{script}\n\\echo __SQL_LAB_AFTER__\n{snapshot}"
    output = psql(practice_sql(script), csv_output=True)
    parts = re.split(r"^__SQL_LAB_(Q\d{2}|BEFORE|AFTER)__\r?$", output, flags=re.M)
    results = dict(zip(parts[1::2], parts[2::2]))
    passed = 0
    for question in ids:
        rows = list(csv.reader(io.StringIO(results.get(question, "").strip())))
        spec = expected[question]
        actual = [[comparable(value) for value in row] for row in rows[1:]]
        wanted = [[comparable(row[col]) for col in spec["columns"]] for row in spec["rows"]]
        if rows and rows[0] == spec["columns"] and actual == wanted:
            passed += 1
            print(f"{question} 通过")
        else:
            print(f"{question} 未通过：检查列名、数据与排序。")
            print("实际：", rows)
            print("预期：", [spec["columns"], *[[row[col] for col in spec["columns"]] for row in spec["rows"]]])
    intact = results.get("BEFORE", "").strip() == results.get("AFTER", "").strip()
    if not intact:
        print("初始数据完整性检查未通过：检查增删改的范围和 Q08 的清理。")
    print(f"{path}：{passed}/8 题通过；初始数据完整性{'通过' if intact else '未通过'}。")
    return passed == 8 and intact


def up():
    # 明确选择 OrbStack，不修改全局 context，也不使用 DOCKER_HOST 指向的其他引擎。
    docker("info", "--format", "{{.ServerVersion}}")
    env_path = ROOT / ".env"
    if not env_path.exists():
        volumes = docker("volume", "ls", "--filter", f"label=com.docker.compose.project={PROJECT}", "--format", "{{.Name}}")
        if volumes.strip():
            raise RuntimeError("已有本练习的数据卷但 .env 缺失。请恢复原 .env，避免生成与已有数据库不一致的密码。")
        # O_EXCL 避免覆盖用户配置；不输出生成的密码。
        fd = os.open(env_path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as file:
            file.write(f"SQL_LEARNING_PORT=55432\nSQL_LEARNING_PASSWORD={secrets.token_hex(24)}\n")
    port_match = re.search(r"^SQL_LEARNING_PORT=(\d+)\s*$", env_path.read_text(), re.M)
    if not port_match:
        raise RuntimeError(".env 中需要 SQL_LEARNING_PORT=端口号。")
    port = int(port_match[1])
    running = compose("ps", "--status", "running", "--quiet", "postgres").strip()
    if not running:
        for attempt in range(11):
            try:
                with socket.socket() as probe:
                    # 排除已关闭连接的 TIME_WAIT，仍会检测正在监听的服务。
                    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    probe.bind(("127.0.0.1", port))
                break
            except OSError as error:
                if error.errno != errno.EADDRINUSE:
                    raise RuntimeError(f"无法检查本机端口 {port}：{error}") from error
                if attempt == 10:
                    raise RuntimeError(f"127.0.0.1:{port} 已占用。请修改本工程 .env 的端口；无需停止已有服务。") from error
                # OrbStack 停止容器后，释放转发端口存在短暂延迟。
                time.sleep(0.1)
    print("正在启动 OrbStack 中的 SQL 练习数据库；首次运行需要下载 PostgreSQL 镜像。", flush=True)
    print(compose("up", "-d", "--wait", "--wait-timeout", "60"), end="")
    print(compose("ps"), end="")
    print(psql(read("hello.sql")), end="")
    with socket.create_connection(("127.0.0.1", port), timeout=3):
        print(f"本机 TCP 连接验证通过：127.0.0.1:{port}。")
    print("TablePlus：数据库 sql_learning，用户 sql_learner；密码查看本工程 .env。")


def main():
    args = sys.argv[1:]
    if args == ["up"]:
        up()
    elif args == ["status"]:
        print(compose("ps"), end="")
    elif args == ["stop"]:
        print(compose("stop"), end="")
    elif args == ["test"]:
        passed = [check(f"solutions/day{day}.sql") for day in (1, 2, 3)]
        if not all(passed):
            return 1
        print("24 道参考答案与初始数据完整性检查全部通过。")
    elif len(args) == 2 and args[0] == "check":
        return 0 if check(args[1]) else 1
    elif args and args[0] == "sql" and len(args) <= 2:
        path = args[1] if len(args) == 2 else "hello.sql"
        print(psql(practice_sql(read(path))), end="")
    else:
        raise RuntimeError("用法：python3 lab.py up | status | stop | sql [文件.sql] | check exercises/day1.sql | test")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError) as error:
        print(f"执行失败：{error}", file=sys.stderr)
        sys.exit(1)
