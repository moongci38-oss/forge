# Development Workflow Rules

## Git — Forge
- develop 브랜치에 먼저 커밋/푸시. main 직접 커밋 금지.
- git push / git merge → allow (ask 금지). 파이프라인 흐름 유지.
- CI PASS + 리뷰 완료 시 자동 머지 후 다음 작업 진행.

## Spec 관리
- 구현 진행 중인 Spec 문서(.spec.md) 사후 변경 금지.

## Article 스킬
- `/article` 실행 시 Sonnet 모델 강제 사용.
- context compaction 후 재개 시 이전 단계 결과 파일 먼저 확인.

## PPT 디자인 시스템
- SF Pro Display 폰트, Instagram 컬러 토큰, 16:9 와이드스크린, 밝은 톤
- PPT 작성 시 항상 위 시스템 적용

## GodBlade 경로 주의
- GodBlade 실제 작업 경로: `god_Sword/src/`
- `Godblade/` (대문자 G, 소문자 b) 디렉토리는 비활성 — 절대 작업 금지
