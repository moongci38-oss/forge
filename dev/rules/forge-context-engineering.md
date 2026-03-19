---
title: "컨텍스트 엔지니어링 규칙"
id: forge-context-engineering
impact: HIGH
scope: [forge]
tags: [context, ace-fca, skill, subagent, loading, passive, active, deep]
requires: [forge-workflow]
section: forge-context
audience: dev
impactDescription: "미준수 시 Subagent raw 출력으로 컨텍스트 오염, 불필요한 스킬 로딩으로 토큰 낭비, 점진적 로딩 미적용으로 세션 시작부터 10K+ 토큰 소비"
enforcement: rigid
---

# Context Engineering Rules (ACE-FCA)

> ACE-FCA Intentional Compaction 적용. Skill vs Subagent 기준. Passive/Active/Deep 3단계 점진적 로딩.

## 핵심 원칙

| ACE-FCA 원칙 | Forge Dev 워크플로우 매핑 |
|-------------|-------------------|
| Research → Plan → Implement | Phase 1.5 → Phase 2 → Phase 3 |
| 컨텍스트 70% 이하 유지 | Phase 전환 시 `/compact` 판단 (70% 이상 시 실행) |
| Subagent는 구조화 요약만 반환 | Check 3.6/3.7/3.8 → JSON만 전달 |
| 컨텍스트 품질 실패 → 재시작 | session-state로 중단점 재개 |

## Skill vs Subagent 선택 기준

| 질문 | 결과 |
|------|------|
| 메인 컨텍스트 오염이 큰가? → Yes | **Subagent** (격리) |
| 오염 적음 + 전문 지식 필요? → Yes | **Skill** (전문 지식 주입) |
| 오염 적음 + 전문 지식 불필요 | **직접 실행** (Glob/Grep/Read, 3회 이내) |

## /compact 실행 규칙

| 시점 | 조건 | 행동 |
|------|------|------|
| Phase 전환 | 컨텍스트 70% 이상 | AI 에이전트가 `/compact` 실행 |
| Phase 전환 | 컨텍스트 70% 미만 | 스킵 (불필요한 압축 방지) |
| 자동 수정 3회 초과 | Check 3↔3.5 루프 | `/compact` 후 재시작 |

## History 크기 제한

| 히스토리 | 최근 N개 유지 | 나머지 |
|---------|:-----------:|--------|
| `autoFixHistory` | **5개** | `autoFixArchive` (요약만) |
| `rollbackHistory` | **3개** | `rollbackArchive` |
| `timeoutHistory` | **3개** | `timeoutArchive` |
| `humanOverrides` | **3개** | `overrideArchive` |

아카이브 형식: `{ check, resolved, timestamp }` (상세 필드 제거)

## Subagent 결과 반환 규칙

- **금지**: raw grep/read 출력을 그대로 반환
- **필수**: 구조화 JSON만 반환 (~500 토큰)

```json
{
  "checkId": "check-3.7",
  "status": "FAIL",
  "issues": [
    { "file": "{project-specific-path}", "line": 42, "rule": "violation-id", "severity": "error", "autoFixable": true }
  ],
  "summary": "패턴 위반 N건, 자동 수정 가능 M건",
  "autoFixable": true
}
```

## Passive/Active/Deep 3단계 점진적 로딩

스킬과 규칙을 필요 시점까지 로딩을 지연하여 토큰을 절약한다.

### 3단계 구조

| 단계 | 로딩 시점 | 내용 | 토큰 |
|:----:|---------|------|:----:|
| **Passive** | 세션 시작 시 항상 | AGENTS.md 압축 원라이너 (CRITICAL/HIGH 규칙 요약) | ~750 |
| **Active** | 스킬 호출 시 | SKILL.md 전체 (인덱스 + 카테고리별 요약) | ~1,500 |
| **Deep** | Check 실행 시 | 개별 룰 파일 (해당 카테고리만 선택 로드) | ~200/룰 |

### Passive 단계 (AGENTS.md)

