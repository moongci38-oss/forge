#!/usr/bin/env python3
"""wiki-fix-inter-links — 위키 내부 broken [[wiki-link]] 해결.

수행:
1. Slug 불일치 alias 교체 (micro-saas-solo-founder → micro-saas-solo-founder-2026 등)
2. 중요 누락 노트는 stub 생성 (growth seed)
3. 템플릿 쓰레기([[topic-x]] 등) 제거
"""

from __future__ import annotations
import re
from pathlib import Path

WIKI = Path("/home/damools/forge-outputs/20-wiki")

# slug alias: broken → real
ALIASES = {
    "micro-saas-solo-founder": "micro-saas-solo-founder-2026",
    "saas-pricing-shift": "saas-pricing-shift-2026",
    "mcp-ecosystem": "mcp-ecosystem-2026",
    "karpathy": "andrej-karpathy",
}

# garbage patterns to delete entirely (link removed, plain text kept)
GARBAGE = {"topic-x", "topic-x-subtopic", "..."}

# stub notes to create — (slug, folder, frontmatter type, tag list, title, seed body)
STUBS = [
    (
        "claude",
        "people",
        "person",
        ["anthropic", "ai-lab", "llm"],
        "Anthropic Claude",
        """## 정체성

Anthropic이 개발한 LLM 패밀리. 현재 주력 모델: **Claude 4.6 Opus / Sonnet / Haiku**. [[claude-code]]의 엔진으로, 본 위키 생태계 전체가 Claude 기반 워크플로우 위에 구축됨.

## 주요 특징

- 긴 컨텍스트 (1M 토큰, Opus 4.6)
- 툴 유스(tool use) 기반 에이전트 역량
- Constitutional AI 훈련
- [[mcp]] 프로토콜 퍼스트파티 지원

## 관련 Tools/Concepts

- [[claude-code]] — CLI 인터페이스
- [[claude-skills]] — 스킬 생태계
- [[claude-channels-telegram]] — 비동기 채널 UX

## Growth Notes

- 모델별 비용/성능 비교표 추가 예정
- 버전 히스토리 (4.5 → 4.6) 추가 예정
""",
    ),
    (
        "rag-architecture",
        "concepts",
        "concept",
        ["rag", "retrieval", "vector-db", "lightrag"],
        "RAG Architecture",
        """## 정의

Retrieval-Augmented Generation — LLM에 외부 지식을 주입하는 아키텍처. 본 생태계에서는 [[lightrag]] 기반으로 4개 context(weekly/grants/wiki/archive) 운영.

## Forge 내 구현

- **shared/scripts/lightrag-pilot.py** — 인덱싱/쿼리 단일 진입점
- **shared/lightrag-{weekly|grants|wiki|archive}-data/** — context별 격리
- **indexed.json** — {path: mtime} 스키마로 증분 재인덱싱

## 관련

- [[karpathy-llm-wiki]] — 본 아키텍처의 상위 개념
- [[obsidian]] — vault = wiki context의 원본 저장소
- [[mcp]] — wiki_search MCP로 RAG 결과를 툴로 노출

## Growth Notes

- 청크 크기 / 검색 모드(hybrid/local/global) 비교 분석 필요
- RAGAS 평가 점수 기록 체계 추가 예정
""",
    ),
    (
        "forge-pipeline",
        "tools",
        "tool",
        ["forge", "pipeline", "dev", "planning"],
        "Forge Unified Pipeline",
        """## 정체성

기획 Phase 1~4 + 개발 Phase 6~12 + 정부과제 GR-1~6을 단일 디렉토리에 통합한 파이프라인. 본 위키 생태계의 호스트 시스템.

## 구조

- **planning/** — Phase 1~4 (리서치→컨셉→기획서→기획패키지)
- **dev/** — Phase 6~12 (Spec→구현→검수→배포→모니터링)
- **shared/** — 공통 도구, 스크립트, 규칙, LightRAG 데이터
- **pipeline.md** — Iron Laws + Single Source of Truth

## 관련

- [[claude-code]] — 파이프라인 실행 엔진
- [[claude-skills]] — 각 Phase를 스킬로 캡슐화
- [[harness-engineering]] — 파이프라인 자체가 하네스 구조
- [[godblade]], [[portfolio-project]] — 파이프라인이 관리하는 프로젝트

## Growth Notes

- Phase별 승인 게이트 / Iron Law 목록을 여기 정리 예정
- 사용자 Override Rate 집계 근거 추가 예정
""",
    ),
    (
        "ollama",
        "tools",
        "tool",
        ["llm", "local", "inference"],
        "Ollama",
        """## 정체성

로컬 LLM 실행 런타임. [[gemma-4]] 같은 오픈 모델을 macOS/Linux에서 네이티브로 구동.

## 활용 시나리오

- 오프라인/에어갭 환경에서 로컬 코드 분석
- 민감 데이터를 클라우드 없이 처리
- RAG 실험 시 임베딩 모델 로컬 구동

## 관련

- [[gemma-4]] — 대표 로컬 모델
- [[claude-code]] — 클라우드 주력, 로컬은 보조

## Growth Notes

- 본 워크스페이스에서 실제 사용 빈도·용도 기록 예정
""",
    ),
    (
        "unity",
        "tools",
        "tool",
        ["game-engine", "c-sharp", "godblade"],
        "Unity Engine",
        """## 정체성

게임 엔진. 본 워크스페이스에서 [[godblade]] (모바일 RPG)와 [[baduki-card-game]] 개발에 사용.

## 관련 프로젝트

- [[godblade]] — 2D 액션 RPG (C#)
- [[baduki-card-game]] — 2D 카드게임

## Growth Notes

- Unity 2026 신기능 / AI 도구 연동 현황 추가 예정
- 빌드 파이프라인·에셋 관리 규칙 정리 예정
""",
    ),
]


