# Art Direction Brief — GodBlade 뽑기 시스템

> 프로젝트의 감성/미적 방향을 정의하는 문서.
> Style Guide(기술적 규격)와 분리하여 크리에이티브 방향을 관리한다.
> Diamond Architecture P1 — GDD + 기획서 + 기존 에셋 기반.

## 1. 감성 키워드 (3개)

| # | 키워드 | 설명 | 레퍼런스 | 프롬프트 키워드 매핑 |
|:-:|--------|------|---------|-------------------|
| 1 | **고대 마법의 신비** | 던전 깊은 곳에서 룬 마법진이 작동하는 순간의 긴장감 | 기존 `gacha-cards-facedown-10slot.png` | `ancient, arcane, mystical glow, rune circles, dim torch light, stone textures, dust particles, sealed chamber` |
| 2 | **화려한 보상감** | 금빛 폭발과 컨페티가 터지는 순간의 카타르시스 | 기존 `gacha-win-acquired-golden-burst.png` | `golden burst, explosive radiance, treasure revealed, confetti particles, triumphant light, warm amber glow` |
| 3 | **운명의 카드** | 뒤집기 전 기대감, 짝이 맞는 순간 번개가 치는 극적 전환 | 기존 `gacha-pair-match-lightning-glow.png` | `fate deciding, lightning arcs, card flip tension, matched pair energy, electric surge, destiny moment` |

## 2. 안티패턴 (하지 말 것)

| # | 안티패턴 | 이유 | 예시 |
|:-:|---------|------|------|
| 1 | **현대적/미니멀 UI** | GodBlade는 고대 판타지 세계관. 깔끔한 플랫 디자인은 세계관 몰입을 파괴 | Material Design 버튼, 깔끔한 카드 UI, 그림자 없는 아이콘 |
| 2 | **밝은/파스텔 컬러** | 던전 깊숙한 곳의 어둡고 신비로운 분위기에 부적합. 밝은 배경은 긴장감을 제거 | 하늘색 배경, 파스텔 핑크, 밝은 그린 UI |
| 3 | **카툰/치비 스타일** | 기존 갓검은 pixel-art RPG 장비 스타일. 과도한 귀여움은 톤 불일치 | 둥근 눈 캐릭터, SD 비율, 카툰 이펙트 |
| 4 | **과도한 네온/사이버펑크** | 중세 판타지 세계관과 불일치. 시안 룬은 '고대 마법'이지 '사이버' 아님 | 네온 핑크, 홀로그램, 글리치 효과 |
| 5 | **스톡 포토/AI 생성 티** | 게임 에셋은 핸드크래프트 느낌 필수. AI 생성의 매끄러운 플라스틱 질감 배제 | 과도하게 매끄러운 그라디언트, 변형된 손가락 |

> AI 이미지 생성 시 위 안티패턴이 감지되면 즉시 재생성한다.
> 안티패턴 라이브러리: `09-tools/templates/ai-anti-patterns.md` 참조

## 3. 무드보드 레퍼런스 (비경쟁 도메인)

> **규칙**: 동일 장르 경쟁작(모바일 가챠 게임)은 제외. 비경쟁 도메인에서 영감을 가져온다.

| # | 레퍼런스 | 도메인 | 참조 요소 | 비고 |
|:-:|---------|--------|----------|------|
| 1 | **The Witcher 3 — Gwent 카드 UI** | AAA RPG (PC/콘솔) | 금 테두리 카드 디자인, 어두운 테이블 위 카드 배치, 중세 분위기 | 카드 뒷면 장식 패턴 참조 |
| 2 | **Harry Potter — 마법 서적 UI** | 판타지 영화 | 고대 룬 문자 장식, 어두운 도서관 조명, 마법 발동 시 빛줄기 | 룬 마법진 + 빛 연출 참조 |
| 3 | **Diablo IV — 인벤토리 UI** | AAA ARPG | 어두운 석재 배경, 금속 테두리, 아이템 등급별 글로우, 고딕 장식 | 등급 컬러 시스템 + UI 톤 참조 |
| 4 | **타로 카드 일러스트레이션** | 전통 점술/아트 | 신비로운 뒷면 패턴, 뒤집는 순간의 기대감, 금박 장식 | 카드 뒤집기 연출 감성 참조 |
| 5 | **중세 연금술 서적 삽화** | 역사/아트 | 고대 문양, 원형 다이어그램(마법진), 양피지 질감, 금 잉크 | 룬 서클 + 제단 장식 참조 |

