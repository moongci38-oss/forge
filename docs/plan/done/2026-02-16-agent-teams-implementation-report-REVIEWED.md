# 1인 기업 AI Agent Teams 구축 실행 계획 - 검증 및 수정본

**작성일**: 2026-02-16
**상태**: ✅ 검증 완료 - 현실적 계획 수립
**목표**: 백엔드 개발자 1명이 AI Agent Teams로 6개 약점 영역을 **60-70% 보완** (현실적 목표)

---

## 📋 원본 계획서 검증 결과

### ⚠️ 발견된 주요 문제점

| 문제점 | 원본 계획 | 현실성 평가 | 수정 방향 |
|--------|----------|------------|----------|
| **토큰 절감 수치** | 96% 절감 (134k→5k) | ❌ 과장된 수치 | 실측 후 조정 필요 |
| **타임라인** | 4주 완료 | ❌ 비현실적 | 6-8주로 확대 |
| **신규 에이전트** | 9개 생성 | ❌ 과도함 | 2-3개로 축소 |
| **자료 타입** | 9가지 동시 처리 | ❌ 복잡도 높음 | 4가지로 시작 |
| **Hook 시스템** | 10개 이벤트 | ❌ 과도함 | 2-3개로 시작 |
| **CLAUDE.md** | 7개 폴더 모두 | ❌ 너무 많음 | 3개 핵심만 |
| **자동화 스케줄** | 매일 실행 | ❌ 비용 과다 | 주간으로 시작 |
| **성과 측정** | 정량 지표 없음 | ❌ 검증 불가 | 측정 방법 추가 |
| **Agent Teams** | Fan-out/Fan-in | ❌ 이론적 | 직렬 실행부터 |
| **외부 도구** | 통합 불명확 | ❌ 수동 작업 | 범위 명확화 |

---

## 🎯 수정된 목표 및 현실적 성과 지표

### Before (원본 계획)
| 지표 | 목표 | 문제점 |
|------|------|--------|
| 토큰 절감 | 70-80% | 근거 불충분 |
| 시장조사 | 87% 절감 (4h→30m) | 측정 방법 없음 |
| 블로그 작성 | 83% 절감 (2h→20m) | 비현실적 |
| 전략 수립 | 75% 절감 (8h→2h) | 과대 평가 |

### After (수정된 계획)
| 지표 | Phase 1 목표 | Phase 2 목표 | 측정 방법 |
|------|:-------------:|:-------------:|----------|
| **토큰 사용량** | 30-40% 절감 | 50-60% 절감 | 세션별 토큰 로그 분석 |
| **시장조사 시간** | 4h → 2h (50%) | 4h → 1h (75%) | 타이머 기록 + 작업 로그 |
| **블로그 작성** | 2h → 1h (50%) | 2h → 40m (67%) | Before/After 실측 |
| **전략 수립** | 8h → 5h (38%) | 8h → 3h (63%) | 프로젝트별 시간 추적 |
| **작업 복구율** | 50% (수동) | 90% (자동) | 중단 테스트 5회 |

**핵심 원칙**: 보수적 예측 → 실측 → 점진적 개선

---

## 📊 현재 시스템 상태 (검증됨)

### ✅ 이미 구축된 인프라 (변경 없음)

**스킬**: 39개 설치됨
- 비즈니스/마케팅: 20개
- 생산성: 7개
- 리서치: 2개
- 기타: 10개

**에이전트**: 9개 활성화됨
- orchestrator, research-coordinator, market-researcher
- technical-writer, ux-researcher, academic-researcher
- fact-checker, seo-analyzer, search-ai-optimization-expert

**MCP 서버**: 6개
- Memory, Filesystem, Brave Search
- Context7, Playwright, Sequential Thinking

---

## 🔄 수정된 구현 계획 (6-8주)

### Phase 1: 최소 기반 구축 (Week 1-2) ⭐

**목표**: 토큰 효율화 + 핵심 2개 폴더만

#### 1.1 토큰 최소화 (Week 1)

**1. MCP Tool Search 활성화 + 실측**
```bash
# 환경변수 설정
export ENABLE_TOOL_SEARCH=auto

# Before/After 측정
# Before: 세션 시작 시 토큰 사용량 기록
# After: 동일 작업 토큰 사용량 비교
# 목표: 30-40% 절감 (현실적)
```