def apply_aliases(text: str) -> tuple[str, int]:
    count = 0
    for bad, good in ALIASES.items():
        # replace [[bad]] and [[bad|alt]] with [[good]] / [[good|alt]]
        pattern = re.compile(r'\[\[' + re.escape(bad) + r'(\|[^\]]+)?\]\]')
        def repl(m):
            nonlocal count
            count += 1
            return f"[[{good}{m.group(1) or ''}]]"
        text = pattern.sub(repl, text)
    return text, count


def remove_garbage(text: str) -> tuple[str, int]:
    count = 0
    for g in GARBAGE:
        pattern = re.compile(r'\[\[' + re.escape(g) + r'(?:\|[^\]]+)?\]\]')
        def repl(m):
            nonlocal count
            count += 1
            return f"`{g}`"  # keep as code text, removes the link
        text = pattern.sub(repl, text)
    return text, count


def create_stubs() -> list[Path]:
    created = []
    for slug, folder, ftype, tags, title, body in STUBS:
        path = WIKI / folder / f"{slug}.md"
        if path.exists():
            continue
        tags_yaml = "[" + ", ".join(tags) + "]"
        fm = f"""---
type: {ftype}
created: 2026-04-14
tags: {tags_yaml}
stub: true
---

# {title}

{body}"""
        path.write_text(fm, encoding="utf-8")
        created.append(path)
    return created


def main() -> int:
    alias_total = 0
    garbage_total = 0
    files_changed = 0
    for sub in ("concepts", "tools", "topics", "people"):
        for md in (WIKI / sub).glob("*.md"):
            orig = md.read_text(encoding="utf-8")
            step1, a = apply_aliases(orig)
            step2, g = remove_garbage(step1)
            if step2 != orig:
                md.write_text(step2, encoding="utf-8")
                files_changed += 1
                alias_total += a
                garbage_total += g

    print(f"Slug alias replacements: {alias_total}")
    print(f"Garbage link removals: {garbage_total}")
    print(f"Files changed: {files_changed}")

    stubs = create_stubs()
    print(f"\nStub notes created: {len(stubs)}")
    for s in stubs:
        print(f"  {s.relative_to(WIKI)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
