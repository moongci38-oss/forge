# 영상 레퍼런스 분석

**원본**: `https://www.youtube.com/watch?v=KKBDO5K8QdA`
**분석일**: 2026-03-15
**프롬프트**: 다음 게임 영상은 카드 뽑기/가챠 연출 레퍼런스입니다. 상세히 분석해주세요:

1. **타임스탬프별 연출 분석**: 각 연출 단계(상자 등장, 카드 배치, 카드 뒤집기, 짝 맞추기, 결과 표시)의 시작/종료 시간, 지속 시간
2. **카드 플립 애니메이션**: 카드가 뒤집히는 각도, 속도, 이징, 중간점에서의 스프라이트 교체 타이밍
3. **이펙트 분석**: 파티클(색상, 크기, 방향), 글로우, 번개, 화면 플래시 등 각 이펙트의 파라미터
4. **등급별 연출 차이**: 등급(별/성급)에 따른 이펙트 색상, 강도, 연출 길이 차이
5. **짝 맞추기 연출**: 동일 아이템 발견 시 강조 연출(번개, 글로우, 카드 회전)의 시퀀스
6. **UI 요소**: 버튼 배치, 카드 그리드 레이아웃, 텍스트 표시 타이밍
7. **사운드 힌트**: 영상에서 추정되는 사운드 이벤트 타이밍 (시각적 단서 기반)

출력 형식:
| 시간 | 연출 설명 | 이펙트 요소 | Unity 구현 가이드 (NGUI + UITweener 기준) |

주의: 이 프로젝트는 Unity 2019.4 + NGUI를 사용합니다. DOTween은 사용하지 않으며 UITweener 기반으로 구현 가이드를 작성해주세요.

---

이 게임 영상의 카드 뽑기/가챠 연출을 NGUI + UITweener 기준으로 상세히 분석합니다.

---

### 게임 영상 카드 뽑기/가챠 연출 분석 (Unity 2019.4, NGUI + UITweener 기준)