**검증 방법**:
- 5개 세션에서 동일 작업 수행
- 평균 토큰 절감율 계산
- 96% 절감은 **특정 케이스일 가능성** → 실측 필요

**2. Root CLAUDE.md 간소화**
```markdown
# 현재: 243줄 → 목표: 100줄 이하
- 기본 개념, 폴더 구조, Golden Rules만
- 세부 시스템 제거 → 각 폴더 CLAUDE.md로 이동
- MCP 서버 가이드 간소화 (링크로 대체)
```

**3. .claude/rules/ 모듈화 (3개만)**
```
.claude/rules/
├── git.md              ← 커밋, 브랜치, 머지 규칙
├── file-naming.md      ← 파일명 규칙
└── security.md         ← 보안 체크리스트
```

**제외**: code-style.md, testing.md, documentation.md (필요 시 추가)

#### 1.2 핵심 폴더 2개 CLAUDE.md 생성 (Week 2)

**우선순위 1: 01-research/CLAUDE.md**
- 4가지 자료 타입만 (9가지는 과도함)
  - 📰 기사 (Brave Search) - market-researcher
  - 📚 공식문서 (Context7) - 기존 도구 사용
  - 💻 오픈소스 (GitHub) - 기존 도구 사용
  - 📊 기타 (수동) - research-coordinator
- 나머지 5가지는 Phase 2-3에서 점진적 추가

**우선순위 2: 05-content/CLAUDE.md**
- 간단한 파이프라인
  - 초안 작성 (technical-writer)
  - SEO 최적화 (seo-analyzer)
  - 검증 (fact-checker)
- 복잡한 Agent Teams는 Phase 2에서

**제외** (Phase 2-3으로 연기):
- 02-strategy, 03-design, 04-marketing, 06-dev-tools, 07-operations

---

### Phase 2: 핵심 자동화 (Week 3-4)

**목표**: Hook 2개 + 자동화 1개 + 검증

#### 2.1 Hook 시스템 (2개만)

**Hook 1: user-prompt-submit**
```bash
# .claude/hooks/context-inject.sh
# 현재 폴더에 따라 컨텍스트 자동 주입
if [[ $PWD == *"01-research"* ]]; then
  echo "📊 Research Mode: 출처 포함 필수"
elif [[ $PWD == *"05-content"* ]]; then
  echo "✍️ Content Mode: SEO 최적화 권장"
fi
```

**Hook 2: task-update**
```bash
# .claude/hooks/checkpoint.sh
# Task 상태 변경 시 Memory MCP 저장
if [[ $TASK_STATUS == "completed" ]]; then
  echo "💾 Saving to Memory MCP"
fi
```

**제외** (복잡도 높음):
- file-write, file-read, bash-run (Phase 3)
- agent-start/end (구현 복잡)
- git-commit (기존 프로세스로 충분)

#### 2.2 자동화 스케줄 (주간 1개만)

**weekly.sh** (월요일 09:00):
```bash
#!/bin/bash
# 주간 리서치 리포트만
cd Z:/home/damools/business/01-research
claude "research-coordinator를 사용하여 지난 7일 Brave Search 결과 종합
→ weekly/$(date +%Y-W%V)-report.md"
```

**제외** (비용 과다):
- 매일 실행 (daily.sh) → Phase 3에서 검토
- 월간 실행 (monthly.sh) → Phase 3에서 추가

#### 2.3 신규 에이전트 (2개만)

**1. docs-tracker.md** (공식문서 모니터링)
```markdown
---
name: docs-tracker
tools: Read, mcp__context7__*
model: haiku
---
# Context7로 React, Next.js 문서 변경 추적
```

**2. opensource-intel.md** (GitHub trending)
```markdown
---
name: opensource-intel
tools: Read, Bash
model: haiku
---
# GitHub API로 trending 리포지토리 분석
```

**제외** (기존 에이전트로 충분):
- whitepaper-analyzer → academic-researcher로 대체
- video-summarizer → 수동 처리 (YouTube는 복잡)
- community-listener → market-researcher로 대체
- trend-tracker → market-researcher로 대체
- screenshot-capturer → Phase 3 (디자인 워크플로우)
- screenshot-business-analyzer → Phase 3
- portfolio-analyzer → Phase 3

