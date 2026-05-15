---
name: bootstrap
description: Use when the user asks to "bootstrap the agentic engineering workflow", "set up the team workflow", "scaffold AGENTS.md and the sprint process", or invokes /agentic-engineering-workflow:bootstrap directly. Walks a workspace through introspection → classification confirmation → batched questions → scaffolding (AGENTS.md, CLAUDE.md shim, ADR placeholder, memory bootstrap) → tracker setup (Bug Triage, Ideas, label taxonomy) → final report. Works for greenfield projects or layering onto existing ones.
---

# Bootstrap the Agentic Engineering Workflow

## When to invoke

The user wants to install the team workflow in their current workspace. Triggers include:

- Direct invocation: `/agentic-engineering-workflow:bootstrap`
- Natural language: "bootstrap the workflow", "set me up", "scaffold the team process", "install the DoE workflow here", "set up AGENTS.md + sprint process", etc.

Do NOT invoke this skill for:
- `/defect <description>` — use the `defect` skill.
- `/idea <description>` — use the `idea` skill.
- Single-file changes inside an already-bootstrapped project — just do the work.

## What to do

1. **Read the full spec.** Open `references/team-process-spec.md` in this skill's directory and read it end-to-end. It contains the complete workflow (roles, tracker hierarchy, sprint flow, ADR system, contract-lock discipline, templates).

2. **Locate the "⌜ PROMPT TO PASTE ⌟" section** in the spec. The contents of that fenced code block are your execution instructions for the bootstrap.

3. **Execute the bootstrap.** Run through the five phases in order:
   - **A. INTROSPECT** the workspace (file tree, git host, tracker MCP, git identity, existing config). Classify as GREENFIELD / EXISTING-COMPATIBLE / EXISTING-DIVERGENT / AMBIGUOUS.
   - **B. ASK** one batched round of questions via `AskUserQuestion` (Claude Code) or your agent's equivalent batched-question tool. Lead with classification confirmation; only ask what you couldn't detect.
   - **C. SCAFFOLD** files (AGENTS.md, CLAUDE.md shim, per-module AGENTS.md stubs, ADR placeholder, memory bootstrap, `.gitignore` entries). Adapt templates to the workspace's actual layout — don't force-fit.
   - **D. SET UP THE TRACKER** (Bug Triage project, Ideas/Backlog project, label taxonomy, initial M0/Sprint document).
   - **E. REPORT** a clean summary: files created, tracker objects created, manual follow-ups, next prompt to run.

4. **Install the slash-command skills inline** as part of step C. The `/defect` and `/idea` skills are already installed if the user installed this plugin — verify they're available. If the user is on a manual install (not the plugin), copy the `/defect` and `/idea` skill content from §11 of the spec into `.claude/skills/defect/SKILL.md` and `.claude/skills/idea/SKILL.md` in the workspace, with the tracker MCP prefix + project IDs filled in from step D.

## Universal rules to enforce throughout

- **`assignee: null` on every tracker call** unless the ticket title is prefixed with a specific human's name. Linear and several other trackers auto-assign to the caller if assignee is omitted — single most common footgun.
- **Don't print secrets.** If you encounter `.env` contents, API keys, tokens — flag and move on.
- **Don't fabricate.** If you can't connect to the tracker, can't find the spec, or can't determine something — stop and tell the user, don't pretend.
- **Don't edit AGENTS.md or other skill files mid-execution** to "fix" things you notice. Surface them as proposed follow-ups so the user can approve rule changes explicitly.

## After running

- Save what you learned about the workspace into auto-memory (project state, tracker references, user identity).
- Output the exact next prompt the user should run.
- Do NOT auto-start the first sprint. Bootstrap ends; sprint planning starts on the user's explicit go-ahead.
