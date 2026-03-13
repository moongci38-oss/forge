# Always Scope — Category Registry

> 모든 세션에 로드되는 기본 규칙 카테고리.
> 우선순위 순서: 보안 → 워크플로우 → 품질 → 권장

| 순서 | 카테고리 | ID | Impact | 설명 |
|:----:|---------|-----|:------:|------|
| 1 | 보안 | security-rules | CRITICAL | 민감 정보 보호, 접근 제한 |
| 2 | Git 워크플로우 | git-rules | HIGH | 브랜치 전략, 커밋 규칙 |
| 3 | 병렬 실행 | parallel-execution | HIGH | 병렬 처리, 오케스트레이션 |
| 4 | 파일명 규칙 | file-naming | MEDIUM | 명명 규칙, 폴더 구조 |
| 5 | 리서치 방법론 | research-methodology | MEDIUM | 출처 검증, 신뢰도 등급 |
| 6 | Cowork 환경 | cowork-environment | MEDIUM | MCP→내장 도구 매핑 |