#### 2.4 성과 측정 프로토콜

**측정 항목**:
1. **토큰 사용량**: 세션별 로그 수집 → 주간 평균 계산
2. **작업 시간**: 타이머 앱 사용 (Toggl Track)
   - 시장조사: 프로젝트별 태그
   - 블로그 작성: 포스트별 태그
3. **작업 복구**: 의도적 중단 테스트 5회
   - Memory MCP 복구율
   - Task 시스템 복구율
   - 파일 체크포인트 복구율

**측정 주기**: 주간 (매주 금요일 리뷰)

---

### Phase 3: 확장 (Week 5-6)

**목표**: 나머지 폴더 + Hook 추가 + 에이전트 확장

#### 3.1 추가 CLAUDE.md (3개)
- 02-strategy/CLAUDE.md (전략 수립)
- 04-marketing/CLAUDE.md (마케팅 자동화)
- 07-operations/CLAUDE.md (3-Layer 상태 관리)

**제외** (낮은 우선순위):
- 03-design/CLAUDE.md (외부 도구 중심, 수동 작업)
- 06-dev-tools/CLAUDE.md (이미 스크립트로 관리 중)

#### 3.2 추가 Hook (2개)
- file-write (자동 린트/포맷)
- bash-run (위험 명령 체크)

#### 3.3 추가 에이전트 (필요 시)
- whitepaper-analyzer (백서 분석)
- community-listener (Reddit, HN)

#### 3.4 자동화 확장
- daily.sh (매일 실행) - Phase 2 검증 후 추가
- monthly.sh (월간 리포트)

---

### Phase 4: 최적화 & 검증 (Week 7-8)

**목표**: 실사용 + 성과 측정 + 개선

#### 4.1 실제 프로젝트 적용
- Micro SaaS 아이디어 1개로 전체 워크플로우 테스트
- 시장조사 → 전략 수립 → 콘텐츠 생성

#### 4.2 성과 측정 및 분석
- 토큰 사용량 최종 집계
- 작업 시간 Before/After 비교
- 병목 구간 파악

#### 4.3 Agent Teams 실험 (선택)
- 단순 Pipeline 패턴 (직렬 실행)
- Fan-out/Fan-in은 Phase 5로 연기

#### 4.4 문서화
- 각 시스템 사용 가이드 작성
- 트러블슈팅 문서
- 베스트 프랙티스 정리

---

## 🔍 01-research/ 수정된 시스템 (4가지 자료 타입)

### 현실적인 자료 수집 전략

| 타입 | 담당 | 출처 | 주기 | 우선순위 |
|------|------|------|------|:--------:|
| 📰 **기사** | market-researcher | Brave Search | 주간 | ⭐⭐⭐ |
| 📚 **공식문서** | docs-tracker (신규) | Context7 | 주간 | ⭐⭐⭐ |
| 💻 **오픈소스** | opensource-intel (신규) | GitHub API | 주간 | ⭐⭐☆ |
| 📊 **기타** | 수동 처리 | 케이스 스터디 | 필요 시 | ⭐☆☆ |

**Phase 2-3에서 추가 고려**:
- 📄 논문 (academic-researcher) - 월간
- 📋 백서 (whitepaper-analyzer) - 분기
- 💬 커뮤니티 (community-listener) - 주간
- 🎥 영상 (video-summarizer) - 복잡도 높음
- 📱 SNS (trend-tracker) - 노이즈 많음

### 자동화 워크플로우 (주간만)

**weekly.sh** (월요일 09:00):
```bash
#!/bin/bash
echo "📅 Weekly Research Automation"

# 1. 기사 수집
claude "market-researcher: Brave Search로 AI/SaaS 뉴스 7일분 수집
→ 01-research/articles/$(date +%Y-W%V)-weekly.md"

# 2. 공식문서 업데이트
claude "docs-tracker: React, Next.js Context7 변경사항 확인
→ 01-research/docs-updates/$(date +%Y-W%V)-updates.md"

# 3. 오픈소스 트렌드
claude "opensource-intel: GitHub trending 주간 분석
→ 01-research/opensource/$(date +%Y-W%V)-trending.md"

# 4. 주간 리포트 종합
claude "research-coordinator: 위 3개 결과 종합
→ 01-research/weekly/$(date +%Y-W%V)-report.md"

echo "✅ Weekly automation completed"
```

