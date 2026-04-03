#!/usr/bin/env python3
"""
RAG Indexer — forge-outputs 문서를 벡터 인덱스로 빌드
Usage:
  python3 index.py [target_dir]              # 기존 인덱스 있으면 스킵
  python3 index.py [target_dir] --rebuild    # 전체 재빌드
  python3 index.py --add file1.md file2.docx # 특정 파일만 기존 인덱스에 추가
  python3 index.py [target_dir] --incremental # 변경/추가된 파일만 재인덱싱

기본 대상: $FORGE_OUTPUTS/09-grants/
인덱스 저장: {target_dir}/.rag-index/
"""
import os
import sys
import json
import shutil
import hashlib
from pathlib import Path
from datetime import datetime


def load_env():
    """$FORGE_ROOT/.env에서 환경변수 로드"""
    forge_root = os.environ.get("FORGE_ROOT", str(Path.home() / "forge"))
    env_file = Path(forge_root) / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                key, val = line.split("=", 1)
                os.environ.setdefault(key.strip(), val.strip().strip('"').strip("'"))


def get_embed_model():
    """임베딩 모델 반환 (OpenAI 키 있으면 OpenAI, 없으면 로컬)"""
    use_local = not os.environ.get("OPENAI_API_KEY")
    if use_local:
        from llama_index.embeddings.huggingface import HuggingFaceEmbedding
        print("ℹ️ 로컬 임베딩 모델 사용 (intfloat/multilingual-e5-small)")
        return HuggingFaceEmbedding(model_name="intfloat/multilingual-e5-small"), 384, "multilingual-e5-small"
    else:
        from llama_index.embeddings.openai import OpenAIEmbedding
        return OpenAIEmbedding(model="text-embedding-3-small", dimensions=1536), 1536, "text-embedding-3-small"


def collect_files(target_path):
    """인덱싱 대상 파일 수집"""
    exclude_dirs = {"_converted", "표준계약서", "__pycache__", ".rag-index", "node_modules"}
    exclude_exts = {".css", ".xhtml", ".zip", ".bmp", ".png", ".jpg", ".jpeg", ".gif",
                    ".hwp", ".pptx", ".xlsx", ".drawio", ".eps", ".svg"}

    files = []
    for f in target_path.rglob("*"):
        if f.is_dir():
            continue
        if any(ex in f.parts for ex in exclude_dirs):
            continue
        if f.suffix.lower() in exclude_exts:
            continue
        if f.name.startswith("."):
            continue
        if f.suffix.lower() in {".md", ".txt", ".json", ".docx", ".pdf"}:
            files.append(str(f))
    return files