| 시간 | 연출 설명 | 이펙트 요소 | Unity 구현 가이드 (NGUI + UITweener 기준) |
| :--- | :-------- | :---------- | :---------------------------------------- |
| 0:03 - 0:07 | **상점 UI 진입 및 선택**<br>장비 상점 UI가 표시되고, "보석 장비 상자 10개" 버튼을 선택합니다. | N/A | **UI 활성화/비활성화:**<br> `GameObject.SetActive(false)` 로 기존 UI 비활성화.<br> `GameObject.SetActive(true)` 로 상점 UI 활성화.<br> `UIButton` 클릭 이벤트에 상자 구매 로직 연결. |
| 0:07 - 0:10 | **캐릭터 선택 팝업**<br>상자 개봉 시 아이템을 귀속할 캐릭터를 선택하는 팝업이 나타납니다. | N/A | **캐릭터 선택 팝업:**<br> `UIPanel`로 구성된 팝업 `GameObject` 활성화.<br> `TweenAlpha`로 서서히 나타나도록 (0.8초, Linear).<br> `UILabel`과 `UISprite`로 캐릭터 정보 및 다이아몬드 가격 표시.<br> `UIButton` 컴포넌트 추가.<br> 캐릭터 선택 시 팝업 `TweenAlpha`로 서서히 사라지도록 (0.5초, EaseOutCubic), 이후 다음 연출 트리거. |
| 0:10 - 0:12 | **상자 등장 및 개봉 (표준)**<br>어두운 배경에서 보석 상자가 중앙으로 줌인됩니다. 상자 중앙의 보석이 빛나며, 푸른 광선이 사방으로 퍼지고 상자가 열립니다. 강렬한 플래시 효과가 동반됩니다. | **이펙트:**<br> - 상자 줌인: `TweenScale`, `TweenPosition`<br> - 보석 광원: `UISprite` (Radial Gradient), `TweenAlpha`, `TweenScale`<br> - 사방으로 퍼지는 광선: `UISprite` (linear sprite), `TweenScale` (X/Y), `TweenAlpha`<br> - 화면 플래시: `UIImage` (fullscreen, white), `TweenAlpha` (0 -> 1 -> 0, very fast)<br> - 상자 개봉 시 빛줄기: `ParticleSystem` (blue, upward)<br> - 배경: Darkness `UISprite` (black, full screen) `TweenAlpha` | **Unity 구현 (표준 상자):**<br> 1. **배경:** 검은색 `UISprite` (FullScreen)를 `TweenAlpha` (0 -> 1, 0.5초, EaseOutCubic)로 페이드인.<br> 2. **상자 등장:** 상자 `GameObject` (3D 모델 또는 `UISprite` 시퀀스)를 중앙으로 `TweenScale` (1 -> 1.2, 0.5초, EaseOutCubic) 및 `TweenPosition`으로 줌인.<br> 3. **보석 광원:** 상자 위에 위치한 `UISprite` (푸른색 원형 그라데이션)에 `TweenAlpha` (0 -> 1, 0.3초) 및 `TweenScale` (1 -> 1.5, 0.3초) 적용. 동시에 `ParticleSystem` (푸른색 작은 스파클) 재생.<br> 4. **광선:** `UISprite` (푸른색 가늘고 긴 광선)를 여러 개 생성, 상자 중앙에서 바깥으로 `TweenScale` 및 `TweenAlpha` (0.3초)로 짧게 발사.<br> 5. **상자 개봉:** 상자 애니메이션 재생 (뚜껑 열리는 애니클립 또는 스프라이트 시퀀스).<br> 6. **화면 플래시:** 흰색 `UIImage` (FullScreen)에 `TweenAlpha` (0 -> 1 -> 0, 0.1초) 적용. (`CameraShake` 스크립트를 통해 카메라 `TweenPosition` 흔들림 0.05초).<br> 7. **카드 분출 준비:** 상자 내부에서 `ParticleSystem` (푸른색/보라색 작은 스파클) 재생. |
| 0:12 - 0:15 | **카드 분출 및 바닥에 착지**<br>상자에서 카드 10장이 튀어나와 하늘로 흩뿌려진 후, 한 장이 상자 위에 떠오릅니다. | **이펙트:**<br> - 카드 분출: `UISprite` (카드 뒷면), `TweenPosition`, `TweenRotation`, `TweenAlpha`<br> - 잔여 파티클: `ParticleSystem` (blue/purple, upward trail)<br> - 상자 안쪽 베이스: 빨간색 벨벳 질감<br> - 상자 상단 카드: `UISprite` (카드 뒷면), `TweenPosition`, `TweenScale`, `TweenRotation` (작은 좌우 흔들림) | **Unity 구현:**<br> 1. **카드 분출:** 미리 준비된 카드 뒷면 `UISprite` 프리팹 10개 인스턴스화. 각 카드에 `TweenPosition` (상자 위로 -> 랜덤한 위치로 흩뿌리기) 및 `TweenRotation` (랜덤한 회전) 적용.<br> 2. **잔여 파티클:** 카드 분출 경로를 따라 `ParticleSystem` (푸른색/보라색, 짧은 수명) 재생.<br> 3. **상자 위 카드:** 상자 위로 떠오르는 카드 `UISprite` 하나를 `TweenPosition` (상자 바닥 -> 상자 위) 및 `TweenScale` (작게 -> 원래 크기)로 애니메이션. `TweenRotation`으로 약간의 흔들림 효과 추가.<br> 4. **상자 페이드 아웃:** 상자 `GameObject` (3D 모델 또는 `UISprite` 시퀀스)를 `TweenAlpha` (1 -> 0, 0.5초, EaseOutCubic)로 페이드 아웃. |
| 0:15 - 0:17 | **카드 그리드 배치 및 순차적 뒤집기**<br>10개의 카드 뒷면이 2x5 그리드로 자동 정렬되고, 좌측 상단부터 순차적으로 뒤집힙니다. 뒤집히기 전 카드는 잠시 강조됩니다. | **이펙트:**<br> - 그리드 정렬: `TweenPosition`<br> - 카드 테두리 강조: `UISprite` (highlight frame), `TweenAlpha`<br> - 카드 플립: `TweenRotation`<br> - 등급별 플립 파티클: `ParticleSystem` (green, blue, purple, red, gold) | **Unity 구현:**<br> 1. **카드 그리드 배치:** 분출된 카드 `UISprite`들을 미리 설정된 `UIGrid` 컨테이너 내의 위치로 `TweenPosition` (1초, EaseOutQuart) 애니메이션.<br> 2. **카드 강조 및 플립 (순차):**<br>    - **순차 처리:** `Coroutine` 또는 `EventDelegate` 체인을 사용하여 카드 한 장씩 처리.<br>    - **강조:** 각 카드의 자식으로 `UISprite` (푸른색 테두리)를 추가, `TweenAlpha` (0 -> 1 -> 0, 0.2초)로 깜빡임 강조.<br>    - **플립:** 카드의 `UISprite`에 `TweenRotation` (Y축: 0 -> 180, 0.3초, EaseInOutSine) 적용.<br>    - **스프라이트 교체:** `TweenRotation`의 `onFinished` `EventDelegate`를 사용하여 Y축 회전이 90도가 되는 중간 지점 (0.15초)에 `UISprite.spriteName`을 카드 뒷면에서 앞면으로 변경.<br>    - **등급별 이펙트:** 카드의 등급에 따라 다른 색상의 `ParticleSystem` (작은 스파클)을 카드의 `GameObject`에 추가하여 플립 시 재생. (예: 초록색/일반, 파란색/희귀, 보라색/영웅, 빨간색/전설, 금색/신화). `UISprite`의 테두리 색상도 등급에 따라 변경.<br> 3. **모두 뒤집힘:** 마지막 카드 플립 완료 후 다음 단계로 진행. |
| 0:17 - 0:20 | **획득 결과 표시 및 UI 버튼**<br>모든 카드가 뒤집힌 후, "한번 더" 및 "확인" 버튼이 나타납니다. | N/A | **Unity 구현:**<br> `UIButton` (확인, 한번 더) `GameObject`를 `TweenAlpha` (0 -> 1, 0.3초, EaseOutCubic)로 페이드인.<br> "확인" 버튼 클릭 시 다음 연출로 이동. |
| 0:20 - 0:22 | **개별 아이템 획득 팝업 (1차)**<br>획득한 아이템 중 하나(가장 높은 등급 추정)의 정보와 스탯 증가량이 표시됩니다. | **이펙트:**<br> - 획득 아이템 강조: 해당 아이템 카드 주변에 지속적인 글로우, 작은 파티클<br> - 스탯 증가 텍스트: `UILabel`, `TweenPosition` (위로), `TweenAlpha` (페이드아웃) | **Unity 구현:**<br> 1. **팝업 활성화:** `UIPanel`로 구성된 아이템 획득 팝업 `GameObject`를 활성화.<br> 2. **정보 표시:** `UISprite` (아이템 이미지), `UILabel` (아이템 이름, 등급, 레벨, 스탯 증가량) 설정.<br> 3. **강조 이펙트:** 팝업 아이템 `UISprite` 주변에 `UISprite` (글로우)를 추가하고 `TweenAlpha`로 지속적인 깜빡임 효과 (0.5초, Loop PingPong). `ParticleSystem` (아이템 등급 색상) 재생.<br> 4. **스탯 증가 텍스트:** `UILabel`에 스탯 증가량 표시 후, `TweenPosition` (0.5초, EaseOutCubic, Y값 증가) 및 `TweenAlpha` (0.5초, 1 -> 0, EaseOutCubic)로 위로 사라지도록 애니메이션.<br> 5. "장착" `UIButton` 추가. 클릭 시 특정 로직 실행 후 팝업 닫기 (`TweenAlpha`로 페이드아웃). |
| 0:22 - 0:23 | **전투력 증가 UI**<br>메인 화면 상단에 전투력 증가 수치가 잠시 표시됩니다. | **이펙트:**<br> - 전투력 텍스트: `UILabel` (green color), `TweenPosition` (위로), `TweenAlpha` (페이드아웃) | **Unity 구현:**<br> `UILabel` 프리팹 (전투력 증가량 텍스트, 초록색)을 인스턴스화하여 화면 상단 (캐릭터 정보 UI 근처)에 생성.<br> `TweenPosition` (0.8초, EaseOutCubic, Y값 증가) 및 `TweenAlpha` (0.8초, 1 -> 0, EaseOutCubic)를 적용하여 위로 사라지도록 애니메이션.<br> 애니메이션 완료 시 `GameObject.Destroy()` 또는 오브젝트 풀 반환. |
| 0:23 - 0:29 | **상자 등장 및 개봉 (높은 등급 - 스페셜)**<br>두 번째 개봉에서는 상자의 문양이 바뀌고, 더 강렬한 빛과 플래시, 폭발적인 효과가 동반됩니다. 상자 개봉 시 흔들림이 더 두드러집니다. | **이펙트:**<br> - 보석 문양 변경: `UISprite` (snowflake icon)<br> - 광원/플래시 강화: 더 밝은 `TweenAlpha` 값, 더 긴 `TweenScale` 지속 시간.<br> - 렌즈 플레어: `UISprite` (Lens Flare Texture) `TweenAlpha` 및 `TweenScale`<br> - 화면 흔들림: `CameraShake` 스크립트 강도 증가.<br> - 카드 분출 강화: 더 많은 `ParticleSystem` (white/blue/gold, larger, faster) | **Unity 구현 (스페셜 상자):**<br> 1. **보석 문양:** 상자 중앙의 `UISprite` (보석)를 스노플레이크 문양의 스프라이트로 교체.<br> 2. **광원/플래시:** 표준 상자보다 `TweenAlpha`의 최대값을 높이고 (예: 0.8 -> 1), `TweenScale` 속도를 빠르게 하여 더 강렬한 인상.<br> 3. **렌즈 플레어:** `UISprite` (렌즈 플레어 텍스처)를 FullScreen으로 추가하고 `TweenAlpha` (0 -> 1 -> 0) 및 `TweenScale` (작게 -> 크게)로 강조.<br> 4. **화면 흔들림:** `CameraShake` 스크립트의 강도 파라미터를 증가시켜 더 격렬한 화면 흔들림 효과 (`TweenPosition` 진폭 증가, 지속 시간 증가).<br> 5. **카드 분출:** `ParticleSystem` (하얀색/푸른색/금색)의 개수, 크기, 속도를 증가시켜 더 화려한 연출. `TweenPosition`, `TweenRotation` 속도도 증가. |
| 0:29 - 0:32 | **카드 그리드 배치 및 순차적 뒤집기 (높은 등급 포함)**<br>표준과 동일하게 그리드 배치 후 순차적으로 뒤집히며, 높은 등급의 카드는 더욱 화려한 색상과 파티클 효과를 보여줍니다. | **이펙트:**<br> - 등급별 플립 파티클 강화: 빨간색, 금색 등 높은 등급 카드 플립 시 파티클의 크기, 개수, 밝기가 더욱 증가.<br> - 테두리 글로우: 등급별 테두리 색상과 함께 `UISprite` (글로우)가 더욱 선명하고 밝게 강조. | **Unity 구현:**<br> **카드 강조 및 플립 (순차):**<br> - 표준과 동일한 로직을 사용하되, 카드 등급에 따라 `ParticleSystem`의 파라미터 (StartSize, StartColor, EmissionRate, Duration 등)를 조절하여 높은 등급일수록 파티클 효과를 강화.<br> - 카드의 테두리 `UISprite`의 `TweenAlpha` (깜빡임) 및 `TweenColor` (등급 색상)를 사용하여 시각적 강조. |
| 0:32 - 0:38 | **아이템 짝 맞추기 연출**<br>동일한 아이템 두 개가 나타났을 때, 두 카드가 동시에 번개 효과와 함께 강조되어 빛나고 미세하게 진동합니다. | **이펙트:**<br> - 번개: `UISprite` (lightning texture), `TweenAlpha` (0 -> 1 -> 0, very fast)<br> - 카드 강조/진동: `UISprite` (글로우), `TweenScale` (loop, subtle 1 -> 1.02 -> 1), `TweenAlpha` (loop, brighter) | **Unity 구현:**<br> 1. **짝 맞추기 감지:** 카드 플립 완료 후, 아이템 목록을 스캔하여 동일 아이템이 2개 이상 있는지 확인.<br> 2. **번개 효과:** 감지된 각 카드 위에 `UISprite` (번개 텍스처)를 `GameObject`로 생성. `TweenAlpha` (0 -> 1 -> 0, 0.1초)를 빠르게 적용하여 번쩍이는 효과. `EventDelegate`로 완료 시 `GameObject.Destroy()`.<br> 3. **카드 강조/진동:**<br>    - 해당 카드의 테두리 `UISprite`에 `TweenAlpha` (지속적인 깜빡임, Loop PingPong)를 강하게 적용하여 글로우 강화.<br>    - 해당 카드 `GameObject`에 `TweenScale` (1 -> 1.02 -> 1, 0.2초, Loop PingPong)를 적용하여 미세한 진동 효과.<br>    - 이펙트는 일정 시간 (예: 3-4초) 지속 후 종료되거나, "확인" 버튼 클릭 시 즉시 종료.<br> 4. "확인" 버튼 클릭 시 다음 연출로 이동. |
| 0:39 - 0:41 | **개별 아이템 획득 팝업 (2차)**<br>이전과 동일하게 개별 아이템 획득 팝업이 순차적으로 표시됩니다. | **이펙트:**<br> - 획득 아이템 강조: 등급에 따른 글로우/파티클 색상 및 강도 유지.<br> - 스탯 증가 텍스트: `UILabel`, `TweenPosition`, `TweenAlpha`. | **Unity 구현:**<br> 1. 이전 개별 아이템 획득 팝업과 동일한 로직.<br> 2. 여러 아이템이 있을 경우, `Coroutine`을 사용하여 순차적으로 팝업을 띄우고 사용자가 "장착" 또는 "X" 버튼을 누르거나 일정 시간이 경과하면 다음 아이템 팝업으로 전환. |
| 0:41 - 0:42 | **전투력 증가 UI**<br>이전과 동일하게 전투력 증가 수치가 표시됩니다. | **이펙트:**<br> - 전투력 텍스트: `UILabel`, `TweenPosition`, `TweenAlpha`. | **Unity 구현:**<br> 이전 전투력 증가 UI와 동일한 로직. |
| 1:12 - 1:13 | **보상 획득 팝업**<br>특정 조건 달성 시 추가 보상 팝업이 나타납니다. | N/A | **Unity 구현:**<br> `UIPanel`로 구성된 팝업 `GameObject` 활성화.<br> `UISprite` (아이템 이미지), `UILabel` (아이템 개수) 표시.<br> "수령" `UIButton` 클릭 시 보상 획득 처리 로직.<br> 팝업 닫기 (`TweenAlpha`로 페이드아웃). |
| 1:13 - 1:14 | **알림 메시지 (토스트 팝업)**<br>"보상이 우편함으로 전송되었습니다." 라는 토스트 메시지가 잠시 표시됩니다. | N/A | **Unity 구현:**<br> `UILabel` 프리팹을 화면 중앙 하단에 인스턴스화.<br> `TweenPosition` (0.2초, EaseOutCubic, 약간 위로) 및 `TweenAlpha` (1초, 1 -> 0, EaseOutCubic) 적용하여 나타난 후 서서히 사라지도록 애니메이션.<br> 애니메이션 완료 시 `GameObject.Destroy()` 또는 오브젝트 풀 반환. |

