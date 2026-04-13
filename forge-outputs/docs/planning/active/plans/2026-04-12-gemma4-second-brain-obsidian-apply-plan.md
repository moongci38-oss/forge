# 적용 계획서: Gemma 4 + Obsidian 제2의 두뇌 패턴
> 영상: [EP.3] 구글 Gemma 4로 나만의 AI 제2의 두뇌 복제하기 (CONNECT AI LAB)
> 작성일: 2026-04-12

---

## 핵심 방향

영상의 Karpathy LLM Wiki 패턴(raw→wiki 계층 + 자동 교차참조)을 Forge Memory 시스템에 부분 적용한다.
Obsidian 도입이나 AntiGravity 앱은 우리 시스템에 불필요 — 스킬/에이전트 기반으로 동등한 구조 구현.

---

## P0 — 즉시 (30분)

### forge memory 2계층 분리 명문화

**현황**: `~/.claude/projects/{forge}/memory/*.md` 파일이 단일 계층으로 혼재
**변경**: README 또는 MEMORY.md에 "raw vs. wiki" 역할 구분을 명시
- `raw/` 개념 = 바로 생성된 메모리 파일 (새 피드백, 학습 등)
- `wiki/` 개념 = 정제·교차참조된 메모리 파일 (기존 대부분)
- 실제 폴더 이동은 P1에서 처리 — 이 단계는 분류 기준 정의만

**기대 효과**: 이후 자동화 파이프라인 설계 기반 마련

---

## P1 — 이번 달

### daily-system-review 스킬에 learnings → wiki 변환 단계 추가

**현황**: `learnings.jsonl`에 JSON 라인 형태로 학습 누적. 검색 불편.
**변경**:
1. daily-system-review 종료 시 새 learnings를 마크다운으로 변환
2. 주제 분류 (AI/워크플로우/프로젝트별) → `memory/wiki/{주제}/` 폴더에 저장
3. 기존 관련 파일에 `## 관련 학습` 섹션 링크 추가

**구현 방법**: `daily-system-review` SKILL.md에 후처리 단계 추가 (hook 또는 마지막 스텝)
**기대 효과**: 누적된 learnings가 검색 가능한 구조로 변환, 컨텍스트 로드 효율 향상

---

## P2 — 다음 분기

### Karpathy LLM Wiki 패턴 full 구현

**목표**: forge memory를 raw/wiki/meta 3계층으로 리팩토링

```
~/.claude/projects/{forge}/memory/
├── raw/          # 정제 전 원본 (피드백, 새 학습)
├── wiki/         # LLM 정제·분류 결과
│   ├── ai/
│   ├── workflow/
│   ├── project/
│   └── feedback/
└── meta/         # 교차참조 그래프 (JSON)
```

**추가 기능**:
- weekly-research 스킬에 "lint" 단계 — 모순/고아 메모리 검출 + 통합 제안
- memory 인덱스 파일 자동 갱신

### Gemma 4 E4B WSL2 평가 (선택)

**조건**: Claude API 비용이 월 $X 이상 증가하는 시점에서 재평가
**평가 항목**: Ollama + Gemma 4 E4B 설치, 분류/요약 품질 vs. Claude Haiku 비교
**참고**: Gemma 4 E2B/E4B는 모바일급 실행 가능. WSL2에서 CPU 추론 가능하나 속도 한계

---

## 제외 항목

| 항목 | 제외 이유 |
|------|---------|
| Obsidian 도입 | 우리 시스템 CLI 기반. 그래프 시각화 필요성 낮음 |
| AntiGravity 앱 연동 | 외부 독점 앱 종속. 스킬 기반 대체 가능 |
| YouTube API → Obsidian 자동화 | yt-analyze 스킬로 이미 커버 |
| P-reinforce 스킬 그대로 복제 | 영상 스킬 원본 미공개. 동등 기능 자체 구현 예정 |

---

## 실행 체크리스트
- [ ] P0: MEMORY.md에 raw/wiki 역할 구분 주석 추가 (담당: Business)
- [ ] P1: daily-system-review SKILL.md에 learnings→wiki 변환 스텝 설계 (담당: Forge Dev)
- [ ] P2: memory 3계층 구조 리팩토링 계획 수립 (담당: Forge Dev)
- [ ] P2: Gemma 4 E4B WSL2 설치 테스트 (조건부)

---

## 참고
- 원본 영상: https://youtu.be/TNEwF_WmgO4
- Karpathy LLM Wiki gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- 분석 파일: `01-research/videos/analyses/2026-04-12-TNEwF_WmgO4-...-analysis.md`
- 비교 리포트: `docs/reviews/2026-04-12-gemma4-second-brain-obsidian-comparison.md`