### 앵커 이미지 (Anchor Images)

> P2 프로토타입에서 승인된 에셋 중 GodBlade 스타일을 가장 잘 대표하는 3장.
> Gemini 프롬프트에 참조 이미지로 첨부하여 스타일 일관성 향상.

| # | 앵커 이미지 | 대표 요소 | 경로 |
|:-:|-----------|----------|------|
| 1 | 상자 개봉 연출 | 던전 배경 + 금빛 폭발 + 석재 제단 | `02-product/projects/godblade/_assets/p2-01-chest-opening.png` |
| 2 | 카드 그리드 배치 | 10장 카드 + 시안 룬 마법진 + 횃불 조명 | `02-product/projects/godblade/_assets/p2-02-card-grid.png` |
| 3 | 짝 맞추기 번개 | 번개 이펙트 + 금 글로우 + 다크 배경 | `02-product/projects/godblade/_assets/p2-03-pair-match.png` |

## 4. 차별화 포인트

### 경쟁작 대비 시각적 차별화

| 경쟁작 유형 | 그들의 스타일 | 우리의 차별점 |
|-----------|-------------|-------------|
| 일반 모바일 가챠 | 밝고 화려한 애니풍, 전체 화면 3D 연출 | **던전 몰입형**: 어둡고 신비로운 돌 제단 위에서 진행 |
| 하이엔드 가챠 (원신 등) | 3D 캐릭터 풀스크린 연출, 과도한 파티클 | **카드 기반 2D**: 10장 그리드 + 짝 맞추기 퍼즐 요소 |
| 레트로 RPG 가챠 | 단순 슬롯머신/리스트 결과 | **연출 레이어링**: 상자 개봉 → 카드 뒤집기 → 짝 맞추기 → 결과 4단계 |

### 핵심 시각 차별 요소
- **석재 제단 + 룬 마법진**: 뽑기 행위가 "고대 마법 의식"으로 포장
- **10장 카드 그리드**: 결과를 한눈에 보면서 짝을 찾는 탐색 재미
- **등급별 번개/글로우 차등**: 짝이 맞는 순간 등급에 따라 극적으로 다른 이펙트
- **꽝도 연출 있음**: 연기+폭발+"다음 기회에" 텍스트로 꽝에도 감성 부여

## 5. 타겟 사용자 감성 프로파일

| 항목 | 정의 |
|------|------|
| 연령대 | 25-40 (중세 RPG/ARPG 세대) |
| 감성 선호 | 어둡고 묵직한 판타지, 아이템 수집의 도파민, 점진적 보상 기대감 |
| 기피 요소 | 유치한 카툰풍, 과도한 네온, 노골적 과금 유도 UI |
| 참조 브랜드/게임 | Diablo 시리즈, Path of Exile, The Witcher, 클래식 한국 RPG |

## 5.5 디자인 철학 선언문 (Design Philosophy Statement)

> GodBlade 뽑기 시스템의 시각적 "영혼"을 정의하는 선언문.

### 선언문

> "GodBlade 뽑기 시스템은 '고대 던전에서 발견한 봉인된 상자'의 경험이다.
> 플레이어는 모험가이고, 뽑기는 보물 발굴이며, 모든 결과는 운명의 선택이다.
> 화려함이 아니라 **경외감**을 추구한다 — 어둠 속에서 빛이 의미를 가지듯."

### 핵심 3원칙

