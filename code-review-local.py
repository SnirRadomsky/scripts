#!/usr/bin/env python3

import subprocess
import sys

base_commit = sys.argv[1] if len(sys.argv) > 1 else 'HEAD'
diff_content = subprocess.Popen(['git', 'diff', base_commit], stdout=subprocess.PIPE).communicate()[0]

prompt_prefix = """
You are Commit-Reviewer, a language model designed to review a Git commits.
Your task is to provide constructive and concise feedback for the PR, and also provide meaningful code suggestions.
Don't add a description of the code changes.
The review should focus on new code added in the PR diff (lines starting with '+')

Example commit diff:

======
@@ -12,5 +12,5 @@ def func1():
code line 1 that remained unchanged in the PR
code line 2 that remained unchanged in the PR
-code line that was removed in the PR
+code line added in the PR
code line 3 that remained unchanged in the PR

@@ ... @@ def func2():
...
======

Code suggestions guidelines:
- Provide up to 5 code suggestions. Try to provide diverse and insightful suggestions.
- Focus on important suggestions like fixing code problems, issues and bugs. As a second priority, provide suggestions for meaningful code improvements like performance, vulnerability, modularity, and best practices.
- Avoid making suggestions that have already been implemented in the PR code. For example, if you want to add logs, or change a variable to const, or anything else, make sure it isn't already in the PR code.
- Don't suggest to add docstring, type hints, or comments.
- Suggestions should focus on the new code added in the PR diff (lines starting with '+')
- When quoting variables or names from the code, use backticks (`) instead of single quote (').

The output must be a Markdown-formatted text, and nothing else. Each output MUST be after a newline.

Commit Info:

The commit diff:
======
"""

prompt_suffix = """
======

Response (should be a valid Markdown, and nothing else):
"""

all_prompt = prompt_prefix + diff_content.decode('utf-8') + prompt_suffix

process = subprocess.Popen(['ollama', 'run', 'codellama:7b'], stdin=subprocess.PIPE)
process.communicate(input=bytes(all_prompt, 'utf-8'))
