#!/usr/bin/env bash
# run_traces.sh — captures traces for all 8 base queries (A-H) and 5 custom
# queries (with and without the FAISS index).
#
# Usage:  bash run_traces.sh
# Requires: gateway running (agent7.py starts it automatically)
# Output:  traces/ directory

set -euo pipefail
AGENT="uv run agent7.py"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACES="$DIR/traces"
mkdir -p "$TRACES"

echo "============================================================"
echo "  RAG Assignment — Trace Capture"
echo "  $(date)"
echo "============================================================"

# ── helper ───────────────────────────────────────────────────────────────────
run_query() {
    local label="$1"
    local query="$2"
    local out="$TRACES/${label}.txt"
    echo ""
    echo "━━━ $label ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "QUERY: $query"
    echo "OUTPUT → $out"
    echo "---"
    { echo "QUERY: $query"; echo ""; $AGENT "$query"; } 2>&1 | tee "$out"
    sleep 30
}

clear_state() {
    echo ""
    echo ">>> Clearing state/ (fresh FAISS index and empty artifacts) <<<"
    rm -rf "$DIR/state/"*
}

# ════════════════════════════════════════════════════════════════════════════
# BASE QUERIES A–H
# ════════════════════════════════════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              BASE QUERIES A – H                          ║"
echo "╚══════════════════════════════════════════════════════════╝"

# Query A
run_query "base_A" \
  "Fetch https://en.wikipedia.org/wiki/Claude_Shannon and tell me his birth date, death date, and three key contributions to information theory."

# Query B
run_query "base_B" \
  "Find 3 family-friendly things to do in Tokyo this weekend. Check Saturday's weather forecast there and tell me which one is most appropriate."

# Query C – Run 1
run_query "base_C_run1" \
  "My mom's birthday is 15 May 2026. Remember that and create reminders for two weeks before and on the day."

# Query C – Run 2 (persisted memory)
run_query "base_C_run2" \
  "When is mom's birthday?"

# Query D
run_query "base_D" \
  "Search for \"Python asyncio best practices\", read the top 3 results, and give me a short numbered list of the advice they agree on."

# Query E (RAG: index one paper)
run_query "base_E" \
  "Index the file papers/attention.md and tell me what the three key contributions of the Transformer architecture are according to this paper."

# Query F – Run 1 (index all papers)
clear_state
run_query "base_F_run1" \
  "Index every .md file under papers/. Confirm how many chunks were indexed in total."

# Query F – Run 2 (fresh process, persisted FAISS — DO NOT clear state)
echo ""
echo ">>> Query F Run 2: fresh process but PERSISTED state <<<"
run_query "base_F_run2" \
  "Across the papers I have indexed, what do they say about chain-of-thought reasoning?"

# Query G (semantic recall: credit assignment)
run_query "base_G" \
  "Across these papers, how do they handle the credit assignment problem?"

# Query H (compare two papers on intermediate reasoning)
run_query "base_H" \
  "Compare how the ReAct paper and the Chain-of-Thought paper differ in their treatment of intermediate reasoning."

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         BASE QUERIES A–H COMPLETE                        ║"
echo "╚══════════════════════════════════════════════════════════╝"

# ════════════════════════════════════════════════════════════════════════════
# CUSTOM QUERIES (5 queries × 2 runs = 10 traces)
# ════════════════════════════════════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           CUSTOM QUERIES 1–5 (WITH INDEX)                ║"
echo "╚══════════════════════════════════════════════════════════╝"

# Pre-populate the index with the necessary papers to ensure the "WITH INDEX" tests pass
run_query "custom_setup" \
  "Fetch and index the following pages: https://arxiv.org/html/1706.03762v7, https://arxiv.org/html/2201.11903v6, and the Wikipedia page for 'Prompt engineering'."

# C1: Factual Lookup - Attention
run_query "custom_1_with_index" \
  "What are the three main differences between self-attention and recurrent layers according to the Attention Is All You Need paper?"

# C2: Semantic Recall 1 (Phrase not in chunks verbatim)
run_query "custom_2_with_index" \
  "Explain how the architecture detailed in the 2017 Google brain paper handles input tokens without using sequential processing."

# C3: Factual Lookup - Chain of Thought
run_query "custom_3_with_index" \
  "According to the Chain-of-Thought Prompting paper, exactly how does this method improve performance on arithmetic reasoning tasks?"

# C4: Semantic Recall 2 (Phrase not in chunks verbatim)
run_query "custom_4_with_index" \
  "Based on the indexed documents, which technique allows models to break down complex logic into step-by-step derivations before arriving at the final answer?"

# C5: Cross-paper synthesis
run_query "custom_5_with_index" \
  "Compare how the ReAct methodology and standard Prompt Engineering instruct the model differently when handling complex tasks."

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         CUSTOM QUERIES 1–5 (WITHOUT INDEX)               ║"
echo "╚══════════════════════════════════════════════════════════╝"

# Clear state completely — agent now has NO corpus in FAISS
clear_state

run_query "custom_1_without_index" \
  "What are the three main differences between self-attention and recurrent layers according to the Attention Is All You Need paper?"

run_query "custom_2_without_index" \
  "Explain how the architecture detailed in the 2017 Google brain paper handles input tokens without using sequential processing."

run_query "custom_3_without_index" \
  "According to the Chain-of-Thought Prompting paper, exactly how does this method improve performance on arithmetic reasoning tasks?"

run_query "custom_4_without_index" \
  "Based on the indexed documents, which technique allows models to break down complex logic into step-by-step derivations before arriving at the final answer?"

run_query "custom_5_without_index" \
  "Compare how the ReAct methodology and standard Prompt Engineering instruct the model differently when handling complex tasks."
echo ""
echo "============================================================"
echo "  ALL TRACES SAVED to traces/"
echo "  $(ls "$TRACES"/*.txt | wc -l) files written"
echo "  $(date)"
echo "============================================================"
