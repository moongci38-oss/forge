# 리소스 AI 파이프라인 사용 가이드

> AI 이미지/에셋 생성 파이프라인의 사용법과 워크플로우.

## 개요

리소스 파이프라인은 **Diamond Architecture** (P0→P1→P2→P3→P4)를 따르며, 프로젝트의 시각적 일관성을 보장하면서 AI 도구로 에셋을 생성한다.

## 빠른 시작

### 시나리오 A: 기존 에셋이 있는 프로젝트

```bash
# 1. 기존 에셋에서 스타일 추출 (P0)
/screenshot-analyze --mode style-extraction {에셋 폴더}
# → style-guide.md 자동 생성

# 2. Art Direction Brief 작성 (P1)
# → 09-tools/templates/art-direction-brief-template.md 기반 작성

# 3. 프로토타입 생성 (P2)
/generate-image {프롬프트}  # style-guide.md 자동 참조

# 4. Human 승인 후 대량 생성 (P3)
/game-asset-generate {에셋 유형}  # 게임 에셋
/generate-image {프롬프트}         # 웹/앱 에셋

# 5. 일관성 검증 (P4)
/screenshot-analyze --mode consistency-check {에셋 폴더}
```

### 시나리오 B: 신규 프로젝트

1. 경쟁작 스크린샷 분석: `/screenshot-analyze {경쟁작 스크린샷}`
2. Art Direction Brief 작성 (템플릿 기반)
3. 스타일 가이드 수동 작성 (경쟁작 분석 결과 + 차별화)
4. P2부터 진행

### 시나리오 C: LoRA 학습이 필요한 프로젝트

```bash
# 기존 에셋 5-10개로 LoRA 학습
/style-train {에셋 폴더}
# → Replicate에 모델 업로드 + style-guide.md에 모델 ID 기록

# 학습된 모델로 생성
/generate-image --model replicate {프롬프트}
```

## 도구 매핑

| 에셋 유형 | 1차 도구 | 폴백 | 스킬 |
|---------|---------|------|------|
| 2D 일러스트/배경 | NanoBanana MCP | Replicate (LoRA) | `/generate-image` |
| 스프라이트 시트 | Ludo.ai MCP | NanoBanana + 수동 슬라이싱 | `/game-asset-generate` |
| 아이콘 세트 | Replicate / Ludo.ai | NanoBanana | `/game-asset-generate` |
| 3D 모델 | Ludo.ai MCP | Asset Store | `/game-asset-generate` |
| UI 목업 | Stitch MCP | — | Stitch 직접 호출 |
| UI 와이어프레임 | Stitch MCP | NanoBanana | `/frontend-design` |

## 템플릿 위치

| 템플릿 | 경로 | 용도 |
|--------|------|------|
| 스타일 가이드 | `09-tools/templates/style-guide-template.md` | 시각적 규격 정의 |
| 리소스 매니페스트 | `09-tools/templates/resource-manifest-template.md` | 에셋 추적 |
| Art Direction Brief | `09-tools/templates/art-direction-brief-template.md` | 감성/방향 정의 |
| AI 안티패턴 | `09-tools/templates/ai-anti-patterns.md` | 품질 문제 사전 방지 |

## 규칙 참조

- `09-tools/rules-source/always/resource-generation.md` — Diamond Architecture 거버넌스
- `~/.claude/rules/` 컴파일 후 → `business-core.md`에 포함

## 주의사항

- **1장씩 순차 생성**: 병렬 이미지 생성 금지 (Human 피드백 루프 유지)
- **MCP API 키 필요**: Replicate, Ludo.ai 등은 별도 API 키 설정 필요 (`~/.claude/scripts/.env`)
- **Git LFS**: 이미지 파일은 반드시 Git LFS 정책 준수
- **안티패턴 체크**: 생성 후 `ai-anti-patterns.md` 대조 필수

---

*Last Updated: 2026-03-17*
