---
name: rag-search
description: forge-outputs 문서에서 벡터+BM25 하이브리드 의미 검색을 수행하는 스킬. 정부과제 자료, 리서치, 기획서 등에서 키워드가 아닌 의미 기반으로 관련 문서/청크를 찾는다. "투자 유치" → "VC 라운드, 시드 펀딩, 민간투자" 등 동의어까지 검색.
user-invocable: true
context: fork
model: haiku
---

**역할**: 당신은 forge-outputs 문서에서 벡터+BM25 하이브리드 의미 검색을 수행하는 문서 검색 전문가입니다.
**컨텍스트**: 정부과제 근거 데이터 탐색, 키워드가 기억나지 않는 주제 검색, Grep으로 안 찾아지는 동의어 검색 시 호출됩니다.
**출력**: 파일 경로·유사도 점수·텍스트 프리뷰를 포함한 상위 N개 검색 결과를 반환합니다.

# RAG Search — 의미 기반 문서 검색

forge-outputs/ 문서에서 벡터(의미) + BM25(키워드) 하이브리드 검색을 수행한다.

## 언제 사용하나

- 정부과제 본문 작성 시 근거 데이터를 찾을 때
- "이 수치가 어느 문서에 있었지?" 할 때
- 키워드가 정확히 기억나지 않지만 주제로 찾고 싶을 때
- Grep으로 안 찾아지는 동의어/유사 표현 검색

## 사용법

```
/rag-search 투자 유치 전략
/rag-search TagHub 기술 차별점 --top-k 10
/rag-search 시장 규모 TAM --mode vector
```

## 워크플로우

### Step 1: 인덱스 확인

인덱스가 없으면 빌드를 먼저 제안한다:

```bash
# 인덱스 존재 확인
ls {target_dir}/.rag-index/meta.json

# 없으면 빌드
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py {target_dir}
```

인덱스 위치:
- **전체**: `$FORGE_OUTPUTS/.rag-index/` (통합 인덱스 — 기본)
- **정부과제**: `$FORGE_OUTPUTS/09-grants/.rag-index/` (과제 전용)

다른 폴더: `python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py $FORGE_OUTPUTS/01-research/`

### Step 2: 검색 실행

```bash
# 전체 forge-outputs 검색 (기본)
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/search.py "{검색어}" --top-k {N} --mode {hybrid|vector|bm25} --index-dir ${FORGE_OUTPUTS:-~/forge-outputs}/.rag-index

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

### 빌드

```bash
# 최초 빌드
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py ${FORGE_OUTPUTS:-~/forge-outputs}/09-grants

# 문서 추가/변경 후 재빌드
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py ${FORGE_OUTPUTS:-~/forge-outputs}/09-grants --rebuild
```

### 인덱스 정보

```bash
cat ${FORGE_OUTPUTS:-~/forge-outputs}/09-grants/.rag-index/meta.json
```

### 다른 폴더 인덱싱

```bash
# 리서치 폴더
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py ${FORGE_OUTPUTS:-~/forge-outputs}/01-research

# 전체 forge-outputs
python3 ${FORGE_ROOT:-~/forge}/shared/scripts/rag/index.py ${FORGE_OUTPUTS:-~/forge-outputs}
```

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