| # | 원칙 | 설명 |
|:-:|------|------|
| 1 | **어둠이 있어야 빛이 빛난다** | 배경이 어두울수록 이펙트가 강렬. Dark Navy #1A1A2E가 기본, 빛은 Gold/Cyan만 |
| 2 | **고대의 무게감** | 석재, 금속, 룬 — 가벼운 것은 없다. 모든 표면에 시간의 흔적 |
| 3 | **운명의 순간** | 모든 화면은 "결정적 순간 직전"의 긴장감. 정적이 아닌 "곧 일어날 일"의 암시 |

### 물성 키워드 사전 (Layer 3)

| 카테고리 | 키워드 | 효과 |
|---------|--------|------|
| 석재 질감 | `weathered stone texture, ancient cracks, moss traces` | 시간의 흔적, 역사감 |
| 금속 마모 | `tarnished gold, oxidized bronze, battle-worn edges` | 사용감, 진품 느낌 |
| 먼지/입자 | `dust motes in light beams, floating particles, ancient debris` | 공간의 깊이, 시간 |
| 불꽃 떨림 | `flickering torch light, uneven flame, dancing shadows` | 살아있는 느낌 |
| 잉크/마법 | `ink-like magical trails, bleeding rune glow, imperfect circles` | 손으로 그린 마법진 |
| 종이/양피지 | `parchment edges, burnt paper texture, aged vellum` | 고문서 느낌 |

## 6. 씬 구성 가이드

### 뽑기 전용 씬 (GDD 8.1)

```
+------------------------------------------------------+
|  [어두운 던전 배경 — 석재 벽, 아치 통로]                    |
|                                                      |
|  [횃불]                                   [횃불]       |
|     🔥                                      🔥       |
|                                                      |
|              [카드 10장 / 상자 영역]                     |
|              [  □□□□□  ]                              |
|              [  □□□□□  ]                              |
|                                                      |
|         [석재 제단 + 시안 룬 마법진 ◯ ]                   |
|                                                      |
|              [CTA 버튼 — 금 테두리]                     |
+------------------------------------------------------+
```

- 중앙: 석재 제단이 화면의 시각적 앵커
- 좌우: 파란 횃불이 앰비언트 조명 제공
- 상단: 상태 텍스트 (금색 대형 폰트)
- 하단: CTA 버튼 (금 테두리 다크 패널)

## 7. 참조 이미지 사용 프로토콜

### 앵커 이미지 vs 생성 이미지

| 구분 | 앵커 이미지 (Reference) | 생성 이미지 (Generated) |
|------|----------------------|----------------------|
| 역할 | GodBlade 스타일 기준점 | 신규 에셋 |
| 출처 | P2 승인 에셋 3장 (§3 앵커) | MCP 도구 생성 |
| 사용법 | Gemini에 "style matching [앵커]" 첨부 | 프로젝트 에셋으로 배치 |
| 수정 | 절대 수정 금지 | 피드백 반영 수정 가능 |

### 활용 흐름

1. 에셋 생성 요청 → 가장 유사한 앵커 이미지 선택
2. Gemini 프롬프트에 앵커 첨부: "style matching the attached reference"
3. 생성 결과를 앵커와 비교 → /asset-critic으로 일관성 검증
4. 크리틱 평균 4.5+ → 앵커 후보로 추가 검토

## 8. 의도적 긴장 규칙 (Intentional Tension)

> GodBlade에 적용하는 핵심 긴장 기법 3가지.

| 긴장 기법 | GodBlade 적용 | 프롬프트 키워드 |
|----------|-------------|---------------|
| **빈 공간의 힘** | 제단 주변의 넓은 어둠 → 고독과 경외감 | `vast darkness surrounding the altar, isolation amplifying presence` |
| **질감 대비** | 반짝이는 금 장식 vs 거친 석재 표면 | `gleaming gold ornaments against rough weathered stone` |
| **빛의 방향 교란** | 지하인데 위에서 한 줄기 빛 → 신비 | `unexpected light beam from above in underground chamber` |

---

*저장 경로: `05-design/projects/godblade/art-direction-brief.md`*
*최초 작성: 2026-03-17*
*최종 수정: 2026-03-18*
*Style Guide 연동: `05-design/projects/godblade/style-guide.md`*
