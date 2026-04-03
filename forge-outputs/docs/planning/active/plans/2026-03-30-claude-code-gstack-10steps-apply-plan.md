# Claude Code 고도화 적용 계획서
> 기반 영상: gstack 완전 분석 + 클로드코드 10단계 로드맵
> 작성일: 2026-03-30
> 비교 분석: docs/reviews/2026-03-30-claude-code-gstack-10steps-comparison.md

---

## 배경

두 영상을 통해 도출된 실질적인 개선 포인트는 2가지로 좁혀진다:
1. forge 프로젝트 MCP 5개 항시 활성 → 41% 컨텍스트 고정 소비
2. context compaction buffer가 45K→33K로 줄어 compaction이 더 빨리 발동됨

gstack의 나머지 핵심 패턴(스킬 구조, CLAUDE.md, 코드 리뷰, 배포 자동화, 기획 검토)은 이미 forge에 구현되어 있음.

---

## 적용 항목

### P1 — 이번 주

#### 1. forge MCP 조건부 활성화
**현황**: forge .mcp.json에 sequential-thinking, drawio, replicate, nano-banana, stitch 5개 항시 로드
**문제**: 매 Claude Code 세션 시작 시 ~41% 컨텍스트 고정 소비
**변경 내용**:
- `drawio`, `replicate`, `stitch` → .mcp.json에서 제거
- 필요 시 `/add-mcp` 또는 `mcp add` 명령으로 임시 추가
- `sequential-thinking`, `nano-banana` → 유지 (Forge 기획/이미지 생성에 자주 사용)

**기대 효과**: 세션당 컨텍스트 ~25% 절감, compaction 발동 빈도 감소, 장기 세션 품질 향상

**검증 기준**: 변경 후 `/context` 명령으로 MCP 토큰 사용량 확인

---

### P2 — 이번 달

#### 2. CLAUDE.md에 /clear 사용 가이드 추가
**현황**: 세션 관리에 명시적 /clear 규칙 없음
**변경 내용**: forge CLAUDE.md 또는 forge-core.md에 아래 가이드 추가
```
세션 관리:
- 관련 없는 새 작업 시작 전: /clear 실행
- 장기 세션(1시간+) 중 이상 동작 시: /clear 후 재시작
- context compaction buffer: 33K tokens (2026년 3월 기준)
```

#### 3. playwright-cli 스킬 persistent session 검토
**현황**: playwright-cli 스킬은 매 호출 시 새 Chromium 세션
**변경 내용**: `--persist` 플래그 추가 검토 (gstack /browse 아키텍처 참고)
- .gstack/browse.json 방식의 세션 상태 저장
- Bun HTTP 서버 방식 대신 playwright의 storageState 활용 가능

**의존성**: playwright-cli 스킬 구조 먼저 검토 필요

---

## 제외 항목

| 항목 | 제외 이유 |
|------|---------|
| gstack 전체 설치 | 핵심 패턴(스킬, 코드리뷰, 배포, 기획검토)이 이미 forge에 구현됨 |
| /retro 스킬 추가 | 현재 blocking 없음, 영향도 낮음 |
| /benchmark 스킬 추가 | 현재 필요성 미확인 |
| Max 플랜 업그레이드 | 현재 소비 패턴 미측정, P2 이후 검토 |

---

## 실행 체크리스트
- [ ] forge .mcp.json에서 drawio, replicate, stitch 제거 후 `/context`로 토큰 확인 (P1, Forge)
- [ ] forge-core.md에 /clear 사용 가이드 추가 (P2, Forge)
- [ ] playwright-cli SKILL.md 검토 후 storageState 지원 타당성 판단 (P2, Portfolio/GodBlade)

---

## 참고 영상
- gstack 완전 분석: https://youtu.be/0322tGsiauo — 분석: `01-research/videos/analyses/2026-03-30-0322tGsiauo-...-analysis.md`
- 클로드코드 10단계: https://youtu.be/d-iNXwtwdFU — 분석: `01-research/videos/analyses/2026-03-30-d-iNXwtwdFU-...-analysis.md`
- gstack GitHub: https://github.com/garrytan/gstack
- MCP 오버헤드 실측: https://scottspence.com/posts/optimising-mcp-server-context-usage-in-claude-code
