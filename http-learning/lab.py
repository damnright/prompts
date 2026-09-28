#!/usr/bin/env python3
"""仅监听回环地址的 HTTP 教具；固定响应，不访问文件或数据库。"""
import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import time
from urllib.parse import urlsplit


class Handler(BaseHTTPRequestHandler):
    def setup(self):
        super().setup()
        self.connection.settimeout(5)

    def send_json(self, status, body, headers=None):
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        for key, value in (headers or {}).items():
            self.send_header(key, value)
        self.end_headers()
        try:
            self.wfile.write(data)
        except (BrokenPipeError, ConnectionResetError):
            # H4 故意让客户端先结束等待。
            pass

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/words":
            self.send_json(200, {"items": [
                {"id": 1, "term": "speak", "level": "A2", "example": None},
                {"id": 2, "term": "review", "level": "A2", "example": "Review a word."},
            ], "next_after_id": None})
        elif path == "/slow":
            time.sleep(2)
            self.send_json(200, {"message": "等待完成；本实验没有写入数据"})
        elif path.startswith("/status/") and path[8:] in {
            "400", "401", "403", "404", "409", "413", "415", "429", "500", "503"
        }:
            status = int(path[8:])
            headers = {}
            if status == 401:
                headers["WWW-Authenticate"] = 'Bearer realm="http-learning"'
            if status in {429, 503}:
                headers["Retry-After"] = "2"
            self.send_json(status, {"error": {"code": f"demo_{status}",
                                             "message": "教学用固定响应"}}, headers)
        else:
            self.send_json(404, {"error": {"code": "not_found"}})

    def do_POST(self):
        if urlsplit(self.path).path != "/echo":
            self.send_json(404, {"error": {"code": "not_found"}})
            return
        if self.headers.get_content_type() != "application/json":
            self.send_json(415, {"error": {"code": "json_required"}})
            return
        # 教具只接受固定长度的小 JSON，不实现流式或分块上传。
        if self.headers.get("Transfer-Encoding"):
            self.send_json(400, {"error": {"code": "fixed_length_required"}})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_json(400, {"error": {"code": "invalid_length"}})
            return
        if not 0 < length <= 4096:
            self.send_json(413 if length > 4096 else 400,
                           {"error": {"code": "invalid_body_size"}})
            return
        try:
            body = json.loads(self.rfile.read(length))
            if not isinstance(body, dict):
                raise ValueError("expected object")
        except (ValueError, UnicodeError):
            self.send_json(400, {"error": {"code": "invalid_json_object"}})
            return
        self.send_json(200, {"received": body})

    def log_message(self, format, *args):
        # 不回显请求正文、Header 或任意用户输入。
        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8083)
    args = parser.parse_args()
    with ThreadingHTTPServer(("127.0.0.1", args.port), Handler) as server:
        print(f"HTTP 教具：http://127.0.0.1:{server.server_port}", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
