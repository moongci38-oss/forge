# 클로드(claude)로 hwpx(한글) 한방에 채우기 | 이제 복잡한 보고서도 5분 컷!(클로드 스킬 무료 제공)
> 김용성 교수의 AI 클래스 | 조회수 29.0K | 5분 09초
> 원본: https://youtu.be/tt50miJGquE
> 자막: 자동생성 (신뢰도 Medium)

## TL;DR
Claude.ai Web의 스킬 커넥터 기능으로 HWPX(한컴 한글) 파일을 자동 생성하는 워크플로우 소개. 사전 제작된 스킬 파일(.json)을 업로드하면 AI가 보고서/공문을 HWP 형식으로 즉시 출력할 수 있다.

## 카테고리
productivity | #hwpx #claude스킬 #한글자동화 #보고서자동화

## 핵심 포인트
1. **Claude.ai 스킬 커넥터로 HWPX 생성** [🕐 00:14](https://youtu.be/tt50miJGquE?t=14) — Claude 무료 요금제에서도 동작, 유료 시 Opus 모델 사용 가능
2. **스킬 파일 업로드 방식** [🕐 01:57](https://youtu.be/tt50miJGquE?t=117) — 사이드바 > 사용자 지정 > 스킬 > + 버튼 > 스킬 업로드 순서
3. **공문·기한문·자동채우기 스킬 포함** [🕐 02:15](https://youtu.be/tt50miJGquE?t=135) — 배포되는 스킬 파일에 세 가지 문서 유형 내장
4. **HWPX 미리보기 불가, 다운로드 필수** [🕐 02:58](https://youtu.be/tt50miJGquE?t=178) — Claude UI에서 HWPX 렌더링 지원 없음
5. **실제 결과물 품질** [🕐 03:18](https://youtu.be/tt50miJGquE?t=198) — 목차·본문·향후계획 자동 생성, 페이지 수 지시는 부정확(5p 요청 → 4p 생성)
6. **입력 자료가 품질 결정** [🕐 04:27](https://youtu.be/tt50miJGquE?t=267) — PDF나 HWP 형태의 참조 자료를 함께 첨부하면 훨씬 풍부한 결과물 출력

## 비판적 분석

### 주장 1: "클로드 스킬을 활용하면 HWP 보고서도 5분 컷"
- **제시된 근거**: 실시간 시연 — 스킬 업로드 후 보고서 생성까지 약 3분 소요
- **근거 유형**: 경험 (단일 사례 시연)
- **한계**: 입력 자료 없이 AI가 내용을 창작한 보고서. 실무에서 사용 가능한 품질인지 검증 안 됨. 페이지 수 제어 실패도 노출됨.
- **반론/대안**: HWPX MCP 서버(airmang/hwpx-mcp-server)나 easy-hwp 스킬은 실제 참조 파일을 매핑하여 더 정밀한 서식 제어 가능

### 주장 2: "무료 요금제에서도 가능"
- **제시된 근거**: 직접 무료 계정으로 시연
- **근거 유형**: 실증
- **한계**: 무료 플랜은 일일 사용 횟수 제한 존재 (영상에서도 인정). 반복 수정 작업 시 한계
- **반론/대안**: 실무 활용은 Pro 이상 권장

### 주장 3: "스킬 첨부만으로 HWP 출력물 생성"
- **제시된 근거**: 시연에서 HWPX 다운로드 성공
- **근거 유형**: 실증
- **한계**: 스킬의 내부 구조(XML 생성 로직)를 공개하지 않아 재현성 검증 불가. 복잡한 서식(표, 이미지, 각주)은 다루지 않음
- **반론/대안**: Python hwpx 라이브러리 직접 활용 시 더 세밀한 서식 제어 가능

## 팩트체크 대상
- **주장**: "Claude 무료 요금제에서도 HWPX 스킬 동작" | **검증 필요 이유**: 스킬 커넥터 기능이 무료 플랜에서 실제 지원되는지 공식 확인 필요 | **검증 방법**: Anthropic 공식 문서 플랜별 기능 비교
- **주장**: "HWP로 된 형태의 파일도 걱정 없이 출력물로 활용 가능" | **검증 필요 이유**: .hwp(바이너리)와 .hwpx(XML 기반) 구분 — 실제로 hwpx만 지원 | **검증 방법**: 출력 파일 확장자 및 스킬 설명 확인
- **주장**: "5페이지 요청에 4페이지 생성 → 지속 요청으로 수정 가능" | **검증 필요 이유**: 페이지 수 제어가 실제로 재요청으로 해결되는지 | **검증 방법**: 반복 프롬프트 실험

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | 무료 요금제에서 스킬 커넥터 동작 | ⚠️ 부분 확인 | Claude.ai 무료 플랜은 스킬 커넥터 지원하나 일일 횟수 제한 존재. 고급 모델(Opus) 미지원 |
| 2 | HWP/HWPX 구분 없이 출력 가능 | ⚠️ 부분 확인 | 출력은 .hwpx(XML 기반)만 가능. 구형 .hwp(바이너리) 형식은 별도 변환 필요 |
| 3 | 재요청으로 페이지 수 조정 가능 | ❓ 미검증 | 이론적으로 가능하나 HWPX의 페이지 레이아웃 특성상 AI의 정확한 제어 어려움. 실증 없음 |

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| HWPX 스킬 생태계 | [easy-hwp (GitHub)](https://github.com/nathankim0/easy-hwp) | Claude Code 스킬로 .hwpx 분석+자동 작성. /hwp-analyze, /hwp-fill 명령 제공. 표 구조 기반 매핑 | 보완 |
| HWPX MCP 서버 | [hwpx-mcp-server (GitHub)](https://github.com/airmang/hwpx-mcp-server) | `uvx hwpx-mcp-server` 설치. Claude Desktop에서 직접 HWPX 읽기/편집/변환 지원. Python 3.10+ | 보완 |
| 공개 스킬 배포 사례 | [gonggong_hwpxskills (GitHub)](https://github.com/Canine89/gonggong_hwpxskills) | 공공 문서용 HWPX 스킬 무료 배포. 양식 교체 기능 포함 | 일치 |
| Claude Code HWPX | [mcpmarket.com](https://mcpmarket.com/tools/skills/hwp-hwpx-document-editor) | hwpilot: 외부 변환 없이 HWP/HWPX 직접 편집, 계층형 참조 시스템으로 섹션/표/이미지 지정 가능 | 보완 |

## GTC 검증 결과 (시스템 현황)

**GTC-1 관련성 필터:**
- 우리 시스템에 `hwp2pdf` 스킬 존재 → HWP→PDF 변환(읽기 전용)
- 영상의 접근법은 Claude.ai Web 스킬 커넥터 → **우리 환경(Claude Code CLI)과 다른 채널**
- HWPX MCP 서버(airmang/hwpx-mcp-server): Forge MCP 미설치

**GTC-2 기구현 확인:**
- `hwp2pdf`: HWP 읽기/PDF 변환 → 영상 주제인 HWPX 생성(쓰기)과 다름
- 정부과제 파이프라인(`/grants`)에서 HWPX 출력 기능 없음

**GTC-4 영향도 검증:**
- 현재 정부과제(KOCCA) 작업 시 HWP 제출 필요 → 잠재적 blocking
- 그러나 현재 Word/PDF 제출로 우회 중 → 즉각 장애 없음

## 시스템 비교 분석

| 제안/발견 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|:--:|:----:|:----:|
| HWPX 파일 생성(쓰기) | hwp2pdf 스킬(읽기만 가능) | 쓰기 파이프라인 전무 | M | M |
| Claude Code에서 HWPX 직접 편집 | 미적용 | hwpx-mcp-server 미설치 | M | L |
| 정부과제 HWPX 자동 채우기 | 수동 작성 | AI 자동화 없음 | M | M |
| 스킬 커넥터(Web) HWPX 생성 | 우리 환경(Code) 해당 없음 (우리 시스템 미사용) | — | L | — |

## 필수 개선 제안

### P0 — 즉시 적용 가능 (1시간 이내)
- **[Forge MCP]** hwpx-mcp-server 설치 테스트: 현재 HWPX 쓰기 기능 전무 → `uvx hwpx-mcp-server` 설치 후 forge `.mcp.json`에 추가 → 정부과제 서류 HWPX 직접 생성 가능 여부 확인

### P2 — 이번 달
- **[Forge/grants]** HWPX 자동 채우기 스킬 연동: 정부과제 파이프라인에서 검토된 내용을 HWPX 서식에 자동 매핑하는 워크플로우 → grants 제출물 품질 향상

## 실행 가능 항목
- [ ] `uvx hwpx-mcp-server` 설치 테스트 + forge `.mcp.json` 등록 여부 검토 (담당: Business)
- [ ] easy-hwp 스킬(nathankim0/easy-hwp) 설치 후 정부과제 서식에 적용 테스트 (담당: Business)
- [ ] gonggong_hwpxskills 무료 스킬 다운로드하여 공문 자동 채우기 시나리오 검토 (담당: Business)

## 관련성
- **Portfolio**: 1/5 — 웹 프로젝트에 HWP 출력 필요 없음
- **GodBlade**: 1/5 — 게임 프로젝트와 무관
- **비즈니스**: 4/5 — 정부과제·공문 작성 시 HWPX 출력 요구 가능, 실용성 높음

## 핵심 인용
> "여러분이 처음에 프롬프트에다가 필요한 내용들을 한꺼번에 PDF나 아니면 HWP 형태의 파일을 넣고 내용이 들어가게 되면 훨씬 더 풍부하게 다양한 내용들이 나오게 됩니다." — 김용성 교수

## 추가 리서치 필요
- HWPX Python 라이브러리 직접 제어 (검색 키워드: `hwpx python library owpml`, `hwpx-mcp-server forge integration`)
- 정부과제 HWPX 서식 자동 채우기 정확도 (검색 키워드: `hwpx template fill automation accuracy`)
