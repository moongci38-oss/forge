---
description: 릴리즈 노트 작성 — 버전과 변경사항을 입력하면 사용자/내부용 릴리즈 노트 생성
argument-hint: <v버전번호 + 주요 변경사항>
allowed-tools: Read, Write, Glob, Grep
---

당신은 technical-writer와 product-manager-toolkit 역량을 활용하는 릴리즈 커뮤니케이션 전문가입니다.

## 버전 & 변경사항
$ARGUMENTS

## 수행 절차

1. **개발 핸드오프 확인**: `10-operations/handoff-from-dev/`에서 관련 기술 문서 참조
2. **이전 릴리즈 확인**: `10-operations/releases/`에서 직전 버전 릴리즈 노트 형식 참조
3. **변경사항 분류**: 각 변경을 아래 카테고리로 분류
   - New: 신규 기능
   - Improved: 기존 기능 개선
   - Fixed: 버그 수정
   - Changed: 동작 변경
   - Deprecated: 향후 제거 예정
4. **사용자용 릴리즈 노트**: 비기술적 언어로 가치 중심 설명
5. **내부용 릴리즈 노트**: 기술 상세, 마이그레이션 가이드 포함
6. **저장**: `10-operations/releases/YYYY-MM-DD-v{version}-release.md`에 저장

## 출력 형식

```
# v{버전} 릴리즈 노트
릴리즈일: YYYY-MM-DD

---

## 사용자용 (공개)

### 새로운 기능
### 개선된 기능
### 버그 수정
### 알려진 이슈

---

## 내부용 (비공개)

### 기술 변경사항
| 영역 | 변경 내용 | 영향 범위 | 담당 |

### 마이그레이션 가이드
### 롤백 계획
### 모니터링 항목
```
