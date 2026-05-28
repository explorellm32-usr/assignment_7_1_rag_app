import re

with open("run_queries.sh", "r") as f:
    content = f.read()

# Replace the CUSTOM QUERIES section
start_marker = "echo \"╔══════════════════════════════════════════════════════════╗\"\necho \"║           CUSTOM QUERIES 1–5 (WITH INDEX)                ║\"\necho \"╚══════════════════════════════════════════════════════════╝\""

custom_queries_code = """echo "╔══════════════════════════════════════════════════════════╗"
echo "║           CUSTOM QUERIES 1–5 (WITH INDEX)                ║"
echo "╚══════════════════════════════════════════════════════════╝"

# Pre-populate the index with the necessary papers to ensure the "WITH INDEX" tests pass
run_query "custom_setup" \\
  "Fetch and index the following pages: https://arxiv.org/html/1706.03762v7, https://arxiv.org/html/2201.11903v6, and the Wikipedia page for 'Prompt engineering'."

# C1: Factual Lookup - Attention
run_query "custom_1_with_index" \\
  "What are the three main differences between self-attention and recurrent layers according to the Attention Is All You Need paper?"

# C2: Semantic Recall 1 (Phrase not in chunks verbatim)
run_query "custom_2_with_index" \\
  "Explain how the architecture detailed in the 2017 Google brain paper handles input tokens without using sequential processing."

# C3: Factual Lookup - Chain of Thought
run_query "custom_3_with_index" \\
  "According to the Chain-of-Thought Prompting paper, exactly how does this method improve performance on arithmetic reasoning tasks?"

# C4: Semantic Recall 2 (Phrase not in chunks verbatim)
run_query "custom_4_with_index" \\
  "Based on the indexed documents, which technique allows models to break down complex logic into step-by-step derivations before arriving at the final answer?"

# C5: Cross-paper synthesis
run_query "custom_5_with_index" \\
  "Compare how the ReAct methodology and standard Prompt Engineering instruct the model differently when handling complex tasks."

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         CUSTOM QUERIES 1–5 (WITHOUT INDEX)               ║"
echo "╚══════════════════════════════════════════════════════════╝"

# Clear state completely — agent now has NO corpus in FAISS
clear_state

run_query "custom_1_without_index" \\
  "What are the three main differences between self-attention and recurrent layers according to the Attention Is All You Need paper?"

run_query "custom_2_without_index" \\
  "Explain how the architecture detailed in the 2017 Google brain paper handles input tokens without using sequential processing."

run_query "custom_3_without_index" \\
  "According to the Chain-of-Thought Prompting paper, exactly how does this method improve performance on arithmetic reasoning tasks?"

run_query "custom_4_without_index" \\
  "Based on the indexed documents, which technique allows models to break down complex logic into step-by-step derivations before arriving at the final answer?"

run_query "custom_5_without_index" \\
  "Compare how the ReAct methodology and standard Prompt Engineering instruct the model differently when handling complex tasks."
"""

end_marker = "echo \"\"\necho \"============================================================\"\necho \"  ALL TRACES SAVED to traces/\""

# Use regex to replace everything between start_marker and end_marker
pattern = re.escape(start_marker) + r".*?(?=" + re.escape(end_marker) + r")"
new_content = re.sub(pattern, custom_queries_code, content, flags=re.DOTALL)

with open("run_queries.sh", "w") as f:
    f.write(new_content)