**비용 추정**:
- 주 1회 실행
- 예상 토큰: ~50K/주 (Sonnet)
- 월 비용: ~$6-8 (매일 실행 대비 1/7)

---

## 🎨 03-design/ 현실적 워크플로우 (Phase 3)

### 외부 도구 중심 + 최소 자동화

**단계별 프로세스 (대부분 수동)**:
1. **v0.dev** (수동) → 컴포넌트 생성
2. **Figma AI** (수동) → 레이아웃 정리
3. **Midjourney** (수동) → 이미지 생성
4. **Claude Code** → 코드 구현 (유일한 자동화)
5. **ux-researcher** → UX 평가 (에이전트)

**자동화 범위 (현실적)**:
- ❌ v0.dev 자동 호출 불가 (브라우저 수동 작업)
- ❌ Figma AI 자동 호출 불가 (API 없음)
- ✅ 생성된 코드 → Claude Code로 구현
- ✅ ux-researcher로 UX 평가

**결론**: 03-design/CLAUDE.md는 낮은 우선순위 (Phase 3)

---

## 🛡️ 07-operations/ 3-Layer 상태 관리 (Phase 2)

### 단순화된 체크포인트 시스템

**Layer 1: Memory MCP** (영구 저장)
```json
{
  "entity": "research-workflow",
  "observations": [
    "last_run: 2026-02-16",
    "status: completed",
    "output: 01-research/weekly/2026-W07-report.md"
  ]
}
```

**Layer 2: Task 시스템** (진행 추적)
- TaskCreate → TaskUpdate(in_progress) → TaskUpdate(completed)
- 간단한 직렬 실행 (의존성 없음)

**Layer 3: 파일 체크포인트** (백업)
- `docs/plan/doing/YYYY-MM-DD-workflow.md`
- 매 Phase 완료 시 수동 저장

### 복구 프로토콜 (단순화)

1. Memory 검색 (`last_run < 7 days`)
2. TaskList로 미완료 작업 확인
3. 체크포인트 파일 로드
4. 수동으로 재개 (자동 복구는 Phase 3)

**자동 체크포인트 제거** (복잡도 높음):
- ❌ "5단계마다 자동 저장" → 수동으로 변경
- ❌ "서브에이전트 완료 시 자동 업데이트" → Phase 3
- ✅ Phase 완료 시 수동 체크포인트

---

## 📊 수정된 토큰 최소화 전략

### 현실적인 절감 목표

**1. MCP Tool Search 활성화** → **30-40% 절감 (실측 필요)**
```bash
export ENABLE_TOOL_SEARCH=auto

# 검증 방법
# 1. Before: 5개 세션 평균 토큰
# 2. After: 동일 작업 5개 세션 평균
# 3. 절감율 = (Before - After) / Before * 100
```

**2. CLAUDE.md 계층화** → **20-30% 추가 절감**
- Root: 100줄 이하 (1-2KB)
- 각 폴더: 200줄 이하 (4-6KB)
- Phase 1에는 2개만 로드

**3. Haiku 모델 활용** → **비용 3배 절감**
- docs-tracker: Haiku (간단한 문서 추적)
- opensource-intel: Haiku (GitHub API 호출)
- 나머지: Sonnet (복잡한 작업)

**4. 서브에이전트 도구 화이트리스팅**
```markdown
---
name: docs-tracker
tools: Read, mcp__context7__*  # 최소한의 도구만
model: haiku
---
```

**5. .claude/rules/ 임포트**
```markdown
# Root CLAUDE.md에서
@.claude/rules/git.md
@.claude/rules/file-naming.md
@.claude/rules/security.md
```

### 예상 총 절감율
- MCP Tool Search: 30-40%
- CLAUDE.md 계층화: 20-30%
- **총 절감**: **50-60%** (Phase 2 완료 시)

---

## ✅ 수정된 실행 체크리스트

### Phase 1: 최소 기반 구축 (Week 1-2)

**Week 1: 토큰 최소화**
- [ ] MCP Tool Search 활성화 + 실측 (5개 세션)
- [ ] Root CLAUDE.md 간소화 (243줄 → 100줄)
- [ ] .claude/rules/ 디렉토리 생성
- [ ] .claude/rules/git.md
- [ ] .claude/rules/file-naming.md
- [ ] .claude/rules/security.md

