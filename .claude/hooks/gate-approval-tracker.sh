#!/usr/bin/env bash
# gate-approval-tracker.sh — UserPromptSubmit 훅
# [STOP] 게이트 직후 빠른 승인(rubber-stamp) 감지
#
# Rubber-stamp 정의: 직전 assistant 출력에 [STOP] 또는 게이트 마커가 있고,
# 사용자 응답이 짧고(< 20자) + 도메인 키워드 없이 "승인/좋아/ok/진행/yes"만 있을 때

LOG_DIR="${PWD}/.claude"
GATE_LOG="${LOG_DIR}/gate-approval.log"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$LOG_DIR"

HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi
[ -z "$HOOK_JSON" ] && exit 0

python3 - "$HOOK_JSON" "$GATE_LOG" "$TS" << 'PYEOF' 2>/dev/null
import json, sys, re, os

hook_json, gate_log, ts = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    d = json.loads(hook_json)
except Exception:
    sys.exit(0)

prompt = (d.get('prompt') or d.get('user_message') or '').strip()
transcript_path = d.get('transcript_path') or ''

if not prompt or not transcript_path or not os.path.exists(transcript_path):
    sys.exit(0)

# Extract last assistant text
last_assistant = ''
try:
    with open(transcript_path) as f:
        for line in f:
            try:
                rec = json.loads(line)
            except Exception:
                continue
            if rec.get('type') == 'assistant':
                msg = rec.get('message', {})
                content = msg.get('content', [])
                if isinstance(content, list):
                    for c in content:
                        if isinstance(c, dict) and c.get('type') == 'text':
                            last_assistant = c.get('text', '')
                elif isinstance(content, str):
                    last_assistant = content
except Exception:
    sys.exit(0)

if not last_assistant:
    sys.exit(0)

gate_markers = r'\[STOP\]|Human 승인|\bapproval required\b|\bGate\s*\d|\bCheck\s+\d'
has_gate = bool(re.search(gate_markers, last_assistant, re.IGNORECASE))
if not has_gate:
    sys.exit(0)

# Rubber-stamp heuristic
ap_patterns = [r'^\s*(ok|yes|네|좋아|진행|go|승인|approve)', r'^\s*(gogo|ㄱㄱ|ㅇㅇ)']
is_short = len(prompt) < 20
is_rubber = any(re.match(p, prompt, re.IGNORECASE) for p in ap_patterns)

if not os.path.exists(gate_log):
    with open(gate_log, 'w') as f:
        f.write('timestamp,gate_detected,prompt_length,rubber_stamp,prompt_preview\n')

preview = re.sub(r'[\n\r,]', ' ', prompt[:40])
rubber = '1' if (is_short and is_rubber) else '0'
with open(gate_log, 'a') as f:
    f.write(f'{ts},1,{len(prompt)},{rubber},"{preview}"\n')

if rubber == '1':
    print(f'[OverrideRate] WARN: rubber-stamp approval detected (len={len(prompt)})', file=sys.stderr)
PYEOF

exit 0
