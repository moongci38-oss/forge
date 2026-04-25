#!/usr/bin/env python3
"""
AgentOps 대시보드 — usage.log 기반 AI 행동 분석
forge/.claude/usage.log + override-rate.log 데이터를 집계하여 리포트 생성

사용법:
  python3 agentops-dashboard.py              # 오늘 통계 (텍스트)
  python3 agentops-dashboard.py --days 7     # 최근 7일
  python3 agentops-dashboard.py --export     # forge-outputs에 Markdown 저장
  python3 agentops-dashboard.py --date 2026-04-11  # 특정 날짜
"""

import json
import os
import sys
import argparse
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict, Counter

FORGE_ROOT = Path(os.environ.get("FORGE_ROOT", Path.home() / "forge"))
USAGE_LOG = FORGE_ROOT / ".claude/usage.log"
OVERRIDE_LOG = FORGE_ROOT / ".claude/override-rate.log"
SECURITY_LOG = FORGE_ROOT / ".claude/security.log"
FORGE_OUTPUTS = Path(os.environ.get("FORGE_OUTPUTS", Path.home() / "forge-outputs"))


def load_usage(days=1, target_date=None):
    """usage.log에서 특정 기간 데이터 로드"""
    if not USAGE_LOG.exists():
        return []

    if target_date:
        cutoff = datetime.strptime(target_date, "%Y-%m-%d").date()
        end_date = cutoff + timedelta(days=1)
    else:
        end_date = datetime.utcnow().date() + timedelta(days=1)
        cutoff = end_date - timedelta(days=days)

    records = []
    for line in USAGE_LOG.read_text(errors="ignore").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            r = json.loads(line)
            ts = r.get("ts", "")[:10]  # YYYY-MM-DD
            rec_date = datetime.strptime(ts, "%Y-%m-%d").date() if ts else None
            if rec_date and cutoff <= rec_date < end_date:
                records.append(r)
        except Exception:
            continue
    return records


def load_override_rate():
    """override-rate.log 로드"""
    if not OVERRIDE_LOG.exists():
        return []
    records = []
    lines = OVERRIDE_LOG.read_text(errors="ignore").splitlines()[1:]  # 헤더 제외
    for line in lines:
        parts = line.split(",")
        if len(parts) >= 6:
            records.append({
                "ts": parts[0],
                "session": parts[1],
                "date": parts[2],
                "total_tools": int(parts[3]) if parts[3].isdigit() else 0,
                "learnings_added": int(parts[4]) if parts[4].isdigit() else 0,
                "override_rate_pct": parts[5],
            })
    return records


def load_security_events(days=1):
    """security.log에서 WARN/BLOCK 이벤트 로드"""
    if not SECURITY_LOG.exists():
        return []
    cutoff = datetime.utcnow() - timedelta(days=days)
    events = []
    for line in SECURITY_LOG.read_text(errors="ignore").splitlines():
        parts = line.split(" ", 3)
        if len(parts) >= 4:
            try:
                ts = datetime.strptime(parts[0], "%Y-%m-%dT%H:%M:%SZ")
                if ts >= cutoff:
                    events.append({"ts": parts[0], "level": parts[1], "msg": parts[3]})
            except Exception:
                continue
    return events