- 프로젝트 루트 `.claude/AGENTS.md` 또는 스킬 디렉토리 `AGENTS.md`
- 모든 CRITICAL/HIGH 규칙을 **원라이너**로 압축
- AI가 코드 작성 시 항상 참조 → "No decision point" (판단 없이 적용)
- 목표: **~750토큰으로 80% 위반 방지**
- **권장**: Business 워크스페이스 루트에도 AGENTS.md 신설하여 전역 CRITICAL 규칙(보안, 접근제한, Iron Law) 요약 포함. 현재 forge/ 스킬 레벨에만 존재함

### Active 단계 (SKILL.md)

- 스킬 호출(`Skill` 도구) 시 자동 로드
- 전체 규칙 인덱스 + 카테고리별 요약 + 적용 지침
- Check 실행 전 도메인 지식 확보용

### Deep 단계 (개별 룰 파일)

- Check 3.7P (성능) / Check 3.7 (코드 품질) 실행 시
- 파일 접두사 기반 라우팅으로 **해당 카테고리만** 선택 로드:
  - `.tsx`/`.jsx` 파일 변경 → 프론트엔드 룰 (`async-*`, `bundle-*`, `rerender-*` 등)
  - `.service.ts` 파일 변경 → 백엔드 룰 (forge-performance.md)
  - `.module.ts` 파일 변경 → 모듈 의존성 룰 (forge-module-dependency.md)
- Before/After 코드 쌍으로 정밀 패턴 매칭

### 토큰 효율 비교

| 전략 | 세션 시작 토큰 | 최대 토큰 (전체 로드) |
|------|:----------:|:------------------:|
| 기존 (단일 레벨) | ~10,700 | ~10,700 (항상 전체) |
| 3단계 (Passive만) | **~750** | ~16,000 (Deep 전체 시) |
| 절감율 | **93% 절감** | 최악 시 50% 증가 (드묾) |

### 라우팅 규칙

```
변경 파일 확장자/경로 → 로드할 Deep 룰 카테고리
─────────────────────────────────────────────
*.tsx, *.jsx           → react-best-practices/rules/async-*, bundle-*, rerender-*, composition-*
*.ts, *.tsx            → code-quality-rules/rules/* (시맨틱 코드 품질)
*.service.ts           → forge-performance.md, forge-observability.md
*.controller.ts        → forge-performance.md, forge-observability.md
*.module.ts            → forge-module-dependency.md
*.entity.ts            → forge-performance.md, forge-database-operations.md
*.migration.ts         → forge-database-operations.md
*.spec.ts, *.test.ts   → forge-test-quality.md
*.e2e-spec.ts          → forge-test-quality.md (T-1, T-6)
page.tsx, layout.tsx   → react-best-practices/rules/server-*, rendering-*
```

## Subtraction Review (감산 리뷰)

규칙/컴포넌트 추가 시 복잡도 단조 증가를 방지하는 구조적 브레이크.

**적용 조건**: 갭 분석 또는 개선 작업에서 규칙/에이전트/스킬을 3개 이상 추가 제안 시

**필수 섹션**:
1. **제거 후보 식별**: "이 변경으로 제거/간소화할 수 있는 기존 컴포넌트는?"
2. **복잡도 수지**: "총 파일 수와 토큰 예산이 이전 대비 증감했는가?"

**게이트 규칙**: 순 증가가 +2개를 초과하면 추가 정당화 필요.

## AI 행동 규칙

1. Phase 전환 시 컨텍스트 사용률 확인 → 70% 이상이면 `/compact` 실행
2. Subagent 스폰 시 반드시 JSON 반환 형식 명시
3. Skill은 전문 지식 주입 용도로만 사용 (대량 탐색 금지)
4. 직접 실행은 Glob/Grep/Read 3회 이내로 제한
5. 스킬 로딩은 3단계 전략을 따른다 — Passive 먼저, 필요 시 Active/Deep 순차 로드
6. Deep 단계에서 파일 라우팅 규칙을 적용하여 불필요한 룰 로딩을 방지한다
7. 전체 Deep 로드가 필요한 경우 `/compact` 실행 후 진행한다
8. 규칙/컴포넌트 3개 이상 추가 시 Subtraction Review를 실행한다