---

#### 사운드 힌트 분석 (시각적 단서 기반)

*   **0:07, 0:09, 0:20, 0:38, 0:54, 1:08, 1:09, 1:12**: UI 버튼 클릭/선택음 (일반적인 `UI_Click_01` 같은 짧은 효과음).
*   **0:10, 0:24, 0:43, 0:58, 1:05**: 상자 중앙 보석 충전/강조음 (짧은 전자음 또는 차징 사운드 `Gacha_Charge_01`).
*   **0:11, 0:25, 0:44, 0:59, 1:05**: 상자 개봉 시 플래시/폭발음 (웅장한 폭발음 또는 보석 깨지는 소리 `Gacha_Explosion_01`).
*   **0:12, 0:26, 0:45, 1:00, 1:05**: 카드 분출음 (카드가 흩날리는 `Card_Scatter_01` 또는 공중을 가르는 `Whoosh_01` 효과음).
*   **0:13, 0:28, 0:47, 1:02**: 상자 개봉 완료 후 잔향음 (은은한 종소리 또는 잔향 `Gacha_Ambience_01`).
*   **0:15, 0:30, 0:49, 1:04**: 카드 그리드에 착지하는 소리 (짧고 날카로운 `Card_Place_01` 또는 `Click_02` 효과음).
*   **0:16, 0:30~0:31, 0:49~0:50, 1:04~1:05**: 개별 카드 플립 소리 (짧은 `Card_Flip_01` 또는 `Whoosh_02` 효과음). 등급별로 미묘하게 다른 음색이나 강조음을 줄 수 있음 (예: 높은 등급은 더 웅장하게).
*   **0:20, 0:39, 0:55, 1:08, 1:09**: 아이템 획득 팝업 등장 시 긍정적인 효과음 (성공적인 획득을 알리는 `Item_Acquire_Fanfare_01`).
*   **0:22, 0:41, 0:57, 1:10**: 전투력 증가 UI 등장 시 짧은 긍정 효과음 (`Stat_Up_01`).
*   **0:34**: 짝 맞추기 번개 효과음 (강렬한 전기 스파크 `Lightning_01` 또는 `Zap_01`).
*   **1:13**: 토스트 메시지 알림음 (작고 부드러운 `Notification_Pop_01`).

---

이 분석은 영상의 시각적 요소를 기반으로 NGUI와 UITweener의 기능을 최대한 활용하여 구현 가이드를 제시했습니다. 실제 개발 시에는 각 이펙트의 세부 파라미터(색상, 지속 시간, 이징 곡선 등)를 더욱 정교하게 조절하여 완성도를 높여야 합니다.
