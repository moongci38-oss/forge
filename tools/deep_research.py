#!/usr/bin/env python3
"""
Deep Research API adapter for Forge skills.

Google's deep-research-preview model uses the Interactions API, NOT generateContent.
This module wraps the async polling pattern into a clean synchronous interface.

Usage (standalone):
    python3 deep_research.py "Your research question here"

Usage (as library):
    from forge.tools.deep_research import research
    result = research("What are the latest advances in WASM runtimes?")
    print(result.report)

Environment:
    GEMINI_API_KEY — required
"""

import os
import sys
import time
import json
import textwrap
from dataclasses import dataclass
from typing import Optional


AGENT_ID = "deep-research-preview-04-2026"
POLL_INTERVAL_SEC = 5
MAX_WAIT_SEC = 600  # 10 min hard cap


@dataclass
class ResearchResult:
    query: str
    report: str
    sources: list[dict]
    elapsed_sec: float
    interaction_id: str

    def save(self, path: str) -> None:
        with open(path, "w", encoding="utf-8") as f:
            f.write(f"# Deep Research: {self.query}\n\n")
            f.write(f"*elapsed: {self.elapsed_sec:.0f}s | interaction: {self.interaction_id}*\n\n")
            f.write(self.report)
            if self.sources:
                f.write("\n\n## Sources\n")
                for s in self.sources:
                    title = s.get("title", "")
                    uri = s.get("uri", "")
                    f.write(f"- [{title}]({uri})\n" if uri else f"- {title}\n")


def _get_client():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise EnvironmentError("[STOP] GEMINI_API_KEY not set")
    try:
        import google.genai as genai
    except ImportError:
        raise ImportError("Run: pip install google-genai")
    return genai.Client(api_key=api_key)


def research(
    query: str,
    max_wait: int = MAX_WAIT_SEC,
    poll_interval: int = POLL_INTERVAL_SEC,
    verbose: bool = False,
) -> ResearchResult:
    """
    Submit a deep research query and poll until complete.

    Args:
        query: Research question or topic.
        max_wait: Maximum seconds to wait (default 600).
        poll_interval: Seconds between polls (default 5).
        verbose: Print progress to stderr.

    Returns:
        ResearchResult with .report (markdown) and .sources (list of dicts).
    """
    client = _get_client()
    start = time.time()

    if verbose:
        print(f"[deep_research] submitting: {query[:80]}...", file=sys.stderr)

    # Interactions API — agent= field, NOT model=
    interaction = client.interactions.create(
        agent=AGENT_ID,
        input={"type": "text", "text": query},
    )
    iid = interaction.interaction_id

    if verbose:
        print(f"[deep_research] interaction_id={iid}, polling...", file=sys.stderr)

    # Poll until terminal state
    while True:
        elapsed = time.time() - start
        if elapsed > max_wait:
            raise TimeoutError(f"Deep research timed out after {max_wait}s (id={iid})")

        state = client.interactions.get(interaction_id=iid)
        status = getattr(state, "state", None) or getattr(state, "status", None)

        if verbose:
            print(f"[deep_research] status={status} elapsed={elapsed:.0f}s", file=sys.stderr)

        if status in ("SUCCEEDED", "COMPLETED", "succeeded", "completed"):
            break
        if status in ("FAILED", "ERROR", "failed", "error"):
            raise RuntimeError(f"Deep research failed (id={iid}): {state}")

        time.sleep(poll_interval)

    # Extract report text and grounding sources
    report = ""
    sources = []

    # Try common output shapes
    output = getattr(state, "output", None) or getattr(state, "response", None)
    if output:
        if hasattr(output, "text"):
            report = output.text
        elif hasattr(output, "content"):
            content = output.content
            if isinstance(content, list):
                for part in content:
                    if hasattr(part, "text"):
                        report += part.text
            elif hasattr(content, "text"):
                report = content.text
        elif isinstance(output, str):
            report = output

    # Grounding metadata
    grounding = (
        getattr(state, "grounding_metadata", None)
        or getattr(state, "groundingMetadata", None)
    )
    if grounding:
        chunks = getattr(grounding, "grounding_chunks", None) or []
        for chunk in chunks:
            web = getattr(chunk, "web", None)
            if web:
                sources.append({
                    "title": getattr(web, "title", ""),
                    "uri": getattr(web, "uri", ""),
                })

    return ResearchResult(
        query=query,
        report=report,
        sources=sources,
        elapsed_sec=time.time() - start,
        interaction_id=iid,
    )


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 deep_research.py \"<query>\" [output.md]", file=sys.stderr)
        sys.exit(1)

    query = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    result = research(query, verbose=True)

    print(f"\n{'='*60}")
    print(f"Query:   {result.query}")
    print(f"Elapsed: {result.elapsed_sec:.0f}s")
    print(f"Sources: {len(result.sources)}")
    print(f"{'='*60}\n")
    print(result.report)

    if output_path:
        result.save(output_path)
        print(f"\n[saved → {output_path}]", file=sys.stderr)


if __name__ == "__main__":
    main()
