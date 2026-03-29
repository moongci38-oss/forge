#!/usr/bin/env python3
"""
RAG Search — 벡터 + BM25 하이브리드 검색
Usage: python3 search.py "검색어" [--top-k N] [--index-dir DIR]

예시:
  python3 search.py "투자 유치 전략"
  python3 search.py "TagHub 특허 기술 차별점" --top-k 10
  python3 search.py "시장 규모" --index-dir ~/forge-outputs/09-grants/.rag-index
"""
import os
import sys
import json
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="RAG 하이브리드 검색")
    parser.add_argument("query", help="검색어")
    parser.add_argument("--top-k", type=int, default=5, help="결과 수 (기본: 5)")
    parser.add_argument("--index-dir", default=os.path.expanduser("~/forge-outputs/09-grants/.rag-index"),
                        help="인덱스 디렉토리")
    parser.add_argument("--mode", choices=["vector", "bm25", "hybrid"], default="hybrid",
                        help="검색 모드 (기본: hybrid)")
    parser.add_argument("--json", action="store_true", help="JSON 출력")
    args = parser.parse_args()

    index_dir = Path(args.index_dir)
    if not index_dir.exists():
        print(f"❌ 인덱스 없음: {index_dir}")
        print("   먼저 python3 index.py 실행")
        sys.exit(1)

    # --- 환경변수 로드 ---
    env_file = Path.home() / "forge" / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                key, val = line.split("=", 1)
                os.environ.setdefault(key.strip(), val.strip().strip('"').strip("'"))

    # --- 패키지 임포트 ---
    try:
        from llama_index.core import (
            VectorStoreIndex,
            StorageContext,
            Settings,
            load_index_from_storage,
        )
        from llama_index.embeddings.openai import OpenAIEmbedding
        from llama_index.vector_stores.faiss import FaissVectorStore
    except ImportError as e:
        print(f"❌ 패키지 미설치: {e}")
        sys.exit(1)

    # --- 임베딩 설정 (인덱스 빌드 시 사용한 모델과 동일해야 함) ---
    meta_file = index_dir / "meta.json"
    use_local = True
    if meta_file.exists():
        meta = json.loads(meta_file.read_text())
        if meta.get("embed_model") == "text-embedding-3-small":
            use_local = False

    if use_local:
        from llama_index.embeddings.huggingface import HuggingFaceEmbedding
        Settings.embed_model = HuggingFaceEmbedding(model_name="intfloat/multilingual-e5-small")
    else:
        Settings.embed_model = OpenAIEmbedding(model="text-embedding-3-small", dimensions=1536)

    # --- 인덱스 로드 ---
    vector_store = FaissVectorStore.from_persist_dir(str(index_dir))
    storage_context = StorageContext.from_defaults(
        vector_store=vector_store,
        persist_dir=str(index_dir),
    )
    index = load_index_from_storage(storage_context)

    # --- 검색 ---
    if args.mode == "hybrid":
        # 하이브리드: 벡터 + BM25 동시 검색 → 결과 병합
        try:
            from llama_index.retrievers.bm25 import BM25Retriever

            vector_retriever = index.as_retriever(similarity_top_k=args.top_k)
            bm25_retriever = BM25Retriever.from_defaults(
                index=index,
                similarity_top_k=args.top_k,
            )

            # 벡터 검색
            vector_results = vector_retriever.retrieve(args.query)
            # BM25 검색
            bm25_results = bm25_retriever.retrieve(args.query)

            # 결과 병합 (중복 제거, 점수 합산)
            seen = {}
            for node in vector_results:
                node_id = node.node.node_id
                seen[node_id] = {
                    "node": node,
                    "vector_score": node.score or 0,
                    "bm25_score": 0,
                }
            for node in bm25_results:
                node_id = node.node.node_id
                if node_id in seen:
                    seen[node_id]["bm25_score"] = node.score or 0
                else:
                    seen[node_id] = {
                        "node": node,
                        "vector_score": 0,
                        "bm25_score": node.score or 0,
                    }

            # 하이브리드 점수 (0.7 벡터 + 0.3 BM25)
            for v in seen.values():
                v["hybrid_score"] = 0.7 * v["vector_score"] + 0.3 * v["bm25_score"]

            sorted_results = sorted(seen.values(), key=lambda x: x["hybrid_score"], reverse=True)
            results = [(v["node"], v["hybrid_score"]) for v in sorted_results[:args.top_k]]

        except ImportError:
            # BM25 미설치 → 벡터만
            print("⚠️ BM25 미설치, 벡터 검색만 사용")
            retriever = index.as_retriever(similarity_top_k=args.top_k)
            raw_results = retriever.retrieve(args.query)
            results = [(r, r.score) for r in raw_results]
    else:
        retriever = index.as_retriever(similarity_top_k=args.top_k)
        raw_results = retriever.retrieve(args.query)
        results = [(r, r.score) for r in raw_results]

    # --- 출력 ---
    if args.json:
        output = []
        for node, score in results:
            output.append({
                "score": round(score, 4) if score else 0,
                "file": node.node.metadata.get("file_name", "unknown"),
                "file_path": node.node.metadata.get("file_path", "unknown"),
                "text": node.node.text[:500],
            })
        print(json.dumps(output, indent=2, ensure_ascii=False))
    else:
        print(f"\n🔍 검색: \"{args.query}\" (모드: {args.mode}, top-{args.top_k})\n")
        print("=" * 80)
        for i, (node, score) in enumerate(results, 1):
            file_path = node.node.metadata.get("file_path", "unknown")
            # 경로 축약
            short_path = file_path.replace(os.path.expanduser("~/forge-outputs/09-grants/"), "")
            text_preview = node.node.text[:300].replace("\n", " ")
            score_str = f"{score:.4f}" if score else "N/A"

            print(f"\n#{i} [점수: {score_str}]")
            print(f"📄 {short_path}")
            print(f"   {text_preview}...")
            print("-" * 80)


if __name__ == "__main__":
    main()
