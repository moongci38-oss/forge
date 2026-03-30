# docs/ 통일 폴더 구조

> 모든 프로젝트(Business, Portfolio, GodBlade)가 동일한 docs/ 하위 구조를 사용한다.
> 새 문서 생성 시 반드시 아래 구조에 맞는 폴더에 저장한다.

## 폴더 구조

```
docs/
├── guides/           ← 셋업 가이드, 사용법, 튜토리얼
├── tech/             ← 프로젝트 고유 기술 문서
├── planning/
│   ├── active/       ← 진행 중인 계획/기획서
│   └── done/         ← 완료된 계획
├── reviews/          ← 코드 리뷰, 분석 리포트, 진단 결과
├── infrastructure/   ← 서버, DB, CI/CD, 배포 관련
├── walkthroughs/     ← 구현 워크스루
├── assets/           ← 이미지, 미디어, 첨부 파일
└── _archive/         ← 더 이상 사용하지 않는 문서
```

## 폴더별 저장 기준

| 폴더 | 저장 대상 | 예시 |
|------|----------|------|
| `guides/` | 환경 셋업, 도구 사용법, 온보딩 | MCP 설정, DB 연결, 팀 셋업 |
| `tech/` | 프로젝트 고유 기술 분석/설계 | 아키텍처 문서, API 레퍼런스 |
| `planning/active/` | 현재 진행 중인 기획/개발 계획 | PRD, 로드맵, 스프린트 계획 |
| `planning/done/` | 완료된 계획 (레퍼런스용 보존) | 이전 스프린트, 완료 기획서 |
| `reviews/` | 코드 리뷰, 품질 분석, 진단 | 갭 분석, 성능 리포트 |
| `infrastructure/` | 서버/DB/배포 운영 문서 | DB 마이그레이션, CI 설정 |
| `walkthroughs/` | 구현 과정 기록 (SDD 산출물) | 기능별 구현 워크스루 |
| `assets/` | 비텍스트 파일 | 스크린샷, 다이어그램 |
| `_archive/` | 비활성 문서 (삭제 대신 보관) | 레거시, 1회성 리포트 |

## 전역 문서 (프로젝트에 배포하지 않음)

v1.4.0부터 아래 문서는 `forge/dev/`에서 직접 참조한다 (프로젝트에 복사 안 함):

- `forge/shared/docs/` — Forge 아키텍처, 온보딩 가이드
- `forge/shared/docs/shared-docs/` — 범용 기술 참고 문서

## 문서 생성 규칙

1. 새 문서 생성 전 위 테이블에서 적절한 폴더를 선택한다
2. `docs/` 루트에 직접 파일을 생성하지 않는다 (반드시 하위 폴더 사용)
3. 파일명은 프로젝트별 명명 규칙을 따른다 (Business: `YYYY-MM-DD-{name}.md`)
4. 완료된 계획은 `planning/active/` → `planning/done/`으로 이동한다
5. 더 이상 참조하지 않는 문서는 `_archive/`로 이동한다 (삭제 대신)
