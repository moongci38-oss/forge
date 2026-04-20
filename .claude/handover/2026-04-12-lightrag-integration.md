# LightRAG 통합 인수인계

> **세션**: 2026-04-11~12 | **작성**: 2026-04-12
> **다음 세션 진입점**: SME 중기부 과제 본문 Session 1 — §2 연구개발 방법 (4p, 배점 20점)

---

## 세션 목적

LightRAG 파일럿을 정부과제 도메인으로 확장하고, grants-write/review 스킬에 RAG 활용 구조를 통합했다.

---

## 완료 항목

| 항목 | 결과 | 경로 |
|-----|------|------|
| LightRAG 파일럿 (weekly-research) | 10개 문서 인덱싱 / 4/5 PASS / 평균 32.7s | `forge/shared/lightrag-pilot-data/index` |
| LightRAG grants 인덱싱 | 5개 문서 중 4개 완료 | `forge/shared/lightrag-grants-data/index` |
| lightrag-pilot.py 업데이트 | `--context [weekly\|grants]` 옵션 추가 | `forge/shared/scripts/lightrag-pilot.py` |
| grants-write SKILL.md | Phase 3에 RAG 활용 가이드 추가 | `~/.claude/skills/grants-write/SKILL.md` |
| grants-review SKILL.md | 축 2에 RAG 팩트체크/미활용 데이터 탐색 추가 | `~/.claude/skills/grants-review/SKILL.md` |
| Memory 업데이트 | project_lightrag_integration.md 생성 | `~/.claude/projects/-home-damools-forge/memory/` |

---

## 진행 중 / 미완료

| 항목 | 상태 | 확인 방법 |
|-----|------|---------|
| grants 5번째 문서 인덱싱 | `processing` 상태 (PID 788965 종료됐을 수 있음) | `cat forge/shared/lightrag-grants-data/index/kv_store_doc_status.json` |
| 워크스페이스 RAG 증분 빌드 | PID 821524 백그라운드 실행 중 | `tail -20 ~/.rag-build.log` |

---

## 다음 세션 진입점

**SME 중기부 과제 본문 작성 Session 1**

```
/grants-write
과제: ~/forge-outputs/09-grants/sme-tech-rd/sme-rd/
세션: Session 1 — §2 연구개발 방법 (4p)
```

참조 파일:
- `sme-본문-인수인계.md` — 6세션 계획 + 확정 표현 + 사용 수치 전체 목록
- `sme-목차.md` — §2 p1~p4 상세 구성 (이미 완성)
- `sme-작성전략.md` — 작성 전략

---

## RAG 사용법 치트시트

### LightRAG

```bash
# 정부과제 쿼리
python3 ~/forge/shared/scripts/lightrag-pilot.py query "TRL 8 근거" hybrid --context grants
python3 ~/forge/shared/scripts/lightrag-pilot.py query "Data Hub Station 기술 차별성" global --context grants

# 인덱스 추가 (새 문서 생길 때)
python3 ~/forge/shared/scripts/lightrag-pilot.py index --context grants

# weekly-research 쿼리 (기본, --context 생략)
python3 ~/forge/shared/scripts/lightrag-pilot.py query "AI 에이전트 동향" hybrid
```

### 워크스페이스 RAG (LlamaIndex)

```bash
# 특정 수치/구절 정밀 검색
python3 ~/forge/shared/scripts/rag/search.py "앵커링 임계값 0.85"
python3 ~/forge/shared/scripts/rag/search.py "Delta Lake CDF 실시간 전파"

# 인덱스 빌드 완료 확인
cat ~/.rag-workspace-index/meta.json
```

---

## 두 RAG 역할 분담

| 상황 | 사용 도구 |
|------|---------|
| 특정 수치·구절이 어느 파일에 있는지 찾을 때 | 워크스페이스 RAG (`search.py`) |
| 출처 코드([A]~[R])로 파일 특정 가능하지만 파일이 클 때 | 워크스페이스 RAG |
| 여러 문서 교차 근거 종합 필요 | LightRAG grants (global/hybrid) |
| 평가위원 관점 합성 질문 | LightRAG grants (global) |
| 목차에 이미 출처가 명시된 경우 | RAG 불필요 — 직접 파일 Read |

---

## 핵심 파일 경로 맵

```
~/forge/
├── shared/
│   ├── scripts/
│   │   ├── lightrag-pilot.py        # --context [weekly|grants] 지원
│   │   └── rag/
│   │       ├── search.py            # 워크스페이스 RAG 검색
│   │       └── workspace-build.sh   # 증분 빌드
│   ├── lightrag-pilot-data/         # weekly-research 인덱스
│   └── lightrag-grants-data/        # 정부과제 인덱스

~/.rag-workspace-index/              # 워크스페이스 전체 인덱스 (빌드 중)
~/.rag-build.log                     # 빌드 로그

~/forge-outputs/09-grants/sme-tech-rd/sme-rd/
├── sme-목차.md                      # §1~§7 상세 작성 가이드 (완성)
├── sme-본문-인수인계.md             # 세션 계획 + 수치 목록 + 확정 표현
└── sme-작성전략.md                  # 작성 전략
```
