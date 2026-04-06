# (직장인 필수) 클로드 skill로 pptx 템플릿 양식을 자동으로 완성
> 오피스마스터 | 21:56 | 10.7K views
> 원본: https://youtu.be/68hp8IiUXB4
> 자막: 자동생성 (신뢰도 Medium)

## TL;DR
Claude Claude.ai의 커스텀 Skill 기능(업로드 방식)을 활용해 기존 PPTX 템플릿의 레이아웃을 유지하면서 내용만 새 주제로 자동 교체하는 방법을 3가지 케이스로 시연한다. Anthropic의 공식 Agent Skills API와는 다른, Claude.ai 웹 UI의 커스텀 스킬 업로드 기능을 다룬다.

## 카테고리
productivity | #pptx #claude-skill #template-automation #office-automation

## 핵심 포인트
1. **기존 AI PPT 도구(Gamma/Gemini Canvas/Genspark)의 한계: 실무 포맷 비적용** [🕐 00:18](https://youtu.be/68hp8IiUXB4?t=18) — AI 생성 PPT는 대학 과제·캐주얼 용도에는 적합하지만, 회사마다 다른 폰트/색상/레이아웃 기준 때문에 비즈니스 실무에서 바로 사용하기 어렵다.
2. **PPTX = XML 기반 압축 파일, Claude가 직접 조작 가능** [🕐 03:00](https://youtu.be/68hp8IiUXB4?t=180) — .zip으로 확장자 변경 시 내부 XML 구조 확인 가능. Claude Skill이 이 구조를 파악하고 텍스트를 교체.
3. **케이스 1: 빈 템플릿 → 주제 지정으로 내용 자동 생성** [🕐 03:58](https://youtu.be/68hp8IiUXB4?t=238) — 교육 제안서 빈 양식에 "한국은행 신입행원 4시간 커리큘럼"을 입력하면 Claude가 레이아웃 유지하며 내용 생성. 완성도 약 80%.
4. **케이스 2: 유사 내용 템플릿 → 업종별 내용 교체** [🕐 09:09](https://youtu.be/68hp8IiUXB4?t=549) — 기존 교육 교안을 첨부하고 "더 세련된 용어로, 파트를 3개로 구분"하는 방식으로 내용 변형 가능.
5. **케이스 3: 전혀 다른 내용의 하이브리드 템플릿 교체** [🕐 12:32](https://youtu.be/68hp8IiUXB4?t=752) — 영업 슬라이드 구조를 삼성화재 손사이 전략 파트 업무에 맞게 재해석. 거버닝 메시지까지 업무 맥락에 맞게 재생성.
6. **슬라이드 분석 표 생성 → 슬라이드 라이브러리화** [🕐 18:16](https://youtu.be/68hp8IiUXB4?t=1096) — 파일명/슬라이드 번호/유형/비주얼 구조/적합한 주제/부적합 주제 등을 표로 정리하면 나중에 AI에게 슬라이드 추천 요청 가능.
7. **Skill 업로드 방법: Claude.ai → 설정 → 기능 → 스킬 → 사용자 지정 → 스킬 업로드** [🕐 05:15](https://youtu.be/68hp8IiUXB4?t=315) — 스킬 파일(.txt 또는 .md 형식 지침)을 업로드하면 해당 스킬이 채팅에서 적용됨.
8. **AI 변화 속도에 대한 현실적 견해** [🕐 19:56](https://youtu.be/68hp8IiUXB4?t=1196) — "채GPT 이후 지금까지 여러분 직장에서 드라마틱한 변화가 있었나요?" — 기술은 실제 적용 시 더디게 오므로 막연한 불안보다 필요할 때 배우는 실용적 접근 권장.

## 비판적 분석

### 주장 1: "Claude Skill로 기존 PPTX 양식을 유지하면서 내용을 자동 교체할 수 있다"
- **제시된 근거**: 라이브 시연 3케이스 (교육 제안서, 교안, 하이브리드 템플릿)
- **근거 유형**: 실증 (직접 시연)
- **한계**: 영상에서 "완성도 80%"라고 스스로 인정. 이미지가 포함된 슬라이드, 복잡한 차트/도형, 다중 색상 그라디언트 등은 처리 어려움. 또한 이 기능은 Claude.ai 웹 UI의 커스텀 스킬 업로드이므로 API 기반 자동화와는 다름.
- **반론/대안**: Anthropic의 공식 Agent Skills API(pptx skill)가 2025년 10월 출시되어 더 구조적인 PPTX 생성/편집이 가능. 우리 Forge 시스템의 pptx skill이 이 공식 API를 활용하고 있어 영상 방식보다 더 정밀한 제어 가능.

### 주장 2: "AI가 만든 PPT는 비즈니스 실무에서 바로 사용하기 어렵다"
- **제시된 근거**: Gamma, Gemini Canvas, Genspark 결과물 비교
- **근거 유형**: 실증적 비교 (주관적 평가 포함)
- **한계**: Genspark의 경우 "있어 보인다"고 인정하면서도 사용 어렵다고 결론 내림. 실제로 많은 기업에서 이 도구들을 이미 사용하고 있으며, "어렵다"의 기준이 주관적.
- **반론/대안**: 기업별 브랜드 가이드라인 적용이 어려운 것은 사실이지만, 중소기업이나 스타트업 환경에서는 AI 생성 PPT를 직접 사용하는 경우가 늘고 있음.

## 팩트체크 대상
- **주장**: "Claude Skill로 PPTX 양식을 유지한 채 내용 교체 시 완성도 약 80%" | **검증 필요 이유**: 구체적 수치이며 케이스에 따라 편차가 클 수 있음 | **검증 방법**: 직접 실험
- **주장**: "Claude.ai 커스텀 스킬 업로드로 PPTX 조작 가능" | **검증 필요 이유**: Anthropic 공식 기능인지, 제3자 방법인지 확인 필요 | **검증 방법**: platform.claude.com/docs 확인

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "Claude.ai 커스텀 스킬 업로드로 PPTX 조작 가능" | ✅ 확인 | Anthropic 공식 Skills 기능 존재 확인. Claude.ai 웹 UI + Agent Skills API 모두 pptx 지원. platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart 확인. |
| 2 | "완성도 약 80%" | ❓ 미검증 | 발표자의 주관적 평가로, 작업 유형/복잡도에 따라 편차가 크다. 단순 텍스트 교체는 높고 이미지/차트는 낮음. |

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| Anthropic 공식 Agent Skills (pptx) | [platform.claude.com](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart) | claude-opus-4-6 + betas["skills-2025-10-02"] + skill_id: "pptx" — 공식 API로 생성/편집 가능 | 보완 (영상보다 강력) |
| Claude PPTX Skill 가이드 | [smartscope.blog](https://smartscope.blog/en/generative-ai/claude/claude-pptx-skill-practical-guide/) | 2025년 10월 출시, Claude.ai/Code/API 모두 지원, 템플릿 재사용 패턴 권장 | 보완 |
| GitHub: claude-office-skills | [github.com/tfriedel/claude-office-skills](https://github.com/tfriedel/claude-office-skills) | markitdown으로 텍스트 추출 → 생성 → OOXML 검증 파이프라인. Forge pptx skill과 유사 구조 | 일치 |
| Claude Lab PPTX 완전 가이드 | [claudelab.net](https://claudelab.net/en/articles/claude-ai/claude-powerpoint-complete-guide) | "템플릿 한 번 만들고 재사용" 패턴 권장. 영상과 동일한 접근법 확인 | 일치 |

## GTC 수행 결과

**GTC-1 관련성 필터:**
- 영상에서 다루는 Claude.ai 커스텀 스킬 업로드 → 우리 시스템에서는 Claude Code + Forge pptx skill로 동일 기능을 더 강력하게 구현 중 ✅
- PPTX 생성/편집 → `/home/damools/.claude/skills/pptx/SKILL.md` 존재 확인 ✅ (이미 구현됨)
- 슬라이드 템플릿 라이브러리화 → 아직 미구현

**GTC-2 기구현 확인:**
- pptx skill: 이미 markitdown + pptxgenjs 기반으로 구현됨
- 영상의 "Claude.ai 스킬 업로드" 방식보다 우리 시스템이 더 구조적임 (API 기반, 검증 스크립트 포함)

**GTC-4 영향도 검증:**
- 슬라이드 라이브러리화 → 현재 비즈니스에서 PPT 작업 빈도를 고려하면 단기적 blocking 없음 → P2 적절

## 시스템 비교 분석

| 영상/리서치 제안 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------------|---------|:--:|:----:|:----:|
| Claude로 PPTX 템플릿 내용 교체 | 이미 적용 (pptx skill 구현됨) | 없음 | — | — |
| 커스텀 스킬 업로드 (Claude.ai 방식) | 우리 시스템 미사용 (Claude Code + skill 방식 우선) | 우리 방식이 더 강력 | L | — |
| 슬라이드 라이브러리 (분석 표) 구축 | 미적용 | 재사용 가능한 슬라이드 분류 체계 없음 | L | L |
| 슬라이드 추천 시스템 (주제 → 적합 슬라이드 매칭) | 미적용 | 라이브러리 미구축으로 불가 | L | M |

## 필수 개선 제안

### P2 — 이번 달
- **[Business]** 자주 쓰는 PPTX 템플릿 슬라이드 라이브러리 구축: 영상의 "슬라이드 분석 표" 방식으로 템플릿별 슬라이드 유형/적합 주제 정리 → 향후 PPT 작업 시 AI에게 "이 주제에 맞는 슬라이드 추천" 요청 가능. 단, 현재 PPT 작업 빈도를 고려하면 즉각 blocking이 아님.

## 실행 가능 항목
- [ ] 현재 보유한 PPTX 템플릿 파일 목록화 + 슬라이드 유형 분류표 작성 (적용 대상: Business)
- [ ] forge pptx skill의 editing.md 검토 — 영상의 3가지 케이스 중 우리 스킬이 지원 안 하는 케이스 파악 (적용 대상: Business/Forge)

## 관련성
- **Portfolio**: 1/5 — 웹 개발 프로젝트에서 PPT 활용 낮음
- **GodBlade**: 1/5 — 게임 개발에서 PPT 직접 연관 없음
- **비즈니스**: 4/5 — 클라이언트 제안서, 정부과제 발표자료 등 PPT 작업이 실제 있음. 우리 pptx skill 활용 강화 가능

## 핵심 인용
> "여러분 이제 좋은 양식만 잘 모아 놓으세요. 나머지는 이제 클로드가 할 겁니다." — 오피스마스터

> "AI 관련해서 너무 겁먹지 마세요. 쫄지도 마시고 생각보다 모든 제도 시스템 기술은 실제 나에게 적용될 때는 조금 더디게 올 확률이 높습니다." — 오피스마스터

## 추가 리서치 필요
- Anthropic Agent Skills API의 pptx skill 상세 기능 목록 (검색 키워드: `anthropic agent skills pptx editing template 2025`)
- 우리 pptx skill의 현재 한계 파악 (검색 키워드: `claude code pptx skill markitdown template editing`)