**Week 2: 핵심 2개 폴더**
- [ ] 01-research/CLAUDE.md (4가지 자료 타입)
- [ ] 05-content/CLAUDE.md (단순 파이프라인)

### Phase 2: 핵심 자동화 (Week 3-4)

**Week 3: Hook & 에이전트**
- [ ] .claude/hooks/context-inject.sh
- [ ] .claude/hooks/checkpoint.sh
- [ ] .claude/agents/docs-tracker.md
- [ ] .claude/agents/opensource-intel.md

**Week 4: 자동화 & 검증**
- [ ] .claude/schedules/weekly.sh (주간 리포트)
- [ ] 성과 측정 프로토콜 실행 (1주일)
- [ ] 토큰 사용량 분석 리포트 작성

### Phase 3: 확장 (Week 5-6)

**Week 5: 추가 폴더**
- [ ] 02-strategy/CLAUDE.md
- [ ] 04-marketing/CLAUDE.md
- [ ] 07-operations/CLAUDE.md

**Week 6: 추가 Hook & 에이전트**
- [ ] .claude/hooks/file-write.sh (린트)
- [ ] .claude/hooks/bash-run.sh (안전 체크)
- [ ] .claude/agents/whitepaper-analyzer.md (필요 시)
- [ ] .claude/agents/community-listener.md (필요 시)

### Phase 4: 최적화 (Week 7-8)

**Week 7: 실제 프로젝트 적용**
- [ ] Micro SaaS 아이디어 전체 워크플로우 테스트
- [ ] 시장조사 → 전략 수립 → 콘텐츠 생성

**Week 8: 측정 & 문서화**
- [ ] 최종 성과 측정 리포트
- [ ] 각 시스템 사용 가이드 작성
- [ ] 트러블슈팅 문서
- [ ] Phase 5 계획 수립

---

## 📈 현실적인 예상 성과

### Phase 1 완료 시 (Week 2)
- 토큰 사용량: **30-40% 절감**
- 작업 시간: 측정 중 (베이스라인 설정)
- CLAUDE.md: 2개 폴더 (01-research, 05-content)

### Phase 2 완료 시 (Week 4)
- 토큰 사용량: **50-60% 절감**
- 시장조사: **30-50% 시간 절감** (4h → 2-3h)
- 블로그 작성: **30-50% 시간 절감** (2h → 1-1.5h)
- 자동화: 주간 리포트 1개

### Phase 3 완료 시 (Week 6)
- 토큰 사용량: **60-70% 절감**
- 시장조사: **50-70% 시간 절감** (4h → 1.5-2h)
- 블로그 작성: **50-70% 시간 절감** (2h → 40-60m)
- CLAUDE.md: 5개 폴더
- 자동화: 주간 + 월간 리포트

### Phase 4 완료 시 (Week 8)
- 토큰 사용량: **70-80% 절감** (최적화 후)
- 전략 수립: **50-70% 시간 절감** (8h → 3-4h)
- 작업 복구율: **80-90%** (3-Layer 시스템)
- 전체 워크플로우 검증 완료

---

## 🚨 리스크 및 대응 전략

### 리스크 1: 토큰 절감 목표 미달
**원인**: MCP Tool Search가 예상만큼 효과적이지 않음
**대응**: Haiku 모델 적극 활용, CLAUDE.md 추가 간소화

### 리스크 2: 자동화 스케줄 실행 실패
**원인**: cron 설정 오류, 환경 변수 미전달
**대응**: 수동 실행 스크립트 준비, 로그 모니터링

### 리스크 3: 신규 에이전트 성능 부족
**원인**: 프롬프트 엔지니어링 부족
**대응**: 기존 에이전트로 대체, 점진적 개선

### 리스크 4: Phase 타임라인 지연
**원인**: 예상보다 복잡한 구현
**대응**: Phase 3-4 일부 기능 Phase 5로 연기

### 리스크 5: 외부 도구 통합 실패
**원인**: API 제한, 수동 작업 필요
**대응**: 자동화 범위 축소, 수동 워크플로우 유지

---

## 🎯 핵심 차별화 요소 (수정됨)

