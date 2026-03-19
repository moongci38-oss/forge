---
description: Forge Dev Check 3.8 보안 검수 — 독립 실행
allowed-tools: Bash, Read, Grep, Glob
model: sonnet
disable-model-invocation: true
---

# /forge-check-security — 보안 검수 게이트

Check 3.8 보안 검증을 독립적으로 실행합니다.

## 실행

1. `security-gate.md` 프롬프트 로드
2. 프로젝트별 보안 검증 스크립트 실행
3. OWASP Top 10 패턴 매칭
4. 의존성 CVE 스캔
5. 결과를 JSON 형식으로 반환

## 판정 기준

| 레벨 | 조건 | 행동 |
|------|------|------|
| Level 1 | WARN만 | 자동 수정 가능 |
| Level 2 | FAIL 1~2건 | 자동 수정 + 재검증 |
| Level 3 | FAIL 3건+ | [STOP] Human 승인 |
