---
name: rag-search
description: forge-outputs 문서에서 벡터+BM25 하이브리드 의미 검색을 수행하는 스킬. 정부과제 자료, 리서치, 기획서 등에서 키워드가 아닌 의미 기반으로 관련 문서/청크를 찾는다. "투자 유치" → "VC 라운드, 시드 펀딩, 민간투자" 등 동의어까지 검색.
user-invocable: true
context: fork
model: haiku
---

**역할**: 당신은 워크스페이스 전체 문서에서 벡터+BM25 하이브리드 의미 검색을 수행하는 문서 검색 전문가입니다.
**컨텍스트**: 서버 설정 문서, 정부과제 근거 데이터, 기획서, 리서치 등 프로젝트 전체에서 키워드가 아닌 의미 기반으로 관련 문서를 찾을 때 호출됩니다.
**출력**: 파일 경로·유사도 점수·텍스트 프리뷰를 포함한 상위 N개 검색 결과를 반환합니다.

# RAG Search — 의미 기반 문서 검색

워크스페이스 전체(Forge + forge-outputs + Portfolio + GodBlade) 문서에서 벡터(의미) + BM25(키워드) 하이브리드 검색을 수행한다.

## 언제 사용하나

- "이 설정 문서가 어디 있었지?" 할 때
- 정부과제 본문 작성 시 근거 데이터를 찾을 때
- 키워드가 정확히 기억나지 않지만 주제로 찾고 싶을 때
- Grep으로 안 찾아지는 동의어/유사 표현 검색

## 사용법

```
/rag-search 투자 유치 전략
/rag-search TagHub 기술 차별점 --top-k 10
/rag-search 시장 규모 TAM --mode vector
/rag-search dev staging production 서버 셋팅
```

## 워크플로우

### Step 1: 인덱스 확인

```bash
# 워크스페이스 인덱스 확인
ls ~/.rag-workspace-index/meta.json

# 없으면 최초 빌드 제안 (시간 소요 — 사용자 확인 후)
bash ${FORGE_ROOT:-~/forge}/shared/scripts/rag/workspace-build.sh --rebuild
```

인덱스 위치:
- **워크스페이스 통합** (기본): `~/.rag-workspace-index/` — Forge + forge-outputs + Portfolio + GodBlade
- **정부과제 전용**: `$FORGE_OUTPUTS/09-grants/.rag-index/`

### Step 2: 검색 실행

```bash
# 워크스페이스 전체 검색 (기본 — ~/.rag-workspace-index 자동 사용)
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/search.py "{검색어}" --top-k {N} --mode {hybrid|vector|bm25}

# 정부과제만 검색
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/search.py "{검색어}" --index-dir ${FORGE_OUTPUTS:-~/forge-outputs}/09-grants/.rag-index
```

파라미터:
- `--top-k N`: 결과 수 (기본 5)
- `--mode hybrid`: 벡터+BM25 조합 (기본, 권장)
- `--mode vector`: 의미 검색만
- `--mode bm25`: 키워드 검색만
- `--json`: JSON 출력 (프로그래밍용)
- `--index-dir`: 인덱스 위치 지정

### Step 3: 결과 해석 + 활용

검색 결과에서:
1. 파일 경로 + 점수 확인
2. 텍스트 프리뷰로 맥락 파악
3. 필요하면 해당 파일을 Read하여 전체 문맥 확인
4. grants-write 등 다른 스킬에서 근거로 인용

## 인덱스 관리

### 워크스페이스 빌드 (권장)

```bash
# 최초 빌드 (Forge + forge-outputs + Portfolio + GodBlade 전체)
bash ${FORGE_ROOT:-~/forge}/shared/scripts/rag/workspace-build.sh --rebuild

# 증분 빌드 (새 파일만 추가 — cron이 4시간마다 자동 실행)
bash ${FORGE_ROOT:-~/forge}/shared/scripts/rag/workspace-build.sh

# 인덱스 정보
cat ~/.rag-workspace-index/meta.json
```

### 단일 폴더 빌드

```bash
# 정부과제 전용 인덱스
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py ${FORGE_OUTPUTS:-~/forge-outputs}/09-grants

# 증분 업데이트
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py ${FORGE_OUTPUTS:-~/forge-outputs}/09-grants --incremental
```

### workspace.json 설정

인덱싱 대상 프로젝트는 `${FORGE_ROOT:-~/forge}/shared/scripts/rag/workspace.json`에서 관리:
- 새 프로젝트 추가 시 `sources` 배열에 항목 추가
- `exclude_dirs`: 프로젝트별 제외 폴더
- 소스코드(.ts/.js/.cs/.py 등)는 화이트리스트(.md/.txt/.json/.docx/.pdf/.yaml)로 자동 제외

## 기술 구성

| 구성 요소 | 선택 | 비고 |
|----------|------|------|
| 프레임워크 | LlamaIndex | 문서 로딩 + 인덱싱 |
| 벡터 저장소 | FAISS (로컬) | 서버 불필요 |
| 키워드 검색 | BM25Retriever | 하이브리드 병합 |
| 임베딩 모델 | multilingual-e5-small (로컬) | 한국어 지원, 비용 0 |
| 임베딩 차원 | 384 | |
| 청크 크기 | 512 토큰 | overlap 50 |
| 지원 파일 | md, txt, json, docx, pdf | hwp/pptx/이미지 제외 |

## 환경 요구사항

- Python 3.10+
- 패키지: `pip install -r ${FORGE_ROOT:-~/forge}/shared/scripts/rag/requirements.txt`
- 추가: `pip install llama-index-embeddings-huggingface sentence-transformers docx2txt`
- (선택) OPENAI_API_KEY — 있으면 text-embedding-3-small 사용, 없으면 로컬 모델

## AI 행동 규칙

1. grants-write/grants-review 실행 중 근거를 찾아야 할 때 자동으로 이 스킬을 호출할 수 있다
2. 검색 결과를 인용할 때 파일 경로를 출처로 명시한다
3. 인덱스가 없으면 빌드를 제안하되, 사용자 확인 없이 자동 빌드하지 않는다 (시간 소요)
4. 문서가 변경되어 인덱스가 오래됐으면 `--rebuild` 제안