1. ✅ **39개 스킬 + 9개 에이전트** 이미 설치 (활용도 증대)
2. ✅ **6개 MCP 서버** 통합 (실측 기반 최적화)
3. ✅ **점진적 확장** (2개 폴더 → 5개 폴더, 6-8주)
4. ✅ **현실적 목표** (60-70% 보완, 50-70% 토큰 절감)
5. ✅ **측정 가능한 성과** (주간 리뷰, Before/After 비교)
6. ✅ **solo-entrepreneur-ai-toolkit 기반** (검증된 방법론)

---

## 📝 검증 결론

### 원본 계획서의 강점
- ✅ 체계적인 구조 (7개 폴더, 4단계 Phase)
- ✅ 이미 설치된 인프라 활용 (39 스킬, 9 에이전트)
- ✅ 토큰 최소화 전략 (MCP Tool Search, CLAUDE.md 계층화)
- ✅ 3-Layer 상태 관리 (작업 중단/복구)

### 원본 계획서의 약점
- ❌ 과도하게 낙관적인 수치 (96% 토큰 절감)
- ❌ 비현실적인 타임라인 (4주)
- ❌ 과도한 복잡도 (9개 신규 에이전트, 10개 Hook)
- ❌ 측정 방법 부재 (검증 불가능한 성과 지표)
- ❌ 외부 도구 통합 불명확 (v0.dev, PrometAI 자동화 불가)

### 수정된 계획의 개선점
- ✅ 현실적인 목표 (60-70% 보완, 50-60% 토큰 절감)
- ✅ 점진적 확장 (6-8주, 2개 폴더 → 5개 폴더)
- ✅ 최소 복잡도 (2개 신규 에이전트, 2개 Hook)
- ✅ 측정 가능한 지표 (주간 리뷰, 타이머 기록)
- ✅ 명확한 자동화 범위 (수동 작업 구분)

---

## 🚀 다음 단계 (즉시 실행)

### 1단계: 토큰 사용량 베이스라인 측정 (오늘)
```bash
# 5개 세션에서 동일 작업 수행
# 1. 시장조사 요청
# 2. 블로그 초안 작성
# 3. 전략 수립 요청
# 4. 리서치 리포트 생성
# 5. 콘텐츠 최적화

# 각 세션 토큰 사용량 기록
# 평균값 계산 → Before 기준값 설정
```

### 2단계: MCP Tool Search 활성화 (오늘)
```bash
echo 'export ENABLE_TOOL_SEARCH=auto' >> ~/.bashrc
source ~/.bashrc
```

### 3단계: 토큰 사용량 After 측정 (내일)
```bash
# 동일한 5개 세션 수행
# 토큰 사용량 기록
# 절감율 계산: (Before - After) / Before * 100
# 목표: 30-40% 절감
```

### 4단계: Root CLAUDE.md 간소화 시작 (Week 1)
```bash
# 현재 243줄 → 목표 100줄
# .claude/rules/ 생성 및 모듈 분리
```

---

## 📊 최종 권장사항

### 즉시 실행 (우선순위 높음)
1. **토큰 베이스라인 측정** (검증 가능한 목표 설정)
2. **MCP Tool Search 활성화** (실제 절감율 확인)
3. **Root CLAUDE.md 간소화** (100줄 목표)

### Week 1-2 (Phase 1)
1. **.claude/rules/ 모듈화** (3개 파일)
2. **01-research/CLAUDE.md** (4가지 자료 타입)
3. **05-content/CLAUDE.md** (단순 파이프라인)

### Week 3-4 (Phase 2)
1. **Hook 2개** (context-inject, checkpoint)
2. **신규 에이전트 2개** (docs-tracker, opensource-intel)
3. **주간 자동화 1개** (weekly.sh)
4. **성과 측정 1주일** (토큰, 시간, 복구율)

### Week 5-8 (Phase 3-4)
1. **추가 폴더 3개** (strategy, marketing, operations)
2. **실제 프로젝트 적용** (Micro SaaS 워크플로우)
3. **최종 측정 및 문서화**

---

**작성자**: Claude Sonnet 4.5
**검증 방법**: 원본 계획서 비판적 분석 + 현실성 검증
**다음 액션**: 토큰 베이스라인 측정 → MCP Tool Search 활성화 → Phase 1 시작

*이 계획은 6-8주에 걸쳐 점진적으로 확장되며, 매 Phase마다 실측 기반으로 조정됩니다.*
