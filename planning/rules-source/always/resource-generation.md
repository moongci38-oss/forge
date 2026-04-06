---
title: "리소스 생성 거버넌스"
id: resource-generation
impact: MEDIUM
scope: [always]
tags: [resource, asset, image, generation, diamond]
requires: []
section: always
audience: all
impactDescription: "스타일 가이드 없이 에셋 생성 시 프로젝트 내 시각적 불일치 → 재생성 비용 증가"
enforcement: flexible
---

# 리소스 생성 거버넌스 (Diamond Architecture)

## 핵심 원칙

AI 에셋 생성은 **Diamond Architecture** (확산→수렴→확산→수렴)를 따른다:

```
P0 (수렴): 스타일 정의 — 기존 에셋에서 스타일 추출 → style-guide.md 생성
P1 (수렴): 방향 설정 — Art Direction Brief 작성 → 감성/안티패턴/차별화 확정
P2 (확산): 프로토타입 — 소수 에셋(3-5개) 시험 생성 → Human 피드백
P3 (확산): 대량 생산 — 승인된 스타일로 전체 에셋 생성
P4 (수렴): 품질 검증 — 일관성 검증 + 크리틱 루프 → 최종 확정
```

## 렌더링 레벨 (Rendering Quality Level)

이미지/다이어그램/슬라이드의 비주얼 품질 단계. 프로젝트 style-guide에서 레벨을 선택한다.
**상세 정의**: `shared/design-tokens/rendering-levels.md`

| Level | 이름 | 적합 용도 |
|:-----:|------|----------|
| L1 | Flat 2D | 내부 메모, 초안 |
| L2 | Soft 3D | 일반 기획서, 내부 보고서 |
| **L3** | **Premium Glassmorphism** | **정부과제, IR, 공식 제안서** |
| L3.5x | 변형 (Isometric/Infographic/Neon/Clay/Paper) | 특화 용도별 선택 |
| L4 | Cinematic 3D | 제품 런칭, 프리미엄 키노트 |
| L5 | Rendered 3D | 영상/게임 에셋 |

## 3-Tier 에셋 분류

| Tier | 분류 | 기준 | 생성 방식 |
|:----:|------|------|----------|
| **T1** | 핵심 브랜딩 | 로고, 메인 캐릭터, 히어로 이미지 | Human 디자인 또는 Human 밀착 감독 |
| **T2** | 주요 에셋 | UI 컴포넌트, 배경, 아이콘 세트 | AI 생성 + Human 승인 (1장씩 순차) |
| **T3** | 대량 에셋 | 필러 이미지, 패턴, 변형 | AI 배치 생성 + 샘플링 검증 |

## 진입 시나리오

| 시나리오 | 조건 | 시작 단계 |
|---------|------|----------|
| **A. 기존 에셋 있음** | 프로젝트에 5개+ 에셋 존재 | P0 (스타일 추출) |
| **B. 신규 프로젝트** | 에셋 없음, 레퍼런스 있음 | P1 (Art Direction Brief) |
| **C. 백지 시작** | 에셋/레퍼런스 없음 | `/screenshot-analyze` 경쟁작 분석 → P1 |

## 품질 게이트

### P0→P1: 스타일 가이드 검증
- [ ] style-guide.md 생성 완료
- [ ] 컬러 팔레트 5색 이상
- [ ] 아트 스타일 키워드 3개 이상

### P1→P2: Art Direction Brief 검증
- [ ] 감성 키워드 3개
- [ ] 안티패턴 2개 이상
- [ ] 무드보드 레퍼런스 3개 이상 (비경쟁 도메인)

### P2→P3: 프로토타입 승인
- [ ] Human이 프로토타입 3-5개 중 방향 승인
- [ ] 안티패턴 해당 없음 확인
- [ ] 일관성 검증 PASS

### P3→P4: 최종 검증
- [ ] 크리틱 4항목 (계층/일관성/안티패턴/브리프) 전체 PASS
- [ ] resource-manifest.md 업데이트 완료
- [ ] Git LFS 정책 준수 확인

## 크로스 에셋 일관성 검증

에셋 5개 이상 생성 후, 전체를 한 화면에 배치하여 일관성을 검증한다:

1. 에셋 컴포지트 이미지 생성 (가로 배열)
2. `/screenshot-analyze` 호출 — "같은 프로젝트 에셋으로 보이는가?" 검증
3. 불일치 에셋 식별 → 재생성 또는 style-guide 조정

## MCP 폴백 체인

도구 장애 시 자동 폴백:

| 1차 도구 | 폴백 | 비고 |
|---------|------|------|
| Replicate (LoRA) | NanoBanana MCP | 85% 일관성 (허용) |
| Ludo.ai | NanoBanana + 수동 슬라이싱 | 스프라이트 시트 분리 필요 |
| Ludo.ai | NanoBanana (2D) / Asset Store (3D) | 3D는 구매 대체 |
| Stitch MCP | NanoBanana + 수동 목업 | 목업 기능 축소 |
| Magic Patterns | Stitch MCP + frontend-design | image-to-code 불가 |

**규칙**: 1회 재시도 → 실패 → 자동 폴백 + Human 알림. 파이프라인 중단 금지.

## Git LFS 정책

### 게임 프로젝트 `.gitattributes`
```
*.png filter=lfs diff=lfs merge=lfs -text
*.psd filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
```

### 웹 프로젝트 `.gitattributes`
```
public/images/**/*.png filter=lfs diff=lfs merge=lfs -text
public/images/**/*.webp filter=lfs diff=lfs merge=lfs -text
```

### 크기 제한
- 단일 파일: 10MB 이하
- PR당 총 에셋: 50MB 이하 (초과 시 별도 에셋 PR 분리)

## Do

- 에셋 생성 전 style-guide.md 존재를 확인한다
- 한 번에 1장씩 순차 생성하고 Human 피드백을 받는다
- resource-manifest.md를 에셋 추가/수정마다 업데이트한다
- 5개 이상 에셋 생성 후 일관성 검증을 실행한다

## Don't

- style-guide.md 없이 에셋을 대량 생성하지 않는다
- T1 (핵심 브랜딩) 에셋을 AI 자율 생성하지 않는다
- 안티패턴 라이브러리 항목에 해당하는 에셋을 승인하지 않는다
- Git LFS 없이 10MB+ 바이너리를 커밋하지 않는다

## AI 행동 규칙

1. 에셋 생성 요청 시 style-guide.md 존재 여부를 먼저 확인한다
2. 미존재 시 P0 (스타일 추출) 또는 P1 (신규 작성)부터 시작을 제안한다
3. 에셋 1장 생성 → Human 확인 → 다음 에셋 (병렬 생성 금지)
4. 5개 이상 에셋 누적 시 일관성 검증을 자동 제안한다
5. MCP 도구 실패 시 폴백 체인에 따라 자동 전환 + Human 알림
6. resource-manifest.md를 에셋 변경 시 즉시 업데이트한다