def file_hash(filepath):
    """파일의 MD5 해시 (변경 감지용)"""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def build_full(target_dir, rebuild=False):
    """전체 빌드 또는 재빌드"""
    from llama_index.core import VectorStoreIndex, StorageContext, Settings, SimpleDirectoryReader
    from llama_index.core.node_parser import SentenceSplitter
    from llama_index.vector_stores.faiss import FaissVectorStore
    import faiss

    target_path = Path(target_dir)
    index_dir = target_path / ".rag-index"

    # 캐시 확인
    if index_dir.exists() and not rebuild:
        meta_file = index_dir / "meta.json"
        if meta_file.exists():
            meta = json.loads(meta_file.read_text())
            print(f"📋 기존 인덱스 발견: {meta.get('doc_count', '?')}개 문서, {meta.get('built_at', '?')}")
            print("   재빌드: python3 index.py --rebuild")
            print("   증분:   python3 index.py --incremental")
            return

    if rebuild and index_dir.exists():
        shutil.rmtree(index_dir)
        print("🗑️ 기존 인덱스 삭제")

    # 파일 수집
    print(f"📂 문서 로딩: {target_dir}")
    files = collect_files(target_path)
    print(f"📄 대상 파일: {len(files)}개")
    if not files:
        print("❌ 인덱싱할 파일 없음")
        sys.exit(1)

    # 로딩
    reader = SimpleDirectoryReader(input_files=files, filename_as_id=True)
    documents = reader.load_data()
    print(f"📖 로드 완료: {len(documents)}개 문서")

    # 임베딩
    embed_model, embed_dim, embed_name = get_embed_model()
    Settings.embed_model = embed_model
    Settings.chunk_size = 512
    Settings.chunk_overlap = 50

    # 청크
    splitter = SentenceSplitter(chunk_size=512, chunk_overlap=50)
    nodes = splitter.get_nodes_from_documents(documents)
    print(f"🔪 청크 분할: {len(nodes)}개 노드")

    # FAISS
    faiss_index = faiss.IndexFlatL2(embed_dim)
    vector_store = FaissVectorStore(faiss_index=faiss_index)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    # 빌드
    print("🔨 인덱스 빌드 중...")
    index = VectorStoreIndex(nodes, storage_context=storage_context, show_progress=True)

    # 저장
    index_dir.mkdir(parents=True, exist_ok=True)
    index.storage_context.persist(persist_dir=str(index_dir))

    # 파일 해시 저장 (증분 빌드용)
    file_hashes = {f: file_hash(f) for f in files}
    (index_dir / "file_hashes.json").write_text(json.dumps(file_hashes, ensure_ascii=False))

    # 메타
    meta = {
        "built_at": datetime.now().isoformat(),
        "target_dir": str(target_dir),
        "doc_count": len(documents),
        "node_count": len(nodes),
        "file_count": len(files),
        "embed_model": embed_name,
        "embed_dim": embed_dim,
        "chunk_size": 512,
    }
    (index_dir / "meta.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False))

    print(f"✅ 인덱스 빌드 완료: {index_dir}")
    print(f"   문서: {len(documents)}개 | 노드: {len(nodes)}개 | 파일: {len(files)}개")


def add_files(file_paths, index_dir=None):
    """특정 파일을 기존 인덱스에 추가"""
    from llama_index.core import VectorStoreIndex, StorageContext, Settings, load_index_from_storage, SimpleDirectoryReader
    from llama_index.core.node_parser import SentenceSplitter
    from llama_index.vector_stores.faiss import FaissVectorStore

    # 인덱스 위치 결정
    if index_dir is None:
        forge_outputs = os.environ.get("FORGE_OUTPUTS", str(Path.home() / "forge-outputs"))
        index_dir = Path(forge_outputs) / ".rag-index"
    else:
        index_dir = Path(index_dir)

    if not index_dir.exists():
        print(f"❌ 인덱스 없음: {index_dir}")
        print("   먼저 python3 index.py [target_dir] 실행")
        sys.exit(1)

    # 파일 검증
    valid_files = []
    for f in file_paths:
        p = Path(f).resolve()
        if p.exists() and p.suffix.lower() in {".md", ".txt", ".json", ".docx", ".pdf"}:
            valid_files.append(str(p))
        else:
            print(f"⚠️ 스킵: {f} (존재하지 않거나 지원 안 되는 형식)")

    if not valid_files:
        print("❌ 추가할 파일 없음")
        sys.exit(1)

    print(f"📄 추가 파일: {len(valid_files)}개")

    # 임베딩 설정
    embed_model, embed_dim, embed_name = get_embed_model()
    Settings.embed_model = embed_model
    Settings.chunk_size = 512
    Settings.chunk_overlap = 50

    # 기존 인덱스 로드
    vector_store = FaissVectorStore.from_persist_dir(str(index_dir))
    storage_context = StorageContext.from_defaults(vector_store=vector_store, persist_dir=str(index_dir))
    index = load_index_from_storage(storage_context)

    # 새 파일 로딩 + 청크
    reader = SimpleDirectoryReader(input_files=valid_files, filename_as_id=True)
    documents = reader.load_data()
    splitter = SentenceSplitter(chunk_size=512, chunk_overlap=50)
    nodes = splitter.get_nodes_from_documents(documents)

    print(f"📖 로드: {len(documents)}개 문서 → {len(nodes)}개 청크")

    # 인덱스에 추가
    print("🔨 인덱스에 추가 중...")
    index.insert_nodes(nodes)

    # 저장
    index.storage_context.persist(persist_dir=str(index_dir))

    # 해시 업데이트
    hash_file = index_dir / "file_hashes.json"
    hashes = json.loads(hash_file.read_text()) if hash_file.exists() else {}
    for f in valid_files:
        hashes[f] = file_hash(f)
    hash_file.write_text(json.dumps(hashes, ensure_ascii=False))

    # 메타 업데이트
    meta_file = index_dir / "meta.json"
    meta = json.loads(meta_file.read_text()) if meta_file.exists() else {}
    meta["built_at"] = datetime.now().isoformat()
    meta["file_count"] = len(hashes)
    meta["last_add"] = [str(Path(f).name) for f in valid_files]
    meta_file.write_text(json.dumps(meta, indent=2, ensure_ascii=False))

    print(f"✅ {len(valid_files)}개 파일 추가 완료")


def incremental_build(target_dir):
    """변경/추가된 파일만 재인덱싱"""
    target_path = Path(target_dir)
    index_dir = target_path / ".rag-index"
    hash_file = index_dir / "file_hashes.json"

    if not index_dir.exists() or not hash_file.exists():
        print("📋 기존 인덱스 없음 → 전체 빌드 실행")
        build_full(target_dir, rebuild=True)
        return

    # 현재 파일 해시 계산
    current_files = collect_files(target_path)
    old_hashes = json.loads(hash_file.read_text())

    # 변경/추가 파일 찾기
    changed = []
    new_files = []
    for f in current_files:
        if f not in old_hashes:
            new_files.append(f)
        elif file_hash(f) != old_hashes[f]:
            changed.append(f)

    removed = [f for f in old_hashes if f not in current_files]

    print(f"📊 증분 분석:")
    print(f"   새 파일: {len(new_files)}개")
    print(f"   변경:    {len(changed)}개")
    print(f"   삭제:    {len(removed)}개")
    print(f"   변경없음: {len(current_files) - len(new_files) - len(changed)}개")

    to_add = new_files + changed

    if not to_add and not removed:
        print("✅ 변경 없음. 인덱스 최신 상태.")
        return

    if removed:
        # 삭제된 파일이 있으면 전체 재빌드 (FAISS는 개별 삭제 미지원)
        print(f"⚠️ 삭제된 파일 {len(removed)}개 → 전체 재빌드 필요")
        build_full(target_dir, rebuild=True)
        return

    if to_add:
        print(f"➕ {len(to_add)}개 파일 추가/갱신")
        # 변경된 파일은 중복 노드가 생길 수 있지만, 검색 품질에 큰 영향 없음
        # 완벽하려면 전체 재빌드, 실용적으로는 추가만
        add_files(to_add, index_dir=str(index_dir))


def main():
    args = sys.argv[1:]

    load_env()

    # --add 모드
    if "--add" in args:
        idx = args.index("--add")
        file_paths = args[idx + 1:]
        # --index-dir 옵션
        index_dir = None
        if "--index-dir" in args:
            idx2 = args.index("--index-dir")
            index_dir = args[idx2 + 1]
            file_paths = [f for f in file_paths if f != index_dir and f != "--index-dir"]
        add_files(file_paths, index_dir)
        return

    # target_dir 결정
    forge_outputs = os.environ.get("FORGE_OUTPUTS", os.path.expanduser("~/forge-outputs"))
    target_dir = forge_outputs + "/09-grants"
    for arg in args:
        if not arg.startswith("--"):
            target_dir = arg
            break

    if not Path(target_dir).exists():
        print(f"❌ 대상 디렉토리 없음: {target_dir}")
        sys.exit(1)

    # --incremental 모드
    if "--incremental" in args:
        incremental_build(target_dir)
        return

    # 전체 빌드
    rebuild = "--rebuild" in args
    build_full(target_dir, rebuild)


if __name__ == "__main__":
    main()
