---
name: library-search
description: Prefab Visual Library에서 기존 에셋을 검색하여 MCP 생성 비용을 절감하는 스킬. 키워드/태그/트랙으로 검색하고, 완전매칭/부분매칭/없음 분기를 제안한다. 에셋 생성 전 Library-First 탐색 전용.
user-invocable: true
context: fork
---

# Library Search — Prefab Visual Library 검색

에셋 생성 요청 시 **먼저** Library에서 재사용 가능한 기존 에셋을 검색한다. MCP 호출 0회로 처리하거나, 유사 에셋을 base로 리터치하여 비용을 60-76% 절감한다.

## 언제 사용하는가

- `/game-asset-generate` 실행 전 자동 호출 (Step 4)
- Human이 "기존 에셋 있어?" / "Library에서 찾아봐" 요청 시
- 에셋 카탈로그 브라우징이 필요할 때

## 전제조건

1. Prefab Visual Library Git 레포가 로컬에 클론되어 있음
   - GitLab: `ssh://git@ssh.lumir-ai.com:32361/lumir/prefab-visual-library.git`
   - 클론: `git clone ssh://git@ssh.lumir-ai.com:32361/lumir/prefab-visual-library.git ~/prefab-visual-library`
2. 환경변수 `PREFAB_LIBRARY_PATH` 설정 (미설정 시 기본: `~/prefab-visual-library`)
   - 또는 `forge-workspace.json`의 `prefabLibraryRoot` 경로 참조
3. `_metadata.json` 파일이 Library 루트에 존재

## 팀 공유

- Library는 GitLab 별도 레포로 관리 (팀원 clone으로 접근)
- 새 에셋 추가 시 _metadata.json 갱신 후 commit + push
- 팀원이 `git pull`하면 최신 에셋 카탈로그 자동 동기화

## 워크플로우

```
1. 검색 쿼리 구성
   → Human 요청에서 키워드 추출
   → 트랙 판별: 🎮 game / 🌐 web / shared

2. _metadata.json 로드
   → PREFAB_LIBRARY_PATH/_metadata.json 읽기
   → 에셋 전체 목록 로드

3. 매칭 수행
   → tags + style_tags 필드에서 키워드 매칭
   → track 필드로 트랙 필터링
   → quality_score 내림차순 정렬
   → 상위 5개 후보 반환

4. 매칭 결과 분기

   ├─ 완전 매칭 (quality_score 4.0+ & 태그 80%+ 일치)
   │   → 에셋 정보 표시: 이름, 경로, 썸네일 설명, 크리틱 점수
   │   → "Library에 [에셋명]이 있습니다. 직접 사용할까요?"
   │   → Human 확인 → 사용 시 usage_count++ 갱신
   │   → 결과: MCP 호출 0회 ✅
   │
   ├─ 부분 매칭 (유사 에셋 존재, 태그 50-79% 일치)
   │   → 유사 에셋 목록 표시 (최대 3개)
   │   → "유사 에셋 [에셋명]을 base로 리터치할까요?"
   │   → Human 확인 → NanoBanana edit_image로 변형
   │   → 변형 결과도 Library에 등록 후보
   │   → 결과: MCP 0.3회 (edit만)
   │
   └─ 매칭 없음 (태그 50% 미만 또는 후보 0개)
       → "Library에 적합한 에셋이 없습니다. 신규 생성합니다."
       → /game-asset-generate 또는 /generate-image로 전환
       → 생성 후 승인 시 Library 자동 등록 제안

5. 사용/변형 후 _metadata.json 갱신
   → usage_count 증가
   → last_used 날짜 업데이트
   → 변형본은 신규 항목으로 추가

6. Inspector Reference 교차 참조
   → 매칭된 에셋이 UI/연출/이펙트인 경우
   → `docs/references/inspector-reference.md`에서 해당 컴포넌트의 검증된 파라미터 조회
   → 있으면: "검증된 Inspector 값이 있습니다" + 값 표시
   → 없으면: 스킵 (에셋만 반환)
```

## 검색 방법

### 키워드 검색 (기본)
```
/library-search button gold dark-fantasy
→ tags에 "button", "gold", "dark-fantasy"가 포함된 에셋 검색
```

### 트랙 필터링
```
/library-search lightning effect --track game
→ 🎮 게임 트랙에서 "lightning", "effect" 검색
```

### Layer 필터링
```
/library-search --layer L1 --track game
→ 🎮 게임 L1 컴포넌트 전체 목록
```

### 프로젝트 필터링
```
/library-search --project my-game
→ 해당 프로젝트 전용 에셋만 검색
```

## 검색 결과 출력 형식

```markdown
## Library 검색 결과: "{쿼리}"

| # | 매칭 | 에셋명 | Layer | 경로 | 점수 | 태그 |
|:-:|:----:|--------|:-----:|------|:----:|------|
| 1 | 완전 | L1-btn-gold-primary | L1 | game/{project}/components/buttons/ | 4.5 | button, gold, cta |
| 2 | 부분 | L1-btn-stone-primary | L1 | game/_shared/components/buttons/ | 3.8 | button, stone, rpg |
| 3 | — | 매칭 없음 | — | — | — | — |

→ 1번 직접 사용 / 2번 리터치 / 신규 생성 — 선택해주세요.
```

## 카탈로그 브라우징

HTML 카탈로그가 생성되어 있으면 경로를 안내한다:
```
카탈로그: {PREFAB_LIBRARY_PATH}/_catalog/index.html
→ 브라우저에서 열어 시각적으로 탐색할 수 있습니다.
```

## _metadata.json 갱신 규칙

| 이벤트 | 갱신 내용 |
|--------|----------|
| 에셋 직접 사용 | `usage_count++`, `last_used: today` |
| 에셋 리터치 사용 | 원본 `usage_count++` + 변형본 신규 항목 추가 |
| 신규 생성 후 등록 | 새 항목 추가 (`source: "generated"`, `quality_score: {크리틱점수}`) |

## 주의사항

- `_metadata.json`이 없거나 비어있으면 "Library가 비어있습니다" 경고 후 신규 생성으로 전환
- `PREFAB_LIBRARY_PATH` 미설정 시 기본 경로 `~/prefab-visual-library` 시도
- Library가 아예 없으면 이 스킬은 스킵 (game-asset-generate Step 4에서 자동 처리)
- 검색은 대소문자 무시, 부분 매칭 허용 (예: "btn" → "button" 매칭)