def generate_report(days=1, target_date=None):
    """AgentOps 대시보드 리포트 생성"""
    records = load_usage(days=days, target_date=target_date)
    override_records = load_override_rate()
    security_events = load_security_events(days=days)

    if not records:
        return f"데이터 없음 (usage.log 비어있거나 해당 기간 기록 없음)"

    # 도구별 사용 통계
    tool_counts = Counter(r.get("tool", "unknown") for r in records)
    subtype_counts = Counter(r.get("subtype", "tool") for r in records)

    # 이벤트 타입
    event_counts = Counter(r.get("event", "tool_use") for r in records)

    # 일별 사용량
    daily_counts = defaultdict(int)
    for r in records:
        date = r.get("ts", "")[:10]
        if date:
            daily_counts[date] += 1

    # Override rate (최근)
    recent_overrides = override_records[-10:] if override_records else []
    avg_override_rate = 0
    if recent_overrides:
        rates = [float(r["override_rate_pct"]) for r in recent_overrides
                 if r["override_rate_pct"].replace(".", "").isdigit()]
        avg_override_rate = sum(rates) / len(rates) if rates else 0

    # 보안 이벤트 요약
    security_blocks = [e for e in security_events if e["level"] == "BLOCK"]
    security_warns = [e for e in security_events if e["level"] == "WARN"]

    # 리포트 생성
    lines = []
    lines.append(f"# AgentOps 대시보드")
    lines.append(f"**기간**: 최근 {days}일 | **생성**: {datetime.utcnow().strftime('%Y-%m-%d %H:%M')} UTC")
    lines.append(f"**총 Tool 호출**: {len(records):,}회")
    lines.append("")

    # 일별 추이
    lines.append("## 일별 Tool 호출 추이")
    lines.append("| 날짜 | 호출 수 |")
    lines.append("|------|:------:|")
    for date in sorted(daily_counts.keys()):
        count = daily_counts[date]
        bar = "█" * (count // 50) if count >= 50 else "▌"
        lines.append(f"| {date} | {count:,} {bar} |")
    lines.append("")

    # 도구별 사용 TOP 10
    lines.append("## 도구별 사용 TOP 10")
    lines.append("| 도구 | 호출 수 | 비율 |")
    lines.append("|------|:------:|:----:|")
    total = len(records)
    for tool, count in tool_counts.most_common(10):
        pct = count * 100 / total
        lines.append(f"| {tool} | {count:,} | {pct:.1f}% |")
    lines.append("")

    # 서브타입 분포
    lines.append("## 작업 유형 분포")
    lines.append("| 유형 | 호출 수 | 비율 |")
    lines.append("|------|:------:|:----:|")
    for subtype, count in subtype_counts.most_common():
        pct = count * 100 / total
        lines.append(f"| {subtype} | {count:,} | {pct:.1f}% |")
    lines.append("")

    # Override Rate
    lines.append("## Human Override Rate")
    lines.append(f"- 최근 세션 평균 Override Rate: **{avg_override_rate:.1f}%**")
    lines.append(f"- 측정 기준: 세션 내 learnings 추가 수 / 총 Tool 호출 수")
    if recent_overrides:
        lines.append(f"- 최근 세션 수: {len(recent_overrides)}개")
    else:
        lines.append("- 데이터 없음 (override-rate.log 확인 필요)")
    lines.append("")

    # 보안 이벤트
    lines.append("## 보안 이벤트 (최근)")
    lines.append(f"- BLOCK: {len(security_blocks)}건 | WARN: {len(security_warns)}건")
    if security_blocks:
        lines.append("\n**BLOCK 이벤트:**")
        for e in security_blocks[-5:]:
            lines.append(f"- `{e['ts'][:16]}` {e['msg'][:80]}")
    if security_warns:
        lines.append("\n**WARN 이벤트 (최근 5건):**")
        for e in security_warns[-5:]:
            lines.append(f"- `{e['ts'][:16]}` {e['msg'][:80]}")
    lines.append("")

    # 권장 조치
    lines.append("## 권장 조치")
    if avg_override_rate > 10:
        lines.append("- ⚠️ Override Rate가 높음 — AI 결정 품질 개선 필요")
    if len(security_blocks) > 0:
        lines.append("- ⚠️ BLOCK 이벤트 발생 — security.log 확인 필요")
    # 가장 많이 쓰는 도구
    top_tool = tool_counts.most_common(1)[0][0] if tool_counts else None
    if top_tool == "Bash":
        lines.append("- 💡 Bash 호출 비중이 높음 — 전용 도구(Read/Grep/Glob) 활용 권장")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="AgentOps 대시보드")
    parser.add_argument("--days", type=int, default=1, help="분석 기간 (일, 기본 1)")
    parser.add_argument("--date", help="특정 날짜 (YYYY-MM-DD)")
    parser.add_argument("--export", action="store_true", help="forge-outputs에 Markdown 저장")
    args = parser.parse_args()

    report = generate_report(days=args.days, target_date=args.date)
    print(report)

    if args.export:
        date_str = args.date or datetime.utcnow().strftime("%Y-%m-%d")
        out_dir = FORGE_OUTPUTS / "docs/tech"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_file = out_dir / f"{date_str}-agentops-dashboard.md"
        out_file.write_text(report)
        print(f"\n✅ 저장: {out_file}")


if __name__ == "__main__":
    main()
