#!/usr/bin/env python3
"""
PreToolUse guard for Claude Code Bash calls.

Install example:
  mkdir -p ~/.claude/hooks
  cp claude-server-guardrails/hooks/pretooluse-guard.py ~/.claude/hooks/
  chmod 700 ~/.claude/hooks/pretooluse-guard.py

The script reads Claude Code hook JSON from stdin. It exits 2 to block a Bash
command that matches clearly dangerous patterns. Keep this list focused on hard
blocks; use settings.json permissions.ask for operations that may be valid after
human confirmation.
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: re.Pattern[str]


def compile_rule(name: str, pattern: str) -> Rule:
    return Rule(name=name, pattern=re.compile(pattern, re.IGNORECASE | re.DOTALL | re.VERBOSE))


SENSITIVE_PATH_PATTERN = r"""
(?:
    (?:^|[\s"'=:@<])
    (?:[^\s"'`;|&<>]*/)?\.env(?!\.example\b)(?:\.[^\s"'`;|&<>]+)?
    (?=$|[\s"'`;|&<>])
  |
    (?:^|[\s"'=:@<])
    (?:[^\s"'`;|&<>]+/)?[^\s"'`;|&<>]+\.(?:pem|key|p12|pfx|jks|keystore)
    (?=$|[\s"'`;|&<>])
  |
    (?:^|[\s"'=:@<])
    (?:[^\s"'`;|&<>]+/)?(?:terraform\.tfstate|\.htpasswd|wp-config\.php)
    (?=$|[\s"'`;|&<>])
  |
    (?:^|[\s"'=:@<])
    (?:~|/root|/home/[^\s"'`;|&<>/]+)/(?:\.ssh|\.aws|\.config/gcloud|\.azure|\.kube|\.gnupg|\.docker/config\.json)
    (?:/|(?=$|[\s"'`;|&<>]))
  |
    (?:^|[\s"'=:@<])
    (?:[^\s"'`;|&<>]+/)?(?:secrets|credentials|backups)
    (?:/|(?=$|[\s"'`;|&<>]))
)
"""


HARD_BLOCK_RULES = [
    compile_rule("fork bomb", r":\s*\(\s*\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:"),
    compile_rule("recursive delete of filesystem root", r"\brm\s+-(?:[^\s]*r[^\s]*f|[^\s]*f[^\s]*r)[^\n;]*\s/(?:\s|$|\*)"),
    compile_rule("find delete", r"\bfind\b[^\n;]*\s-delete\b"),
    compile_rule("find exec rm", r"\bfind\b[^\n;]*(?:-exec|-execdir)\s+(?:sudo\s+)?rm\b"),
    compile_rule("xargs rm", r"\bxargs\b[^\n;]*\brm\b"),
    compile_rule("rsync delete", r"\brsync\b[^\n;]*\s--delete\b"),
    compile_rule("tar remove files", r"\btar\b[^\n;]*\s--remove-files\b"),
    compile_rule("disk format", r"\bmkfs(?:\.[a-z0-9]+)?\b"),
    compile_rule("raw disk write", r"\bdd\b[^\n;]*(?:\bof=/dev/|>\s*/dev/(?:sd|vd|xvd|nvme))"),
    compile_rule("shred", r"\bshred\b"),
    compile_rule("power action", r"\b(?:shutdown|reboot|halt|poweroff)\b"),
    compile_rule("firewall flush", r"\b(?:iptables\s+-F|nft\s+flush\s+ruleset|ufw\s+reset)\b"),
    compile_rule("global kill", r"\bkill\s+-9\s+-1\b"),
    compile_rule("force push", r"\bgit\s+push\b[^\n;]*(?:\s-f\b|\s--force\b)"),
    compile_rule("hard git reset", r"\bgit\s+reset\s+--hard\b"),
    compile_rule("destructive git clean", r"\bgit\s+clean\b[^\n;]*-(?:[^\s]*f[^\s]*d|[^\s]*d[^\s]*f)[^\s]*x"),
    compile_rule("docker system prune", r"\bdocker\s+system\s+prune\b"),
    compile_rule("docker volume removal", r"\bdocker\s+volume\s+(?:rm|prune)\b"),
    compile_rule("compose down with volumes", r"\bdocker\s+compose\s+down\b[^\n;]*\s-v\b"),
    compile_rule("kubernetes delete", r"\bkubectl\s+delete\b"),
    compile_rule("helm uninstall", r"\bhelm\s+uninstall\b"),
    compile_rule("terraform destroy", r"\bterraform\s+destroy\b"),
    compile_rule("curl pipe interpreter", r"\bcurl\b[^\n;|]*\|\s*(?:sudo\s+)?(?:sh|bash|python3?|node|ruby|perl)\b"),
    compile_rule("wget pipe interpreter", r"\bwget\b[^\n;|]*\|\s*(?:sudo\s+)?(?:sh|bash|python3?|node|ruby|perl)\b"),
    compile_rule("decode pipe shell", r"\b(?:base64|openssl\s+\w+|gunzip|gzip\s+-d|zcat|xzcat)\b[^\n;|]*\|\s*(?:sudo\s+)?(?:sh|bash)\b"),
    compile_rule("bash process substitution curl", r"\bbash\s+<\s*\(\s*curl\b"),
    compile_rule("bash process substitution wget", r"\bbash\s+<\s*\(\s*wget\b"),
    compile_rule("shell eval remote code", r"\b(?:eval|sh\s+-c|bash\s+-c)\b[^\n;]*(?:curl|wget)\b"),
    compile_rule("secret file read via shell", rf"\b(?:cat|less|more|head|tail|grep|egrep|fgrep|rg|awk|sed|strings|xxd|base64)\b[^\n;|&]*{SENSITIVE_PATH_PATTERN}"),
    compile_rule("secret upload via curl or wget", rf"\b(?:curl|wget)\b[^\n;]*(?:(?:--data(?:-raw|-binary)?|-d|--form|-F|--upload-file|-T)(?:=|\s+)|--post-file=)@?[^\n;|&]*{SENSITIVE_PATH_PATTERN}"),
    compile_rule("secret transfer via shell", rf"\b(?:scp|sftp|rsync)\b[^\n;|&]*{SENSITIVE_PATH_PATTERN}"),
    compile_rule("secret sent via shell redirection", rf"\b(?:nc|netcat|socat|openssl\s+s_client)\b[^\n;|&]*<\s*{SENSITIVE_PATH_PATTERN}"),
    compile_rule("drop database/schema/table", r"\bDROP\s+(?:DATABASE|SCHEMA|TABLE)\b"),
    compile_rule("truncate table", r"\bTRUNCATE\b"),
    compile_rule("redis flush", r"\bFLUSH(?:ALL|DB)\b"),
]


def command_from_hook(payload: dict) -> str:
    if payload.get("tool_name") != "Bash":
        return ""
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return ""
    command = tool_input.get("command")
    return command if isinstance(command, str) else ""


def block_reason(command: str) -> str | None:
    for rule in HARD_BLOCK_RULES:
        if rule.pattern.search(command):
            return rule.name

    for statement in re.split(r";", command):
        statement = statement.strip()
        if not statement:
            continue
        if re.search(r"\bDELETE\s+FROM\b", statement, re.IGNORECASE) and not re.search(r"\bWHERE\b", statement, re.IGNORECASE):
            return "DELETE without WHERE"
        if re.search(r"\bUPDATE\s+\S+\s+SET\b", statement, re.IGNORECASE) and not re.search(r"\bWHERE\b", statement, re.IGNORECASE):
            return "UPDATE without WHERE"

    return None


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("Claude server guardrail warning: invalid hook JSON; allowing command.", file=sys.stderr)
        return 0

    command = command_from_hook(payload)
    if not command:
        return 0

    reason = block_reason(command)
    if reason is None:
        return 0

    print(f"BLOCKED by Claude server guardrail: {reason}", file=sys.stderr)
    print("If this action is truly required, revise the guardrail policy deliberately before retrying.", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
