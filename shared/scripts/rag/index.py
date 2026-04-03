#!/usr/bin/env python3
"""
RAG Indexer — 문서를 벡터 인덱스로 빌드
Usage:
  python3 index.py [target_dir]                        # 기존 인덱스 있으면 스킵
  python3 index.py [target_dir] --rebuild               # 전체 재빌드
  python3 index.py [target_dir] --incremental           # 변경/추가된 파일만 재인덱싱
  python3 index.py --add file1.md file2.docx            # 특정 파일만 기존 인덱스에 추가
  python3 index.py --workspace                          # 워크스페이스 전체 빌드
  python3 index.py --workspace --incremental            # 워크스페이스 증분 빌드
  python3 index.py --workspace --rebuild                # 워크스페이스 전체 재빌드

기본 대상: $FORGE_OUTPUTS/09-grants/
인덱스 저장: {target_dir}/.rag-index/ (단일) | ~/.rag-workspace-index/ (워크스페이스)
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


def expand_path(path_str):
    """환경변수 + ~ 확장"""
    return str(Path(os.path.expandvars(os.path.expanduser(path_str))).resolve())


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


# 인덱싱 대상 확장자 (소스코드 제외, 문서/설정만)
INCLUDE_EXTS = {".md", ".txt", ".json", ".docx", ".pdf", ".yaml", ".yml", ".toml"}

# 항상 제외할 디렉토리 (빌드 아티팩트, 의존성)
BASE_EXCLUDE_DIRS = {
    "_converted", "표준계약서", "__pycache__", ".rag-index",
    "node_modules", ".git", "Library", "Temp", "obj", "Logs",
    ".next", "dist", "build", "out", ".turbo", "UserSettings",
    ".venv", "venv", ".tox", "target",
}


def collect_files(target_path, extra_exclude_dirs=None):
    """인덱싱 대상 파일 수집

    Args:
        target_path: 스캔할 루트 Path
        extra_exclude_dirs: 추가 제외 디렉토리 (단순 이름 또는 상대 경로 prefix)
    """
    exclude_dirs = BASE_EXCLUDE_DIRS.copy()
    exclude_prefixes = set()

    if extra_exclude_dirs:
        for ex in extra_exclude_dirs:
            if "/" in ex:
                # 슬래시 포함 → 경로 prefix로 처리 (e.g. "06-finance", "08-admin/insurance")
                exclude_prefixes.add(ex.rstrip("/"))
            else:
                exclude_dirs.add(ex)

    files = []
    for f in target_path.rglob("*"):
        if f.is_dir():
            continue
        # 디렉토리 이름 제외
        if any(ex in f.parts for ex in exclude_dirs):
            continue
        # 경로 prefix 제외
        try:
            rel = str(f.relative_to(target_path))
            if any(rel.startswith(prefix) for prefix in exclude_prefixes):
                continue
        except ValueError:
            pass
        if f.name.startswith("."):
            continue
        if f.suffix.lower() in INCLUDE_EXTS:
            files.append(str(f))
    return files


def collect_files_workspace(sources):
    """워크스페이스 전체 파일 수집"""
    all_files = []
    for source in sources:
        source_path = Path(expand_path(source["path"]))
        if not source_path.exists():
            print(f"  ⚠️ 스킵 (경로 없음): {source['path']}")
            continue
        extra_excludes = source.get("exclude_dirs", [])
        files = collect_files(source_path, extra_exclude_dirs=extra_excludes)
        label = source.get("note", source["path"])
        print(f"  📂 {label}: {len(files)}개 파일")
        all_files.extend(files)
    # 중복 제거 (여러 소스가 겹칠 경우 대비)
    return list(dict.fromkeys(all_files))


def load_workspace_config():
    """workspace.json 로드"""
    forge_root = os.environ.get("FORGE_ROOT", str(Path.home() / "forge"))
    config_path = Path(forge_root) / "shared/scripts/rag/workspace.json"
    if not config_path.exists():
        print(f"❌ workspace.json 없음: {config_path}")
        sys.exit(1)
    return json.loads(config_path.read_text())


def file_hash(filepath):
    """파일의 MD5 해시 (변경 감지용)"""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def _do_build(files, index_dir, meta_extra=None):
    """공통 빌드 로직 (build_full / workspace_full_build 공유)"""
    from llama_index.core import VectorStoreIndex, StorageContext, Settings, SimpleDirectoryReader
    from llama_index.core.node_parser import SentenceSplitter
    from llama_index.vector_stores.faiss import FaissVectorStore
    import faiss

    reader = SimpleDirectoryReader(input_files=files, filename_as_id=True)
    documents = reader.load_data()
    print(f"📖 로드 완료: {len(documents)}개 문서")

    embed_model, embed_dim, embed_name = get_embed_model()
    Settings.embed_model = embed_model
    Settings.chunk_size = 512
    Settings.chunk_overlap = 50

    splitter = SentenceSplitter(chunk_size=512, chunk_overlap=50)
    nodes = splitter.get_nodes_from_documents(documents)
    print(f"🔪 청크 분할: {len(nodes)}개 노드")

    faiss_index = faiss.IndexFlatL2(embed_dim)
    vector_store = FaissVectorStore(faiss_index=faiss_index)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    print("🔨 인덱스 빌드 중...")
    index = VectorStoreIndex(nodes, storage_context=storage_context, show_progress=True)

    index_dir.mkdir(parents=True, exist_ok=True)
    index.storage_context.persist(persist_dir=str(index_dir))

    file_hashes = {f: file_hash(f) for f in files}
    (index_dir / "file_hashes.json").write_text(json.dumps(file_hashes, ensure_ascii=False))

    meta = {
        "built_at": datetime.now().isoformat(),
        "doc_count": len(documents),
        "node_count": len(nodes),
        "file_count": len(files),
        "embed_model": embed_name,
        "embed_dim": embed_dim,
        "chunk_size": 512,
    }
    if meta_extra:
        meta.update(meta_extra)
    (index_dir / "meta.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False))

    print(f"✅ 인덱스 완료: {index_dir}")
    print(f"   문서: {len(documents)}개 | 노드: {len(nodes)}개 | 파일: {len(files)}개")
    return index


def build_full(target_dir, rebuild=False):
    """단일 디렉토리 전체 빌드"""
    target_path = Path(target_dir)
    index_dir = target_path / ".rag-index"

    if index_dir.exists() and not rebuild:
        meta_file = index_dir / "meta.json"
        if meta_file.exists():
            meta = json.loads(meta_file.read_text())
            print(f"📋 기존 인덱스 발견: {meta.get('file_count', '?')}개 파일, {meta.get('built_at', '?')}")
            print("   재빌드: python3 index.py --rebuild")
            print("   증분:   python3 index.py --incremental")
            return

    if rebuild and index_dir.exists():
        shutil.rmtree(index_dir)
        print("🗑️ 기존 인덱스 삭제")

    print(f"📂 문서 수집: {target_dir}")
    files = collect_files(target_path)
    print(f"📄 대상 파일: {len(files)}개")
    if not files:
        print("❌ 인덱싱할 파일 없음")
        sys.exit(1)

    _do_build(files, index_dir, meta_extra={"target_dir": str(target_dir)})


def workspace_full_build(rebuild=False):
    """워크스페이스 전체 빌드"""
    config = load_workspace_config()
    index_dir = Path(expand_path(config["index_dir"]))

    if index_dir.exists() and not rebuild:
        meta_file = index_dir / "meta.json"
        if meta_file.exists():
            meta = json.loads(meta_file.read_text())
            print(f"📋 기존 워크스페이스 인덱스: {meta.get('file_count', '?')}개 파일, {meta.get('built_at', '?')}")
            print("   재빌드: python3 index.py --workspace --rebuild")
            print("   증분:   python3 index.py --workspace --incremental")
            return

    if rebuild and index_dir.exists():
        shutil.rmtree(index_dir)
        print("🗑️ 기존 인덱스 삭제")

    print(f"📂 워크스페이스 파일 수집 중...")
    files = collect_files_workspace(config["sources"])
    print(f"📄 총 파일: {len(files)}개")
    if not files:
        print("❌ 인덱싱할 파일 없음")
        sys.exit(1)

    _do_build(files, index_dir, meta_extra={
        "mode": "workspace",
        "sources": [s.get("note", s["path"]) for s in config["sources"]],
    })


def add_files(file_paths, index_dir=None):
    """특정 파일을 기존 인덱스에 추가"""
    from llama_index.core import VectorStoreIndex, StorageContext, Settings, load_index_from_storage, SimpleDirectoryReader
    from llama_index.core.node_parser import SentenceSplitter
    from llama_index.vector_stores.faiss import FaissVectorStore

    if index_dir is None:
        forge_outputs = os.environ.get("FORGE_OUTPUTS", str(Path.home() / "forge-outputs"))
        index_dir = Path(forge_outputs) / ".rag-index"
    else:
        index_dir = Path(index_dir)

    if not index_dir.exists():
        print(f"❌ 인덱스 없음: {index_dir}")
        print("   먼저 python3 index.py [target_dir] 실행")
        sys.exit(1)

    valid_files = []
    for f in file_paths:
        p = Path(f).resolve()
        if p.exists() and p.suffix.lower() in INCLUDE_EXTS:
            valid_files.append(str(p))
        else:
            print(f"⚠️ 스킵: {f} (존재하지 않거나 지원 안 되는 형식)")

    if not valid_files:
        print("❌ 추가할 파일 없음")
        sys.exit(1)

    print(f"📄 추가 파일: {len(valid_files)}개")

    embed_model, embed_dim, _ = get_embed_model()
    Settings.embed_model = embed_model
    Settings.chunk_size = 512
    Settings.chunk_overlap = 50

    vector_store = FaissVectorStore.from_persist_dir(str(index_dir))
    storage_context = StorageContext.from_defaults(vector_store=vector_store, persist_dir=str(index_dir))
    index = load_index_from_storage(storage_context)

    reader = SimpleDirectoryReader(input_files=valid_files, filename_as_id=True)
    documents = reader.load_data()
    splitter = SentenceSplitter(chunk_size=512, chunk_overlap=50)
    nodes = splitter.get_nodes_from_documents(documents)

    print(f"📖 로드: {len(documents)}개 → {len(nodes)}개 청크")
    print("🔨 인덱스에 추가 중...")
    index.insert_nodes(nodes)
    index.storage_context.persist(persist_dir=str(index_dir))

    hash_file = index_dir / "file_hashes.json"
    hashes = json.loads(hash_file.read_text()) if hash_file.exists() else {}
    for f in valid_files:
        hashes[f] = file_hash(f)
    hash_file.write_text(json.dumps(hashes, ensure_ascii=False))

    meta_file = index_dir / "meta.json"
    meta = json.loads(meta_file.read_text()) if meta_file.exists() else {}
    meta["built_at"] = datetime.now().isoformat()
    meta["file_count"] = len(hashes)
    meta["last_add"] = [str(Path(f).name) for f in valid_files]
    meta_file.write_text(json.dumps(meta, indent=2, ensure_ascii=False))

    print(f"✅ {len(valid_files)}개 파일 추가 완료")


def _incremental_core(files_fn, index_dir):
    """증분 빌드 공통 로직"""
    hash_file = index_dir / "file_hashes.json"

    current_files = files_fn()
    current_set = set(current_files)
    old_hashes = json.loads(hash_file.read_text())

    new_files = [f for f in current_files if f not in old_hashes]
    changed = [f for f in current_files if f in old_hashes and file_hash(f) != old_hashes[f]]
    removed = [f for f in old_hashes if f not in current_set]

    print(f"📊 증분 분석: 새 {len(new_files)}개 | 변경 {len(changed)}개 | 삭제 {len(removed)}개 | 유지 {len(current_files)-len(new_files)-len(changed)}개")

    to_add = new_files + changed

    if not to_add and not removed:
        print("✅ 변경 없음. 인덱스 최신 상태.")
        return False  # 재빌드 필요 없음

    if removed:
        print(f"⚠️ 삭제된 파일 {len(removed)}개 → 전체 재빌드 필요")
        return True  # 전체 재빌드 필요

    print(f"➕ {len(to_add)}개 파일 추가/갱신")
    add_files(to_add, index_dir=str(index_dir))
    return False


def incremental_build(target_dir):
    """단일 디렉토리 증분 빌드"""
    target_path = Path(target_dir)
    index_dir = target_path / ".rag-index"
    hash_file = index_dir / "file_hashes.json"

    if not index_dir.exists() or not hash_file.exists():
        print("📋 기존 인덱스 없음 → 전체 빌드 실행")
        build_full(target_dir, rebuild=True)
        return

    needs_rebuild = _incremental_core(
        lambda: collect_files(target_path),
        index_dir,
    )
    if needs_rebuild:
        build_full(target_dir, rebuild=True)


def workspace_incremental():
    """워크스페이스 증분 빌드"""
    config = load_workspace_config()
    index_dir = Path(expand_path(config["index_dir"]))
    hash_file = index_dir / "file_hashes.json"

    if not index_dir.exists() or not hash_file.exists():
        print("📋 기존 워크스페이스 인덱스 없음 → 전체 빌드 실행")
        workspace_full_build(rebuild=True)
        return

    print(f"📂 워크스페이스 파일 스캔 중...")
    needs_rebuild = _incremental_core(
        lambda: collect_files_workspace(config["sources"]),
        index_dir,
    )
    if needs_rebuild:
        workspace_full_build(rebuild=True)


def main():
    args = sys.argv[1:]
    load_env()

    # --workspace 모드
    if "--workspace" in args:
        if "--incremental" in args:
            workspace_incremental()
        elif "--rebuild" in args:
            workspace_full_build(rebuild=True)
        else:
            workspace_full_build(rebuild=False)
        return

    # --add 모드
    if "--add" in args:
        idx = args.index("--add")
        file_paths = args[idx + 1:]
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

    if "--incremental" in args:
        incremental_build(target_dir)
        return

    build_full(target_dir, rebuild="--rebuild" in args)


if __name__ == "__main__":
    main()
