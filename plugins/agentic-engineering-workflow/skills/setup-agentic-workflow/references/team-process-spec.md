# Agentic Engineering Workflow — Spec

> A portable, opinionated workflow for software teams where an AI coding agent is part of the team. Two ways to adopt it: install the [Claude Code plugin](#install-via-plugin-recommended) (one command, everything scaffolded), or drop this single `.md` file into a workspace and paste the [setup prompt](#-prompt-to-paste-) into a fresh agent session.
>
> Tracker-agnostic, stack-agnostic, agent-agnostic. Works with Claude Code natively, with Codex and other agents via manual install or drop-in spec. Solo founders, small teams, multi-agent setups.

---

## What this is

A bundle of opinions about how to run a software project where an AI coding agent is one of the contributors:

- **Roles are separated.** A human (or humans) owns **WHAT** to build. The agent owns **HOW**. When the two disagree on WHAT, the human wins. HOW guidance is incorporated.
- **Cross-cutting decisions get reviewed by 2-3 orthogonal critics in parallel** (CTO subagent for tech, CPO for product, CDO for design — pick whichever fit the project). The triad reviews proposals before they land; their feedback is mandatory input, not optional.
- **The issue tracker is the source of truth.** Not chat, not memory, not commits. Whatever tracker the team uses (Linear, GitHub Issues, Jira, Notion — pick one) becomes the single dashboard. The agent updates it as work progresses.
- **Decisions leave a paper trail (ADRs).** Anything touching multiple modules / repos gets a numbered Architecture Decision Record.
- **Contract lock + phase milestones.** Sprints have explicit phases (Contract Lock → Core Build → UX → Integration → Beta Readiness). Contracts between layers freeze at end-of-Day-2.
- **Bug + idea capture is fire-and-forget.** `/defect` and `/idea` slash commands take a one-liner, infer everything (priority, repro, hypothesis, cross-repo scope), file a ticket with no follow-up questions. Zero ceremony during testing.
- **Verification gates the close.** Sprints don't close while a deploy is failing or verification is "deferred."

### Good fit for

- Solo founder + AI agent (agent executes; human approves)
- Small teams (2-5 humans) where the agent is a peer / coordinator
- Multi-platform products (web + mobile + backend) where contracts between layers matter
- Single-platform projects (web-only, backend-only) — just skip the platforms that don't apply
- Open-source projects with mixed human/AI contributors

### Probably not a fit

- Research / exploratory code where ADR overhead slows you down (use this after the prototype hardens)
- Throwaway prototypes
- Projects that already have a deeply embedded workflow you don't want to disrupt

---

## Install via Claude Code plugin (recommended for Claude Code users)

The workflow is published as a Claude Code plugin. One-time install:

```
/plugin marketplace add Pixel-Perfect-Apps/agentic-engineering-workflow
/plugin install agentic-engineering-workflow@agentic-engineering-workflow
```

After install, three things become available in any workspace:
- `/defect` and `/idea` slash commands for fire-and-forget bug + idea capture.
- A **setup-agentic-workflow** skill that scaffolds AGENTS.md / tracker / ADR / memory for a workspace. Invoke it by asking your agent to "set up the agentic engineering workflow" or directly via `/agentic-engineering-workflow:setup-agentic-workflow`.
- This full spec, available as a reference doc inside the plugin.

## Install for Codex and other SKILL.md-compatible agents

Copy the skills folder into your project's `.agents/skills/` directory:

```bash
git clone --depth 1 https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow /tmp/aew
mkdir -p .agents/skills && cp -r /tmp/aew/plugins/agentic-engineering-workflow/skills/* .agents/skills/
rm -rf /tmp/aew
```

The skill content is generic — it works for any agent that follows SKILL.md-style instructions.

## Install via drop-in spec (any agent, no plugin install)

Don't want a plugin install? Drop just this `.md` file into your workspace root and paste the [prompt block](#-prompt-to-paste-) below into a fresh agent session. The agent will read the file end-to-end and execute the setup. You miss the `/defect` and `/idea` slash commands but the rest works identically.

## Prerequisites (any path)

- An issue-tracker connection: Linear MCP, GitHub via `gh` CLI, Jira via its MCP, or any tracker with a queryable API.
- Git access (`gh auth login` or equivalent).
- Whatever CLIs your stack needs (npm, gradle, xcodebuild, vercel, etc.).

---

## ⌜ PROMPT TO PASTE ⌟

> Copy this entire block verbatim into a fresh agent session. If you've installed the Claude Code plugin, you can invoke the setup-agentic-workflow skill directly instead; this prompt is for manual installs where you dropped the spec `.md` into the workspace yourself, or for agents that don't support Claude Code plugins.

```text
You are taking on the "Director of Engineering" (DoE) role for this project.
We follow a specific opinionated workflow that I want you to set up here,
end-to-end, in one pass.

Read the agentic engineering workflow spec end-to-end before doing anything
else. The spec lives either at `team-process-spec.md` in this workspace
(manual install), or inside the installed plugin's setup-agentic-workflow skill
references folder. If you can't find it, ask me for the path. It contains
the full workflow spec plus templates and embedded slash-command skills.

Then do these steps in order. Do not stop for confirmation between steps
unless you hit something genuinely blocking. If you hit a blocker, stop and
tell me what's wrong — don't fabricate IDs, don't pretend you ran something
you couldn't.

A. INTROSPECT THE WORKSPACE
   Detect what you can without asking. Walk the actual file tree of the
   current folder (and its sibling folders if you're at the parent of a
   potential multi-repo layout). DO NOT skip this — the rest of the
   workflow depends on you understanding what you're looking at.
   
   What to look at — FILESYSTEM:
   - Folder contents at the top level. Is it empty, near-empty (only
     dotfiles), or does it contain real code / repos / config?
   - Workspace layout: single repo, multi-repo monorepo (sibling folders
     each with their own `.git`), workspace-style monorepo (root
     `package.json` with `workspaces`, Turborepo `turbo.json`, Nx
     `nx.json`, pnpm-workspace.yaml), or something else.
   - Git hosting: `gh auth status` for GitHub, `glab auth status` for
     GitLab, etc. Capture the org/group + repo names.
   - Local git identity: `git config user.name` + `git config user.email`.
   - Existing config files that hint at the stack: package.json,
     Cargo.toml, pyproject.toml, Package.swift, build.gradle, go.mod,
     Gemfile, etc.
   - CI provider: .github/workflows, .gitlab-ci.yml, circleci config, etc.
   - Deploy target: vercel.json, fly.toml, render.yaml, netlify.toml,
     k8s/, Dockerfile.
   - Existing AGENTS.md / CLAUDE.md / .claude/ / .agents/ — DO NOT
     clobber prior setup; merge or back up before overwriting.
   - DO NOT print any secrets you encounter — flag them and move on.

   What to look at — DOCS STORAGE:
   - Existing in-repo docs folders: `docs/`, `documentation/`, `wiki/`,
     and especially `docs/decisions/` or `decisions/` (ADRs).
   - Existing dedicated docs repo if multi-repo monorepo: look for
     `<project>-docs`, `<project>-handbook`, `docs`, etc. as sibling
     folders or in the same GitHub org.
   - Existing GitHub Wiki on any repo (`gh api repos/<owner>/<repo> --jq
     '.has_wiki'`).
   - Whether the tracker has a documents feature in active use (Linear
     teams + projects can have documents; check `list_documents` if the
     MCP supports it).
   - Whether there's a `.docx` / `.pdf` / `.md` already at a top-level
     `PRD.docx` or `ARCHITECTURE.md` — these signal where the team
     already stashes long-form docs.

   What to look at — WORKFLOW INSTALLATION STATE (CRITICAL):
   Another collaborator may already have run the setup. Detect this
   before writing anything. Check for these signatures:
   - Root `AGENTS.md` contains the section heading `## Tracker
     destinations` (this is the **current-format marker** — it's the
     section /defect and /idea read from). If present, the install is
     current-format and at least partially complete.
   - **Legacy-format signature:** AGENTS.md contains an older section
     heading like `## Tracker — Linear` (or similar) with concrete
     team / project / workspace IDs but NO `## Tracker destinations`
     section. This signals a complete v0.1.x install in the old
     format — NOT a partial install. It should route to UPGRADE
     mode (via the v0.2.0 migration) rather than COMPLETE-PARTIAL.
   - A `*/decisions/0001-*.md` ADR exists noting workflow adoption
     (filename may be `0001-bootstrap.md` for v0.1.x installs or
     `0001-setup.md` for v0.2.0+ installs — both count).
   - Tracker has 3+ of the canonical labels co-existing (`kind:spec`,
     `sprint:s1`, `area:*`, `alarm:deploy-failure`, `gate:beta-ready`)
     — these together strongly suggest the workflow has been adopted
     there.
   - Per-repo `AGENTS.md` files exist at module boundaries (in
     multi-repo or workspace-monorepo layouts).
   - The tracker has projects matching workflow names ("Bug Triage",
     "Ideas / Backlog", or specifically configured destinations).
   
   Classify the **install state**:
   - **FRESH** — no signatures found. Use the full setup flow.
   - **LEGACY** — legacy-format signature present (older AGENTS.md
     section heading, or older ADR filename) but current-format
     marker missing. This is a complete v0.1.x install, not a
     half-finished one. Default version: `0.1.x`. Route to UPGRADE
     mode — the v0.2.0 migration handles the section rename + new
     fields, then later migrations apply.
   - **PARTIAL** — current-format signatures present but key fields
     missing (e.g., "Tracker destinations" section exists but lacks
     a `/defect` mode, or only some collaborator-owned files exist).
     Someone started a current-format install but didn't finish.
   - **INSTALLED** — current-format signatures all present + version
     field reads ≤ current. Another collaborator has fully set this
     up; you're likely joining a project that already uses this
     workflow. If installed-version < current-plugin-version, offer
     UPGRADE in §B Q1.

   For LEGACY / PARTIAL / INSTALLED, capture **what's already
   configured** so §B can offer concrete sync/onboarding/upgrade
   options. Don't overwrite — read.

   What to look at — ISSUE TRACKER:
   - Tracker MCP availability: try in this order — Linear
     (mcp__linear__*, mcp__plugin_linear_linear__*, mcp__claude_ai_Linear__*),
     Jira (mcp__atlassian__*, mcp__jira__*), Notion (mcp__notion__*),
     Plain GitHub Issues via `gh issue`. Use whichever responds first.
   - If a tracker is available, **read its current state** (don't write
     yet). Capture:
       - Teams / workspaces / projects (names + IDs).
       - Whether the tracker has a built-in "Triage" inbox (Linear teams
         do; check `mcp__linear__get_team` for `triageEnabled` — but
         see caveat below if the MCP doesn't surface this field).
       - Active sprints / cycles / iterations / milestones / fix-versions
         (names + dates).
       - Existing labels / tags / components / issue types.
       - Issue ID prefix in use (PROJ-NN, etc.) — derive from any recent
         issue.
       - Rough activity level (how many open issues per project). High
         activity = the team is actively using this tracker; low/none =
         it might be inherited or unused.
   - **`triageEnabled` fallback:** if `get_team` doesn't return
     `triageEnabled` (some Linear MCP builds don't expose it), fall
     back in order: (1) check the team's URL pattern — Linear teams
     with Triage have a `/triage` route accessible; (2) ask the user
     in §B; (3) default to assuming Triage is enabled (Linear's
     default for new teams). Surface the assumption in the §E report
     so the user can correct it if wrong.
   - This inspection feeds the §B questions about destinations + cadence.
     **Do not write anything to the tracker in this phase.** Inspection
     is read-only.

   Then **classify the workspace** into one of these scenarios. This
   classification drives every downstream decision:
   
   i.   GREENFIELD — empty or near-empty folder; no real code yet. The
        user wants to start a new project from scratch and adopt the
        spec's conventions wholesale. Adopt the recommended layout
        (sibling-repo monorepo or single-repo) as-is.
   
   ii.  EXISTING-COMPATIBLE — existing project whose structure already
        aligns reasonably well with one of the layouts the spec
        describes. Examples: a single Next.js repo; a Turborepo-style
        monorepo; a parent folder with sibling repos. Layer the
        workflow on top of the existing structure; do NOT reorganize.
   
   iii. EXISTING-DIVERGENT — existing project whose layout doesn't map
        cleanly to either spec layout. Examples: a "kitchen sink" repo
        with code + docs + scripts all at root; an unusual workspace
        layout; multiple repos in non-sibling positions. The workflow
        can still adopt, but the AGENTS.md repo map + templates need
        to be hand-shaped to fit reality. Adopt the workflow CONCEPTS
        while letting the project's actual layout drive the templates.
   
   iv.  AMBIGUOUS — you can't tell. The folder has a few files but not
        enough to determine intent (e.g., a fresh `git init` with a
        README and nothing else). Ask the user explicitly.

   Whichever scenario you pick, summarize what you observed before
   asking anything: "I see <X, Y, Z>. Based on this, I think you're in
   scenario <Y> because <reason>." Showing your reasoning gives the
   user a chance to correct a wrong classification quickly.

B. ASK ME ONE BATCHED ROUND OF QUESTIONS
   Use the AskUserQuestion tool (or the platform's equivalent
   batched-question mechanism) in a SINGLE turn. Lead with the right
   anchor question based on **installation state** (from §A).

   **If install state is LEGACY — anchor on the older-format detection:**

   "I see an older-format install here (AGENTS.md uses
   `## Tracker — Linear` style instead of the current
   `## Tracker destinations`). Based on the format, this is likely
   a v0.1.x install — complete by its era's standards but
   out-of-date with the current plugin version.

   I can run an UPGRADE that walks through migration files from
   v0.1.x → current. The v0.2.0 migration handles the section
   rename + new fields; later migrations layer on top. Nothing
   destructive — each change is proposed for confirmation.

   What would you like?"

   - "**Upgrade through migrations (recommended).**"
       → UPGRADE mode. Run §F starting from the v0.2.0 migration.
   - "**Just sync me locally, leave the team config alone.**"
       → LOCAL SYNC mode. Don't run any migrations; treat the legacy
         install as authoritative for local config seeding.
   - "**Re-install from scratch.** (Destructive — replaces all
     existing config.)"
       → RE-INSTALL mode with destructiveness warning.

   **If install state is PARTIAL or INSTALLED — anchor on scope first:**

   Show concrete evidence of what's already configured, then ask the
   user how they want to engage:
   
   "The agentic-engineering-workflow looks <partially/fully> installed
   here. I see:
     - <e.g., AGENTS.md with Tracker destinations: Linear team 'Eng',
       /defect → 'Triage' (built-in)>
     - <e.g., 12 of the canonical labels exist in your Linear>
     - <e.g., docs/decisions/0001-setup.md dated 2026-04-15>
   What's your goal?"
   
   - "**Sync me locally — onboard me without changing anything
     shared.** Seed my local memory from the existing AGENTS.md +
     tracker config, verify my auth, then exit. Recommended if you're
     joining an existing project."
       → LOCAL SYNC mode. Skip all §C writes to shared files. Skip all
         §D tracker writes. Only write per-machine memory seed.
         Don't ask Q2-Q15 — just sync.
   
   - "**Complete the install** — some pieces look missing. Finish setup
     for the team."
       → COMPLETE-PARTIAL mode. Identify the gap; ask only the §B
         questions whose answers aren't already in AGENTS.md or the
         tracker. Show a diff before any team-affecting writes.
   
   - "**Update the team's setup** — make intentional changes that
     everyone will see."
       → TEAM UPDATE mode. Full §B question flow with current values
         pre-filled as defaults. Changes to AGENTS.md go via a branch +
         PR for review; tracker changes happen immediately but only
         after explicit per-change confirmation.
   
   - "**Upgrade to the current plugin version**" — read the installed
     version from AGENTS.md and the current plugin version from
     plugin.json. If installed < current, walk through migration files
     between them and apply confirmed changes."
       → UPGRADE mode. Skip §C/§D. Run §F instead. See §F for the
         migration-walking flow.
       
       Only offer this option if installed-version < current-version.
       If they match, skip this option from the menu.
   
   - "**Re-install from scratch** — wipe existing config and start
     over. (Destructive — affects everyone.)"
       → RE-INSTALL mode. Print the destructiveness warning. If they
         confirm, run the FRESH flow (full questions, full writes).

   **If install state is FRESH — anchor on workspace classification:**

   Show what you observed + your best guess + a "no, it's something
   else" option. Phrase it concretely. Example wordings:
   
   - For GREENFIELD: "This folder looks empty/near-empty. Are you
     starting a new project from scratch, or is there existing code
     somewhere else I should look at first?"
       - "New project, use the recommended layout"
       - "Existing code elsewhere — let me point you at it"
       - "Empty for now but planned structure is different — let me
         describe it"
   
   - For EXISTING-COMPATIBLE: "This looks like an existing <describe
     what you see: 'Next.js app in a single repo' / 'pnpm workspace
     with apps/* + packages/*' / 'parent folder with sibling repos
     X, Y, Z'>. I'll adopt this structure and layer the workflow on
     top — no reorganizing. Confirm?"
       - "Yes, adopt as-is"
       - "Close, but I want to make some structural changes first"
       - "No, the structure is wrong — let me describe what it should
         be"
   
   - For EXISTING-DIVERGENT: "This is an existing project but the
     layout doesn't match either of the spec's standard layouts. I see
     <X, Y, Z>. I'll adapt the templates to fit your actual structure
     rather than try to remap. Do you want to walk me through the
     structure, or should I just infer from what I see?"
       - "Infer from what you see — I'll correct if you get it wrong"
       - "Let me walk you through it"
       - "Actually I do want to reorganize toward the spec's layout"
   
   - For AMBIGUOUS: "I see <X, Y, Z> but can't tell what you're going
     for. Help me out:"
       - "New project, use recommended layout"
       - "Existing project, adopt my current structure"
       - "Existing project, but reorganize toward the spec"

   **Questions 2-N (only if not detected) — remaining setup:**
   For each of the below, SKIP the question if you already detected the
   answer in step A. Only ask what you genuinely don't know.

   For tracker-related questions (Q3, Q9, Q10, Q11): if your §A
   inspection found existing state, **show what you observed + the
   inferred mapping + a "don't write anything" option**. Don't ask the
   user to invent destinations from scratch when they may already have
   them.
   
   2. **Project name + short slug** (used in branch names, ADR
      filenames, etc.).
   3. **Issue tracker confirmation** — confirm the detected tracker.
      Skip if obvious.
   4. **Issue ID prefix** (e.g., PROJ-NN — used in branch names + PR
      trailers). For trackers that auto-generate IDs, what's the
      format? Skip if you derived it from an existing issue.
   5. **Branch convention** (e.g., `<username>/<id>-<slug>` or
      `feature/<id>-<slug>` or just `<id>-<slug>`).
   6. **Operating mode**:
        a) PLANNER-ONLY — the agent plans, dispatches reviewers, files
           tickets, monitors. Other humans/agents execute.
        b) SOLE-IC — the agent executes every ticket end-to-end,
           sequentially.
        c) HYBRID — Planner by default; executes when explicitly
           delegated.
   7. **Worktree usage**: yes (`.worktrees/<slug>` inside each repo)
      or no (just feature branches in the main checkout).
   8. **Triad reviewers to enable** (any subset of the canonical
      three):
        - CTO (technical feasibility)
        - CPO (product priority — needs a PRD reference to be
          effective)
        - CDO (design fidelity — needs a design source to be
          effective)
        - Or specify others (Staff <platform>, Legal, Security, etc.)
   9. **`/defect` destination** — where bugs get filed by the slash
      command. Phrase concretely based on §A inspection. Examples:
      
      - "I see your Linear team has built-in Triage enabled. Should
        `/defect` route there, or do you have a different bug
        destination?"
            a) "Use the team's Triage inbox (recommended)"
            b) "I have a dedicated bug project — let me name it"
            c) "Create a new 'Bug Triage' project"
            d) "Use a label-based approach (apply `bug` label, no
                dedicated project)"
            e) "Skip /defect setup — I'll configure manually later"
      
      - "I see existing projects that could work: '<Bugs>', '<Defects>',
        '<Issues>'. Which should `/defect` use?"
            a) "Use '<Bugs>' (recommended match)"
            b) "Use one of the others"
            c) "Create a new 'Bug Triage' project"
            d) "Skip /defect setup"
      
      - "No existing bug destination detected. Should I create one?"
            a) "Yes, create 'Bug Triage'"
            b) "Yes, but use a different name"
            c) "Skip — I'll configure manually later"
   10. **`/idea` destination** — where parking-lot ideas get filed.
       Same shape. Common pre-existing destinations: "Ideas", "Backlog",
       "Icebox", "Parking Lot", "Future Enhancements", "Roadmap".
            a) "Use '<matched name>' (recommended match)"
            b) "Use a different existing project — let me pick"
            c) "Create a new 'Ideas / Backlog' project"
            d) "Use a label-based approach (apply `idea` label only)"
            e) "Skip /idea setup"
   11. **Planning cadence** — how does this team plan work?
       Phrase based on §A inspection:
       
       - If active sprints/cycles detected: "I see you run <inferred
         cadence: e.g., 2-week sprints; you're mid-Cycle 14>. How should
         the workflow plug in?"
            a) "Continue existing cadence — don't create planning
                artifacts now"
            b) "Create one new sprint/cycle to anchor the workflow's
                rollout"
            c) "Replace existing cadence with the workflow's 10-day
                sprint phases (Contract Lock → Core Build → UX →
                Integration → Beta Readiness)"
            d) "Skip planning entirely — just use /defect and /idea"
       
       - If milestones detected: similar shape, mapping to milestones.
       
       - If no planning structure detected: "No active sprint or
         milestone. How do you want to plan?"
            a) "Don't create anything — I plan work ad-hoc"
            b) "Adopt the workflow's 10-day sprint phases starting now"
            c) "Set up a custom cadence — let me describe it"
   12. **Label / tag taxonomy** — based on what already exists:
       
       - "Your tracker already has labels: <list>. The workflow's
         canonical taxonomy is <list>. Of the missing ones, which
         should I add?"
            a) "Add all missing labels"
            b) "Add a subset — let me pick"
            c) "Show me a diff first — don't write yet"
            d) "Skip — I'll manage labels myself"
   13. **Canonical artifacts** to feed reviewers (paths if local,
       URLs if hosted):
        - PRD / product spec
        - Design source (Figma, design system docs)
        - Architecture overview
   14. **Stacks present** in the project (so per-repo AGENTS.md
       templates can be filled correctly): backend lang/framework, web
       stack, mobile platforms, shared-types layer, infra/deploy, QA
       harness, etc. SKIP this question entirely if introspection
       already gave you a confident answer.
   15. **Docs storage location** — where ADRs and architectural docs
       should live. Phrase based on §A inspection:
       
       - If `docs/decisions/` or `<project>-docs/` exists: "I see you
         already keep docs in `<path>`. I'll put new ADRs there.
         Confirm?"
            a) "Yes, use that"
            b) "Use a different location — let me describe it"
            c) "Skip ADRs entirely"
       
       - If no docs location found AND tracker has documents feature
         in active use (e.g., Linear initiative documents):
         "No docs folder detected, but you're using <tracker>
         documents. How should architectural docs live?"
            a) "Create `docs/decisions/` in-repo (recommended —
                version-controlled, PR-reviewable, greppable)"
            b) "Attach docs to <tracker> initiatives instead"
            c) "Hybrid: ADRs in-repo, strategy docs in <tracker>"
            d) "Create a new dedicated docs repo (I'll create
                `<project>-docs` on GitHub if you want)"
            e) "Skip ADRs entirely"
       
       - If nothing detected: "Where should architectural docs (ADRs,
         design docs, runbooks) live?"
            a) "Create `docs/decisions/` in this repo (recommended)"
            b) "Create a new dedicated docs repo"
            c) "Attach to my tracker (if it supports documents)"
            d) "Skip ADRs entirely — I'll manage docs myself"
       
       Default recommendation: **in-repo `docs/decisions/`** because
       it's version-controlled, reviewable in PRs, greppable from the
       command line, and survives tracker migrations. Tracker-attached
       docs are great for strategy / PRD / product narrative; ADRs and
       engineering decisions belong in the repo.

C. SCAFFOLD THE FILES
   Mode-aware behavior:
   - **LOCAL SYNC mode** (§B Q1 → "sync me locally"): SKIP this entire
     section. Jump to memory seed only (last bullet below) — write
     `MEMORY.md` + `user_identity.md` + `project_current_state.md` +
     `reference_tracker.md` seeded from existing AGENTS.md + tracker
     config. Do NOT write shared files. Do NOT modify AGENTS.md /
     CLAUDE.md / .claude/ / .agents/.
   - **COMPLETE-PARTIAL mode**: For each file below, check if it
     already exists with the workflow's signature. If so, skip. If
     missing, write it. Show a diff before writing.
   - **TEAM UPDATE mode**: Write changes as committed-and-PR'd (open a
     branch like `<user>/aew-update-<date>`, commit the changes,
     surface the PR URL — don't push to main directly).
   - **FRESH or RE-INSTALL mode**: Write everything from scratch.

   For TEAM UPDATE / FRESH / RE-INSTALL: create or update (idempotently —
   check before overwriting). **Adapt every template to the workspace's
   actual layout** — don't blindly copy the templates if the project
   doesn't match. In particular:
   
   - If GREENFIELD or EXISTING-COMPATIBLE with a sibling-repo layout: use
     the templates in §13 as-is.
   - If EXISTING-COMPATIBLE with a single-repo or workspace-monorepo
     layout: write a single root AGENTS.md, skip per-repo AGENTS.md, and
     instead write per-module AGENTS.md stubs under the actual module
     directories (e.g., `apps/web/AGENTS.md`, `packages/api/AGENTS.md`).
   - If EXISTING-DIVERGENT: hand-shape the AGENTS.md repo map section
     to reflect what actually exists. The template's repo table is a
     starting point, not a requirement.
   
   Files to write:
   - Root `AGENTS.md` (template §13.1, filled with answers + actual
     layout).
   - `CLAUDE.md` compatibility shim pointing to AGENTS.md.
   - Per-repo / per-module `AGENTS.md` stubs (template §13.2) at
     wherever the project's modules actually live.
   - `.claude/skills/defect/SKILL.md` (from §11.1, with the tracker
     tool names + project IDs filled in).
   - `.claude/skills/idea/SKILL.md` (from §11.2).
   - If the workspace uses the Codex CLI in addition to Claude Code,
     mirror the skills to `.agents/skills/` too.
   - `.gitignore` entries for `/.worktrees/` in each repo (if using
     worktrees).
   - An ADR placeholder noting the workflow was adopted — **but only
     if the user picked an in-repo or dedicated-docs-repo location in
     §B Q15**. Write it at the chosen path. If the user picked
     tracker-attached docs, create the equivalent initiative-document /
     project-document in §D instead. If the user picked "skip ADRs",
     don't write any placeholder.
   - Memory seed files at the path the agent's harness uses
     (typically `~/.claude/projects/<slugified-workdir>/memory/` for
     Claude Code; consult the equivalent path for Codex or other
     agents): `MEMORY.md` + `user_identity.md` +
     `project_current_state.md` + `reference_tracker.md`.

D. WRITE TO THE TRACKER (only what the user approved in §B)
   The tracker is shared state — writing to it without confirmation is
   invasive. The §A inspection already gave you the lay of the land; the
   §B questions confirmed exactly what to write. This phase just
   executes those confirmed writes.

   **Default behavior is "do as little as possible."** If the user said
   "use existing X" or "skip", DO NOT create anything new.

   Mode-aware behavior:
   - **LOCAL SYNC mode**: SKIP this entire section. No tracker writes.
     Just record the *existing* destinations in local memory so /defect
     and /idea work for the local user.
   - **COMPLETE-PARTIAL / TEAM UPDATE / FRESH / RE-INSTALL**: proceed
     with the writes the user confirmed in §B, with one additional
     check: re-verify each target doesn't already exist before
     creating. Trackers are shared and other collaborators may have
     created the same things in parallel.

   **Tracker MCP capability caveats (Linear in particular):**
   - **No project / document delete.** Linear's MCP exposes
     `delete_attachment`, `delete_comment`, `delete_status_update` —
     but NOT `delete_project` or `delete_document`. If a previous
     setup created a project (e.g., an unwanted "M0 / Current Sprint"
     from an older install) and you want to retire it, the bootstrap
     can ONLY archive / cancel / tombstone it via state update
     (project state → "canceled" or equivalent), OR surface a
     manual-step recommendation: "Open Linear and delete the project
     manually." NEVER claim the bootstrap deleted something it can't.
   - **`triageEnabled` may not surface on `get_team`.** Some MCP
     builds don't expose this field even though Linear teams support
     built-in Triage. Fallback order: (1) check `triageEnabled` if
     returned; (2) if absent, ask the user via §B Q9 sub-prompt: "I
     can't tell from the MCP whether your Linear team has built-in
     Triage. Does it?" (3) If user doesn't know either, default to
     assuming it exists (Linear's default for new teams) but note
     this assumption in the report.
   - **List operations may paginate.** Don't trust a single
     `list_projects` / `list_cycles` / `list_issue_labels` call to be
     exhaustive — check for pagination tokens.
   - **MCP-specific delete behavior may vary across tracker
     types.** Jira allows deleting some object types; Notion archives
     pages instead of deleting; GitHub Issues are closable but
     pages/projects aren't fully deletable via API in some cases.
     Always reframe cleanup as the strongest non-destructive action
     the tracker supports, and surface manual UI cleanup when needed.

   D.1 — Write the /defect destination
   Based on the user's answer to question 9:
   - "Use built-in Triage" / "Use existing project X": no write needed.
     Record the destination ID in `AGENTS.md` → "Tracker destinations"
     section so the /defect skill knows where to file.
   - "Create new project": create exactly one project with the chosen
     name. Capture the ID. Record in AGENTS.md.
   - "Label-based": no write needed. Record `mode: label-based, label:
     <bug-label-name>` in AGENTS.md.
   - "Skip": do nothing. The /defect skill will prompt at first use.

   D.2 — Write the /idea destination
   Same shape as D.1, based on answer to question 10.

   D.3 — Write planning artifacts (only if requested)
   Based on the user's answer to question 11:
   - "Continue existing cadence" / "Don't create anything": no write.
   - "Create one new sprint/cycle to anchor the rollout": create a
     single sprint/cycle named per the team's existing naming pattern
     (e.g., if they have Cycles 1-14, create Cycle 15). Pre-fill with
     a "Workflow adoption" milestone or note; DO NOT pre-fill scope.
   - "Adopt 10-day sprint phases": create a project/milestone named
     "M0 — Workflow Adoption" with the five canonical phase milestones
     (Contract Lock / Core Build / UX Layer / Integration / Beta
     Readiness). Empty bodies; the user fills scope later.
   - "Custom cadence": pause and ask for the cadence definition. Do
     not invent one.

   D.4 — Write labels (only if requested)
   Based on the user's answer to question 12:
   - "Add all missing labels": add labels not already in the tracker
     from the canonical taxonomy (kind, sprint:s1, platform, area, ops).
     Skip ones that already exist.
   - "Add subset": add only the ones the user picked.
   - "Show me a diff first": print the diff (which labels would be
     added) and ask again before writing.
   - "Skip": no write.

   D.5 — Record destinations + cadence in AGENTS.md
   Whatever destinations and cadence were chosen, write them into
   `AGENTS.md` under a "Tracker destinations" section so /defect and
   /idea know where to file at runtime, and so future sessions
   understand the planning model. See §13.1 for the template.

   **Universal rule:** every tracker write call passes `assignee: null`
   explicitly. The Linear MCP and several others auto-assign to the
   caller (= the human running the session) when assignee is omitted —
   this pollutes the human's queue with tickets they shouldn't own.
   Always pass `null` unless the title is prefixed with a human's name.

E. REPORT
   Print a final summary:
   - Files created / updated (paths).
   - Tracker writes performed (with URLs/IDs). If the user opted to use
     existing destinations or skip writes, say so explicitly — "no
     tracker writes performed; /defect routes to existing Triage" beats
     leaving the user to guess.
   - Manual follow-ups required (auth steps, secrets to set, design
     files to link, etc.).
   - The exact next prompt I should run to start working in this setup.
     Examples:
       - "Draft Sprint 1 plan from <PRD path>" (if they adopted sprint
         phases)
       - "Continue with current cycle" (if they kept existing cadence)
       - "Try /defect to file a bug" (if they skipped planning entirely)

F. APPLY UPGRADE MIGRATIONS (UPGRADE mode only)
   Triggered when §B Q1 returned "Upgrade to the current plugin
   version". Skip this phase in every other mode.

   F.1 — IDENTIFY MIGRATIONS TO RUN
   - Read the "Workflow version" field from `AGENTS.md` → "Tracker
     destinations" section. This is the **installed version**.
   - Read `plugin.json` from the plugin root for the **current
     version**.
   - Look in `migrations/` (next to this skill in the plugin) for every
     `vX.Y.Z.md` file. Each has frontmatter with `from:` and `to:`
     fields.
   - Select migrations where `to:` > installed AND `to:` ≤ current.
     Apply them in SemVer order from lowest `to:` to highest.
   - If no migrations match (e.g., installed == current), report "No
     upgrades available" and exit.

   F.2 — WALK EACH MIGRATION WITH THE USER
   For each migration, in order:
   - Show the migration's "Summary" section.
   - Show how many changes it contains and a one-line preview of each.
   - Ask: "Apply this migration? (apply all / pick which to apply /
     skip this version / abort upgrade)"
   - If APPLY ALL: walk each change and apply per §F.3.
   - If PICK: show changes one at a time, ask apply/skip for each.
   - If SKIP THIS VERSION: move to the next migration; warn that
     future migrations may depend on skipped state.
   - If ABORT: stop the upgrade, report progress so far, exit.

   F.3 — APPLY A SINGLE CHANGE
   Read the change's `Scope` and `Automatable` fields.
   - **Scope `plugin-internal`**: the plugin update already delivered
     it. Acknowledge and move on; no user action.
   - **Scope `local`**: apply to per-machine files only. No tracker
     writes, no shared file writes. Confirm with the user before each
     local file write.
   - **Scope `team-wide`**: this affects shared config. Apply via a
     branch + PR for file changes (per TEAM UPDATE mode rules). For
     tracker writes (label renames, project moves), confirm per-write
     before executing. **Idempotency check first** — if the target
     state is already reached (e.g., label already renamed because
     another collaborator did it), skip with "already done."
   - Read the `Automatable` field:
     - `yes`: apply mechanically with confirmation.
     - `partial`: show a diff/preview first, then confirm.
     - `no`: describe the action; the user does it manually.

   F.4 — UPDATE THE WORKFLOW VERSION FIELD
   After all migrations the user accepted are applied, update
   `AGENTS.md` → "Tracker destinations" → "Workflow version" field
   to the highest version that was fully applied (not skipped).

   If any migration was partially applied or skipped, surface that in
   the report: "Workflow version updated to v0.4.0 (v0.5.0 migration
   skipped on user request — re-run setup to apply later)."

   F.5 — REPORT
   Same shape as §E, but specifically for migrations:
   - Migrations applied (and the changes within each).
   - Migrations skipped (and why).
   - New installed version.
   - Next prompt to run if anything new from the migrations needs
     follow-up (e.g., "Try the new /standup skill" if v0.4.0 added one).

Throughout, follow the rules in the spec verbatim. Two universal rules to
double-check on every tracker call:
- If the tracker MCP auto-assigns to the caller when `assignee` is omitted
  (Linear does this — it's the single most common footgun), ALWAYS pass
  `assignee: null` explicitly. Tickets requiring a specific human's action
  are the only ones that should be assigned, via a title prefix convention.
- NEVER edit AGENTS.md or skill files mid-execution to "fix" things you
  notice. Surface them as proposed follow-ups so I can approve a rule
  change explicitly.
```

---

## §1 — Workflow philosophy

This workflow is built on a few core convictions. They're worth understanding before you adopt or adapt it.

### Convictions

1. **The hardest part of multi-person software is communication, not code.** A workflow that makes intent visible (tickets, ADRs, status updates) beats one that optimizes for individual throughput.
2. **AI agents work best with explicit operating contracts.** Telling the agent "you're the DoE" with clear authority boundaries produces better results than treating it as an oracle that knows what to do.
3. **Reviews catch things makers miss.** A draft that survives three orthogonal critiques (technical, product, design) is meaningfully more durable than one signed off by a single reviewer.
4. **Process pays back proportionally to project complexity.** The triad-review + ADR overhead is overkill for a single-file script and essential for a multi-repo product. The setup asks about operating mode so the overhead can scale.
5. **The tracker is the source of truth, not chat.** Conversation context evaporates between sessions; tickets and ADRs persist.

### What this workflow does NOT prescribe

- A specific tech stack — bring your own.
- A specific tracker — Linear-style hierarchy is the model the spec assumes, but the workflow adapts to whatever tracker has a queryable API.
- A specific CI/CD setup — bring your own.
- Team size — works solo, scales to small teams.

---

## §2 — Roles, authority, operating mode

### Roles

| Role | Held by | Decides |
|---|---|---|
| Founder / Product Owner / "the human" | One or more humans on the team | **WHAT** ships. Scope, priorities, brand voice, design deviations. |
| Director of Engineering (DoE) | The AI coding agent | **HOW** it ships. Implementation, sequencing, tickets, ADRs. |
| CTO (subagent) | DoE dispatching a general-purpose subagent | Technical feasibility, architecture, risk. |
| CPO (subagent) | DoE dispatching a general-purpose subagent | Product priority, sequencing — **MUST cite the PRD** if one exists. |
| CDO (subagent) | DoE dispatching a general-purpose subagent | Design fidelity — **MUST cite design system** if one exists. |
| Additional reviewers (optional) | DoE dispatching subagents | Staff-level platform-specific review (e.g., Staff iOS, Staff Backend), Legal, Security, etc. |

The triad reviewers are **reviewers, not scope-deciders.** When they recommend scope changes ("cut this feature", "this isn't in the PRD"), DoE flags to the human — DoE does NOT cut from scope on triad pushback alone. **Human wins when scope is disputed.** Triad's HOW guidance is incorporated; their WHAT pushback becomes open questions for the human.

### Operating modes

Pick one at setup. Switchable later.

- **PLANNER-ONLY** (recommended when there's a team of humans + agents): the agent drafts plans, dispatches reviewers, files tickets, monitors, files defects/ideas, posts status updates. Other humans / agents pick up implementation. The agent does NOT auto-execute implementation work unless explicitly delegated.
- **SOLE-IC** (recommended for a solo founder + one agent): the agent executes every ticket end-to-end. Sequentially, one ticket at a time. Code → test → push → watch deploy → next ticket.
- **HYBRID**: Defaults to planner; executes only when explicitly delegated. Each delegation is one ticket — does not generalize into permanent IC mode.

---

## §3 — Repo / monorepo layout

Pick whichever fits the project.

### Layout A — Sibling-repo monorepo (recommended for multi-platform products)

```
<parent-folder>/                    ← NOT a git repo; holds AI config + sibling repos
  AGENTS.md                         ← root working guide (this is what your agent reads first)
  CLAUDE.md                         ← compatibility shim → AGENTS.md (Claude Code looks here first)
  .claude/                          ← Claude Code config
  .agents/                          ← Codex / other-agent config
  .agents/                          ← skills + plugins (alternate harness)
  docs/                             ← optional human local-notes folder
  <project>-contracts/              ← shared types / DTOs / OpenAPI (if applicable)
  <project>-api/                    ← backend
  <project>-web/                    ← web client
  <project>-ios/                    ← iOS client (if applicable)
  <project>-android/                ← Android client (if applicable)
  <project>-infra/                  ← shared docker / deploy config
  <project>-docs/                   ← ADRs + sprint summaries + PRD
  <project>-design-system/          ← tokens + design specimens (if applicable)
  <project>-ui-{platform}/          ← per-platform UI kits (if applicable)
  <project>-qa/                     ← cross-repo QA harness (if applicable)
```

**Parent folder discipline (if you adopt this layout):**
- Contains ONLY per-repo folders + AI-config dotfiles + `docs/`.
- NO top-level files (no PNGs, scratch docs, screenshots).
- NO ad-hoc folders (`tmp/`, `sprint-N/` — all forbidden).
- Brand assets live in `<project>-design-system/assets/`.
- Cross-cutting design audits + plans + ADRs live in `<project>-docs/`.
- Agent infrastructure (specs, brainstorms, scratch) lives outside the parent folder (e.g., `~/.claude/projects/<slug>/`).

### Layout B — Single-repo project (or workspace monorepo)

```
<repo-root>/
  AGENTS.md
  CLAUDE.md                          ← shim → AGENTS.md
  .claude/
  docs/
    decisions/                       ← numbered ADRs
  packages/ or apps/ or src/         ← project source
```

Per-module `AGENTS.md` files live in module subdirectories if the project has clear ownership boundaries.

### Worktree placement rule (if you use worktrees)

- Worktrees live **INSIDE the repo they belong to**, at `<repo>/.worktrees/<slug>`.
- NEVER in the parent folder, NEVER as sibling-repos.
- Every repo's `.gitignore` includes `/.worktrees/`.

```bash
# Correct
git -C <repo> worktree add .worktrees/<slug> <branch>

# Wrong — pollutes the parent
git -C <repo> worktree add ../<repo>-<slug> <branch>
```

---

## §4 — Issue tracker hierarchy

This is the model the workflow assumes. Map it onto whichever tracker you use:

```
Initiative              ← top-level dashboard view (e.g., "Beta Launch")
  Project               ← work area (e.g., "Sprint 4", "Chat Module")
    Milestone           ← phase gates within a project
      Issue             ← actual ticket
```

| Tracker | Initiative ≈ | Project ≈ | Milestone ≈ | Issue ≈ |
|---|---|---|---|---|
| Linear | Initiative | Project | Project Milestone | Issue |
| GitHub Issues | Milestone (top-level) + label | Project (beta) board | Milestone within board | Issue |
| Jira | Initiative | Epic | Sprint or Fix Version | Story / Task / Bug |
| Notion | Top-level DB or page | Sub-page or category | Milestone property | Item |

### Status update cadence

- **Initiative-level** (DoE-owned): every ~2 sprint days + at close.
- **Project-level** (DoE-owned): at kickoff + each phase milestone + close.

### Assignee rule (the #1 footgun, especially on Linear)

```
Title prefixed "<HumanName>:" → assign to that human
Otherwise                     → leave unassigned (assignee: null)
```

**ALWAYS pass `assignee: null` explicitly** on every ticket-creation call when the tracker MCP defaults to "assign to caller". The caller is often the agent's authenticated user (= the human running the session), which pollutes the human's queue with tickets they shouldn't be on the hook for. The title-prefix convention is the only way a ticket gets assigned at creation; everything else stays in the triage pool.

### Canonical label taxonomy

Adapt names to the tracker's conventions; the categories are universal.

| Group | Labels | Purpose |
|---|---|---|
| Sprint | `sprint:s1`, `sprint:s2`, … | Sprint membership |
| Launch | `launch:private-beta`, `launch:ga` | Launch gating |
| Area | `area:<module>` (e.g., `area:chat`, `area:auth`) | Module ownership / triage filtering |
| Platform | `platform:web`, `:ios`, `:android`, `:backend`, `:all` | Affected platforms |
| Kind | `kind:spec` (for parent "Define X" tickets), `bug`, `improvement`, `feature` | Ticket flavor |
| Ops | `blocker`, `alarm:deploy-failure`, `gate:beta-ready` | Operational signals |

---

## §5 — Sprint workflow

### Phase 0 — Read in

Before drafting any plan, DoE reads:
- The PRD (canonical product spec — wherever it lives).
- The design system / design source.
- The previous sprint's completion summary.
- Current open alarms (`alarm:deploy-failure` tickets).

### Phase 1 — Draft v1

DoE drafts a v1 sprint plan to a scratch file. The plan includes:
- **Goal** — one sentence on what shipping this sprint changes for users.
- **Scope** — bulleted feature/fix list, each linked to a parent `kind:spec` ticket.
- **Execution order** — explicit ticket sequence with dependency arrows.
- **Phase milestones** — Contract Lock → Core Build → UX Layer → Integration → Beta Readiness.
- **Risks + open questions** — explicit list.
- **Out of scope (anti-scope)** — explicit list of what's ruled out.

### Phase 2 — Triad review (PARALLEL subagent dispatch)

DoE dispatches the configured reviewers in parallel (single message, multiple `Agent` tool calls). Each gets a focused prompt that names their role, the canonical artifact they're enforcing, and the verdict format.

**CTO prompt skeleton:**
```
You are the CTO reviewing the DoE's Sprint N plan at <path>.

Focus on:
- Technical feasibility and architecture coherence
- Risk profile (where could this go wrong?)
- Engineering trade-offs (is the sequencing sane?)
- Cross-repo / cross-module contract implications
- Test strategy adequacy

No specific artifact constraint — push back on any concrete technical decision.

Verdict format: "Ship as-is" / "Ship with edits" / "Reframe required"
+ numbered punch list (4-8 items max).
```

**CPO prompt skeleton:**
```
You are the CPO reviewing the DoE's Sprint N plan at <path>.

Focus on product priority + user-experience outcomes — BUT you MUST reference
the canonical PRD at <path-to-PRD>. CPO does NOT invent net-new features.
Push back on prioritization / scope / sequencing — yes. Adding features that
aren't in the PRD — no, flag as out-of-bounds.

For each scope item:
- Is this in the PRD?
- Is the proposed sequencing user-value-optimal?
- What's the user-visible outcome at end-of-sprint?

Verdict format: "Ship as-is" / "Ship with edits" / "Reframe required"
+ numbered punch list with explicit PRD citations.
```

**CDO prompt skeleton:**
```
You are the CDO reviewing the DoE's Sprint N plan at <path>.

Focus on design fidelity. Read the canonical design source at <path-to-design>
and check that every UI surface in scope matches a documented state. Sole
sanctioned design deviations: <project-specific list>. All other deviations
require explicit human sign-off via ADR.

For each UI ticket:
- Is this screen/state in the design source?
- Does the proposed implementation match the spec?
- Are tokens / typography / brand identity respected?

Verdict format: "Ship as-is" / "Ship with edits" / "Reframe required"
+ numbered punch list with explicit design-file citations.
```

### Phase 3 — Synthesize v2

DoE merges the verdicts:
- HOW pushback from any reviewer is incorporated.
- WHAT pushback (scope cuts, new features) goes to the human as open questions — DoE does NOT cut scope on triad recommendation alone.
- If two reviewers contradict each other, escalate as an open question.
- v2 plan documents what each reviewer pushed back on and what was incorporated/dropped.

### Phase 4 — Persist the plan

- Post v2 as a tracker Document / wiki page / pinned issue on the current-sprint project.
- Write an **ADR** at `<docs>/decisions/NNNN-sprint-N-execution-plan.md` containing the project → parent ticket → execution-order map.

### Phase 5 — Build tracker scaffolding

In order:
1. Initiative (if new initiative crosses multiple sprints).
2. Project (the sprint itself).
3. Parent `kind:spec` tickets ("Define X") for each major feature.
4. Execution-order child tickets under each parent.
5. Five phase milestones: Contract Lock / Core Build / UX Layer / Integration / Beta Readiness.

### Phase 6 — Execute

**Mode-dependent.**

- **PLANNER-ONLY:** DoE hands off the scaffolded plan. Monitors via tracker status, files defects via `/defect`, posts status updates every ~2 sprint days. Does NOT auto-execute.
- **SOLE-IC:** DoE executes tickets sequentially, in execution order. Code → test → push → watch deploy → next ticket.
- **HYBRID:** Defaults to planner; executes only when explicitly delegated.

### Phase 7 — Pre-close gate (MANDATORY)

Before marking a sprint complete:
- Run a canonical happy-path walkthrough on every shipped platform with screenshots.
- **NEVER close while a deploy is failing.**
- **NEVER close while verification is "deferred."**

### Phase 8 — Closeout

- Write `SPRINT_N_COMPLETION.md` PR in the docs repo.
- Move project state → completed.
- Initiative-level status update.

---

## §6 — ADR system

ADRs (Architecture Decision Records) live at `<docs>/decisions/NNNN-<kebab-case-title>.md` — numbered sequentially.

**Template:**
```markdown
# ADR NNNN — <Decision title>

Date: YYYY-MM-DD
Status: <Proposed / Accepted / Deprecated / Superseded by ADR NNNN>

## Context

<What problem are we solving? What's the constraint that forces a decision?>

## Decision

<What we're going to do, in declarative bullet points.>

## Consequences

<What does this enable? What does it foreclose? What's the cost?>

## Alternatives considered and rejected

<Each alternative + one-line rationale for rejection.>
```

**When to write a new ADR:**
- Any decision touching 2+ modules / repos.
- Introducing a new external dependency or paid service.
- Changing the contract lock process.
- Choosing one tech over another at module level.
- Reversing a prior ADR (write a new one that "Supersedes ADR NNNN").

**When NOT to write an ADR:**
- Per-sprint scope decisions (those live in the sprint plan).
- Single-file refactors.
- Bug fixes (commit message + PR description is enough).
- Anything ephemeral.

---

## §7 — Contract-lock discipline (for multi-module projects)

If the project has a shared types / API contracts layer, contracts are **locked end-of-Day-2** of every sprint. After lock:
1. Changes require an opened PR touching the contracts module.
2. DoE approval + sign-off from every affected client.
3. Synchronized update in every client that consumes the changed shape (fan-out edit in the same PR if DoE owns all clients; coordinated PRs otherwise).
4. If the change is significant, write an ADR amendment referencing the original contract-lock ADR.

This keeps parallel work safe against schema drift and makes mid-sprint contract changes expensive + visible (by design).

For projects without an explicit contracts layer, the same discipline applies to API endpoints (treat the endpoint surface as the contract) and database schemas (treat migrations as contract changes).

---

## §8 — PR hygiene

- **Branch name:** `<user>/<issue-id>-<short-slug>` (or include the issue ID anywhere visible — most conventions prefix with the contributor's name or initials).
- **Commit author:** the human's git identity, not the agent's. Configure on first run if needed.
- **PR body trailer:** include the issue-tracker's auto-close keyword (`Closes #N` / `Closes PROJ-NN` / `Fixes ISSUE-N` — check the tracker's docs for which keywords trigger close-on-merge).
- **Never** `--no-verify`, `--no-gpg-sign`, force-push to main, or amend published commits.
- **Stage specific files** — avoid `git add -A` (accidentally commits `.env`, build artifacts, secrets).
- **DoE reviews via subagent code-reviewer** before merge.
- **DoE watches every PR through deploy success.** Merge ≠ shipped; production reachable = shipped.
- **PRs that change visible UI:** record + **visually inspect** snapshot baselines before commit. Recording without looking is not running the gate.
- **README freshness:** before opening any PR, decide whether the repo README needs an update. If the change alters setup commands, dependency pins, public routes, bundle/package IDs, CI/deploy behavior, verification steps, runbooks, or architecture/module ownership — update README in the same PR.

---

## §9 — Working agreements

- **No side work during a sprint.** Only `sprint:sN` tickets. Drift → file `sprint:s(N+1)` candidate.
- **Tests come first.** No ticket ships without tests.
- **Secrets never in the tracker.** Service IDs, console URLs, DB region are OK. Full creds go directly in destination stores (deploy platform / CI secrets / local `.env`).
- **Deploys never block on observability.** Sentry / source-map / analytics steps are `continue-on-error: true`.
- **Auto-alarms route to DoE, not the human.** Deploy-failure alarms create unassigned tickets with `alarm:deploy-failure`. **Scan open alarms at session start.**
- **Shared-resource writes pre-authorized** for trusted infra (database / hosting / observability platforms) — don't ask the human for per-op approval; they've already approved the tool class.
- **Cross-platform parity audit:** every bug-fix bundle on one client platform gets a read-only cross-check on sibling platforms before merge; file sibling tickets for any present-elsewhere class of bug.
- **Notifications-as-feature-shape:** every new feature ticket that creates a user-visible state change considers the notification surface at scope time, not after. Categories without features are not built.

---

## §10 — Architectural philosophy: "Dumb clients, smart server"

Logic lives on the server; clients render.

- **Server owns:** derived display fields, external API calls (weather, maps, geocoding), ranking, system messages, error → user-copy mapping, viewer-action / can-edit checks per request.
- **Client owns:** layout, animation, gestures, per-device state (timezone, push token), trivial concatenations, network-failure fallbacks.
- **Rule of thumb:** if a logic rule appears in two client repos, file a follow-up to migrate it to the server.

This philosophy is optional — some projects have legitimate reasons for thick clients (offline-first, latency-sensitive UIs, etc.). When you skip it, document the reason in an ADR so future contributors don't try to "fix" the divergence.

---

## §11 — Skill files (full SKILL.md contents)

Each skill goes in `.claude/skills/<name>/SKILL.md` (Claude Code) and/or `.agents/skills/<name>/SKILL.md` (Codex and other agents that follow the SKILL.md convention). The setup agent should:
1. Detect which agent CLI is configured in the workspace and write to the right path (or both, if the workspace uses multiple agents).
2. Replace `<TRACKER_MCP_PREFIX>` in the skill templates with the actual MCP function prefix detected during introspection (e.g., `mcp__linear__`, `mcp__plugin_linear_linear__`, `mcp__atlassian__`).
3. Replace tracker-specific placeholders (`<TEAM_OR_PROJECT_NAME>`, `<BUG_TRIAGE_PROJECT_ID>`, `<IDEAS_PROJECT_ID>`) with the IDs created in step D.
4. For non-MCP trackers (plain GitHub Issues, etc.), rewrite the "File via Linear MCP" section to use `gh issue create` or the equivalent CLI.

### 11.1 — `/defect` skill

Save to `.claude/skills/defect/SKILL.md`:

````markdown
---
name: defect
description: Triggered when the user types /defect — captures a bug report from chat, infers platform/build/repro/hypothesis, files a ticket to the project's "Bug Triage" view with an inferred severity priority. Use ONLY when the user types /defect.
---

# /defect — file a bug report ticket with inferred context + hypothesis

## When to invoke

The user types `/defect <description>` in chat. The description is everything after the slash command. The user may also drop screenshots into the same message — use them to inform the hypothesis and ticket description.

Do NOT use this skill for anything except `/defect` invocations. For ideas, use `/idea`.

## What to do

The whole point is **low-friction capture during testing**. The user is mid-flow when they report a bug — they should not have to answer follow-up questions or wait. Make every reasonable inference yourself. If a field is genuinely unknowable, say so in the ticket rather than asking.

### 1. Parse the bug payload

Read everything after `/defect`. Categorize:
- **What happened** (the actual buggy behavior — usually the leading sentence)
- **Where in the app** (screen / flow / feature, if mentioned or inferable)
- **Reproducibility** (always / sometimes / once — usually unstated; assume "always" if not specified)
- **Platform overrides** ("on android", "on web", "on safari") — default per project setup
- **Priority overrides** ("urgent", "high priority", "minor", "cosmetic") — default per rubric below
- **Build override** ("build 142", "deploy abc123") — default to current production

If a screenshot is attached, use it to inform the hypothesis + description. Attach to the ticket if the tracker supports it.

### 2. Build context lookup

Look up the latest build / deploy for the affected platform, if it's quick:
- Web: current production deploy (commit SHA from main, or deploy ID from the hosting platform).
- iOS: latest TestFlight build (if the App Store Connect API is configured).
- Android: latest internal-testing build (if Play Console API is configured).
- Backend: current production deploy commit SHA.

If the lookup is slow / unavailable, write "unknown (couldn't verify)" and proceed. Do NOT block ticket creation on it.

### 3. Build the cause hypothesis

This is what makes `/defect` valuable over a plain `gh issue create`. Walk this checklist:

1. **Identify the screen/feature.** Map the bug to a specific screen / flow / module by name.

2. **Identify the likely culprit repo + module.** For the bug's screen, name the most likely module (often 1-2 candidates).

3. **Hypothesis on root cause.** Walk likely failure modes for the symptom:
   - Crash → null deref, decoder failure on optional field, precondition violation. Check recent commits to the module.
   - Wrong data shown → view-model binding bug, stale cache, API contract mismatch. Check what changed in the contract recently.
   - UI glitch → layout / binding / state-machine inconsistency. Check kit-component changes.
   - Network / API error → 4xx/5xx from API. Check recent backend deploys.
   - Permission / auth → session expiry, role check, feature flag.
   
   Be specific: cite likely file:line ranges if you know them.

4. **Recent commits that might have introduced it.** Quick `git log` against the build's source SHA — what landed in the last ~10 commits? List commits whose subject mentions the affected module/screen.

5. **Likely files to investigate.** Top 3 file paths the assignee should open first.

A wrong hypothesis is fine on triage — the value is the assignee starts with a starting point instead of a blank page.

### 4. Severity → priority

| Priority | Use when |
|---|---|
| Urgent (1) | Crashes; data loss; can't sign in; can't install/update; security; payment broken |
| High (2) | Core feature unusable; blocked sign-up; major data corruption; chat undeliverable |
| Medium (3) | Feature works but has visible glitch; workable workaround; degraded UX in core flow |
| Low (4) | Cosmetic; copy fixes; rare edge cases; polish; minor visual misalignment |

Honor explicit user priority. Otherwise infer + write a one-sentence severity rationale into the ticket.

Default to **Medium** if uncertain. Don't default to Low — bugs found while testing are usually at least Medium because they made it through self-review.

### 5. Compose the ticket

Title: 5-10 word noun-led summary of WHAT'S broken. No "Bug:" prefix (the project placement conveys it).

Description structure:

```markdown
## Summary

<1-2 sentence restatement of what's broken, more precise than the title>

## Reported context

- **Platform:** <iOS / Android / web / backend>
- **Build:** <build # / commit / current production / unknown>
- **Environment:** <user device / simulator / browser / unknown>
- **When:** <where in the flow>
- **Reproducibility:** <Always / Sometimes / Once>
- **Screenshot:** Attached (if applicable)

## Expected behavior

<What SHOULD happen. If unclear, say so.>

## Actual behavior

<Restate the bug as observed, in user-facing terms.>

## Reproduction

1. <Step 1>
2. <Step 2>
3. <Observe bug>

## Hypothesis

- **Likely module:** `<repo/module>`
- **Likely cause:** <specific failure mode with caveats>
- **Suggested first files to read:** `<path>`, `<path>`, `<path>`
- **Recent relevant commits:** <1-3 commits if quickly available>

## Severity rationale

<One sentence explaining the priority.>

## Triage notes

<Any parking-lot or sprint-pull guidance.>
```

Omit sections that are genuinely empty. Don't pad with placeholders.

### 6. Resolve the destination

Read `AGENTS.md` → "Tracker destinations" section (written by the setup). It specifies how /defect should file:

- **Mode `project`**: file into a specific project / team / view. The destination ID is in the section.
- **Mode `triage`**: file into the tracker's built-in Triage inbox (Linear has this; Jira's equivalent is the default backlog).
- **Mode `label`**: file as an unassigned issue with the configured bug label applied, no specific project.
- **Mode `unset`** or no "Tracker destinations" section: the setup was skipped or `/defect` wasn't configured. Ask the user where to file (single batched question, then write the choice back to AGENTS.md so this doesn't repeat).

### 7. File via the tracker

Adapt the call shape to the destination mode resolved in step 6:

```
<TRACKER_MCP_PREFIX>save_issue({
  team / project: <destination_id_or_null>,
  title: "<5-10 word noun-led summary>",
  description: "<full markdown above>",
  priority: <1|2|3|4>,
  assignee: null,
  labels: ["bug", "platform:<primary>", <plus configured bug-label if mode == "label">]
})
```

CRITICAL: pass `assignee: null` explicitly. Many tracker MCPs auto-assign to the caller if `assignee` is omitted.

Capture the returned ticket ID / URL.

### 7. Attach screenshots

If a screenshot was provided and accessible as a local path or base64 blob, call the tracker's attachment API. If you can't access the screenshot bytes, skip rather than ask.

### 8. Report back

Output in chat, under 5 lines:
- Ticket URL
- Inferred priority + 1-line severity rationale
- Hypothesis in 1 sentence
- Any inference the user should sanity-check

## Rules

- Don't enter plan mode. Don't ask clarifying questions. `/defect` is fire-and-forget.
- Don't skip the hypothesis section even if uncertain — partial guesses with caveats beat blank tickets.
- Don't invent reproduction steps that aren't grounded in the description + product knowledge. If you can't reconstruct, say so explicitly.
- Don't omit `assignee: null`.
- Don't add `area:*` labels unless you're confident which area owns the affected module.
- Don't auto-pull the ticket into the active sprint. Triage at sprint kickoff.
- Don't dispatch implementation subagents. Capture only.

## After filing

Done. Don't post to other tickets, don't start implementing. The ticket sits in "Bug Triage" until next sprint-kickoff triage.
````

### 11.2 — `/idea` skill

Save to `.claude/skills/idea/SKILL.md`:

````markdown
---
name: idea
description: Triggered when the user types /idea — takes an idea description, infers the cross-repo work needed to ship it, drafts a mini-spec, and files the ticket to the "Ideas / Backlog" view as a parked idea. Use ONLY when the user types /idea.
---

# /idea — file a parking-lot ticket with inferred cross-repo spec

## When to invoke

The user types `/idea <description>` in chat. The description is everything after the slash command — could be a one-liner, a paragraph, or a rambling thought with multiple sub-ideas. Treat the entire post-command text as the raw idea payload.

## What to do

1. **Understand the idea.** Read carefully. If ambiguous, make one reasonable interpretation and note it in the spec as "Assumed: …" rather than asking — `/idea` is low-friction capture.

2. **Infer the cross-repo work.** For every idea, walk the checklist of repos in this project and note what (if anything) each needs:
   - Contracts / shared types — new DTOs, event names, telemetry taxonomy?
   - Backend — endpoints? Migrations? Background workers? External service wiring?
   - Web — routes? UI? Middleware gates? Analytics call sites?
   - iOS — screens? Navigation? Service integrations? Analytics?
   - Android — equivalents? Push hooks? Analytics?
   - UI kits — new primitives?
   - Design system — token additions? Component contracts?
   - QA — e2e? UI tests? Snapshots?
   - Docs — ADR needed?
   - Infra — secrets? Deploy config? Env vars?

   Only call out repos / modules that actually need work. Be specific. If you don't know enough to infer, say so rather than fabricating detail.

3. **Draft the mini-spec.** Structure the ticket description exactly as:

   ```markdown
   ## Why

   <1-3 sentences on the user value + why it's worth capturing.>

   ## Proposed shape

   <3-8 sentences describing the user-facing flow, key decisions, and notable edge cases.>

   ## Work inferred

   - **<repo-or-module-name>** — <specific work. Only include items that need work.>

   ## Open questions

   - <Question 1>
   - <Question 2>

   ## Size estimate

   <XS / S / M / L / XL plus one sentence of rationale.>

   ## Trigger to revisit

   <When this should come off the parking lot.>
   ```

4. **Resolve destination + file via the tracker.**

   Read `AGENTS.md` → "Tracker destinations" section (written by the setup). It specifies how /idea should file:
   - Mode `project`: file into the configured ideas project / view.
   - Mode `label`: file as an unassigned issue with the configured ideas label applied, no specific project.
   - Mode `unset` or missing section: ask the user where ideas should go (single batched question, then write back to AGENTS.md so this doesn't repeat).

   Then call:

   ```
   <TRACKER_MCP_PREFIX>save_issue({
     team / project: <destination_id_or_null>,
     title: "<6-12 word descriptive, noun-led; no 'Idea:' prefix>",
     description: "<full mini-spec from step 3>",
     priority: 4,
     assignee: null,
     labels: ["feature", "platform:<primary>", <plus configured ideas-label if mode == "label">]
   })
   ```

   Platform label: use `platform:all` if the idea spans 3+ platforms; otherwise the primary user touchpoint.

5. **Report back** (2-3 lines):
   - Ticket URL
   - One-sentence scope summary
   - Any assumption the user may want to correct

## Rules

- Don't enter plan mode, don't ask clarifying questions. Fire-and-forget.
- Don't fabricate detail you don't know. Write "unclear — flag for design review" instead.
- Don't skip cross-repo inference even on small ideas — that's the point of the skill.
- Don't assign to a human. `assignee: null` is mandatory.
- Don't mark Urgent or High. Priority is always Low.
- Don't dispatch subagents. The ticket parks until future sprint triage.

## After filing

Done. The ticket sits in "Ideas / Backlog" until DoE triages at a future sprint kickoff.
````

---

## §12 — Memory system layout

The agent harness stores auto-memory per-workspace. The exact path depends on the harness:

- **Claude Code:** `~/.claude/projects/<slugified-workdir>/memory/` (slug = workdir path with `/` → `-`).
- **Codex:** check the platform docs; typically `~/.codex/...` or similar.
- **Other harnesses:** check their docs.

**Files in the memory folder:**
- `MEMORY.md` — index file. Auto-loaded into every session. Each entry is one line: `- [Title](file.md) — one-line hook`. Keep under 200 lines.
- One file per memory, kebab-cased: `user_role.md`, `feedback_pr_hygiene.md`, `project_current_sprint.md`, `reference_tracker_dashboard.md`.

**Memory types:**
- `user_*.md` — facts about the human user (role, expertise, preferences).
- `feedback_*.md` — guidance the user gave about how to work. Include "Why" + "How to apply" lines.
- `project_*.md` — project state (current sprint, deadlines, decisions). Convert relative dates to absolute.
- `reference_*.md` — pointers to external systems (tracker projects, dashboards, runbooks).

**What NOT to put in memory:**
- Code patterns, architecture, file paths (derivable from the code).
- Git history (use `git log`).
- Debug recipes (commit messages have the context).
- Anything already in AGENTS.md.

---

## §13 — Templates

### 13.1 — Root `AGENTS.md` template

```markdown
# <Project Name> — Agent Working Guide

> Working memory for the <Project Name> workspace. <Brief one-sentence
> description of what the product is.>
>
> <If multi-repo:> The parent `<project>/` directory is **NOT a git repo**.
> Each `<project>-*` subfolder is its own repo.

---

## Repo / module map

| Folder | Purpose | Stack |
|---|---|---|
| `<project>-contracts/` | Shared types + DTOs. | <stack> |
| `<project>-api/` | Backend. | <stack> |
| `<project>-web/` | Web client. | <stack> |
| ... | ... | ... |

---

## Your role: Director of Engineering (DoE)

<Operating mode: planner-only / sole-IC / hybrid. See §2 of
team-process-spec.md for definitions.>

The overall process: the human(s) set WHAT, the CTO + CPO + CDO triad
reviews proposals in parallel as subagents, their HOW guidance feeds back
into the plan.

Every change goes through a branch + PR. Author commits as the human's git
identity.

---

## Authority — humans set WHAT, triad advises on HOW

CTO/CPO/CDO are reviewers, not scope-deciders. When triad recommends scope
changes, DoE flags to the human — DoE does NOT cut from scope on triad
pushback alone.

When scope is disputed: **the human wins.** Triad's HOW guidance is
incorporated; their WHAT pushback becomes open questions.

---

## Sprint workflow

1. Read PRD + design + previous sprint completion.
2. Draft v1 plan to scratch.
3. Run CTO + CPO + CDO triad in parallel.
4. Synthesize v2 = human-set scope + triad's HOW guidance.
5. Post v2 as tracker document.
6. ADR: `<docs>/decisions/NNNN-sprint-N-execution-plan.md`.
7. Build tracker scaffolding: initiative → projects → parent kind:spec
   tickets → execution-order children → 5 phase milestones.
8. Execute per operating mode.

**Mandatory pre-close gate:** canonical happy-path walkthrough on every
shipped platform with screenshots. NEVER close while a deploy is failing.

---

## Tracker

- **Hierarchy:** Initiative → Project → Milestone → Issue.
- **Assignee rule — `assignee: null` ALWAYS** unless ticket title starts
  with "<HumanName>:".
- **Canonical labels:** see §4 of team-process-spec.md.

## Tracker destinations

> This section is the canonical signature that the setup has run
> here. `/defect` and `/idea` read it to know where to file. Edit via
> the setup's TEAM UPDATE mode, not by hand.

- **Tracker type:** Linear / Jira / GitHub Issues / Notion
- **Workspace / team:** `<name>` (id: `<id>`)
- **`/defect` destination:**
  - Mode: `project` | `triage` | `label` | `unset`
  - Target: `<project name>` (id: `<id>`) OR `<label name>` OR `Built-in Triage`
- **`/idea` destination:**
  - Mode: `project` | `label` | `unset`
  - Target: `<project name>` (id: `<id>`) OR `<label name>`
- **Planning cadence:** `existing-cadence` | `10-day-phases` | `custom` | `none`
  - Detail: `<e.g., "2-week cycles, currently on Cycle 14">` or
    `<"M0 — Workflow Adoption project with 5 phase milestones">`
- **Issue ID prefix:** `PROJ-NN`
- **Workflow version:** `<aew-version>` installed by `<contributor>` on `<date>`

## Docs location

- **ADR location:** `docs/decisions/` | `<docs-repo>/decisions/` | `<tracker-attached>` | `skipped`
- **Strategy / PRD docs:** `<path or tracker location>`
- **Design source:** `<path or URL>`

---

## PR hygiene

- Branch: `<user>/<id>-<slug>`
- Commit author: <human's identity>
- PR body trailer: `Closes <ID>` per ticket
- Never `--no-verify`, force-push to main, or amend published commits
- Stage specific files; avoid `git add -A`
- DoE reviews via subagent code-reviewer, fixes blockers, merges
- DoE watches every PR through deploy success
- README freshness: update in same PR if setup / commands / routes change

---

## Worktrees (if using)

Worktrees live INSIDE the repo at `<repo>/.worktrees/<slug>`. Never in the
parent folder. Every repo's `.gitignore` includes `/.worktrees/`.

---

## Working agreements

- No side work during a sprint.
- Contracts lock end-of-Day-2.
- Tests come first.
- Secrets never in tracker.
- Deploys never block on observability.
- Auto-alarms route to DoE.
- Shared-resource writes pre-authorized for trusted infra.
- Cross-platform parity audit on bug fixes.
- Notifications-as-feature-shape at scope time.

---

## Architectural philosophy

**Dumb clients, smart server** — logic lives on the server; clients render.

---

## Quick reference

| Thing | Location |
|---|---|
| Current sprint | <tracker URL> |
| Tracker workspace | <URL> |
| Git host | <URL> |
| Live URLs | <list> |
| PRD | <path> |
| Design source | <path> |
| Memory files | `<harness-specific path>` |
```

### 13.2 — Per-repo / per-module `AGENTS.md` template

```markdown
# <repo-or-module-name> — Agent Working Guide

> Per-repo working memory. Layered on top of the root AGENTS.md.

## Stack

<one-paragraph summary>

## Module layout

<directory tree of key modules>

## Build / test

```bash
<build command>
<test command>
<typecheck command>
```

## Repo-specific rules

- <Rule 1>
- <Rule 2>

## Quick reference

| Thing | Location |
|---|---|
| Production URL | <URL> |
| CI config | `.github/workflows/ci.yml` |
| Deploy config | <path> |
```

### 13.3 — Initial `MEMORY.md` seed

```markdown
- [User identity](user_identity.md) — <role>, <handle>, <email>
- [Project current state](project_current_state.md) — <one-line summary>
- [Tracker reference](reference_tracker.md) — workspace URL, team name, key project IDs
- [Git host reference](reference_git_host.md) — org URL + repo list
```

### 13.4 — Initial `user_identity.md`

```markdown
---
name: user-identity
description: Human user's role, git handle, email, and any preferences stated.
metadata:
  type: user
---

- **Name:** <name or initials>
- **Git host handle:** <handle>
- **Email:** <email>
- **Role:** <CEO / CTO / IC engineer / etc.>
- **Tech depth:** <e.g., "senior backend engineer, new to mobile">
- **Preferences:** <if any captured so far>
```

---

## §14 — Common pitfalls + how to avoid them

1. **Tracker auto-assigns to caller.** ALWAYS pass `assignee: null` (or whatever the tracker's equivalent is) explicitly on every ticket-creation call. Single most common failure mode.
2. **Markdown lists with multiple URLs may truncate** in some trackers (Linear in particular). Split into separate paragraphs if a list gets cut off.
3. **Tracker schemas sometimes lie.** Linear's `save_status_update` accepts `type: "project"` even though the schema enum lists only `"initiative"`. If something says it doesn't accept a value but you know it should, try anyway before giving up.
4. **First PR on a brand-new repo fails because there's no main branch.** Seed main first via `gh repo create --add-readme` or a contents-API commit before opening feature-branch PRs.
5. **Triad reviewers disagree on scope.** Don't pick a winner yourself — surface to the human as an open question.
6. **Snapshot-test baselines drift across CI architectures.** Pin the runner architecture in CI config (e.g., arm64 on macOS-14, x86_64 on Ubuntu).
7. **Worktrees pollute the parent folder.** Always `cd` into the repo first; never use `..` paths with `git worktree add`.
8. **Generated config files strip manual edits.** If you have a generated `Info.plist`, `pbxproj`, etc., declare all keys in the source-of-truth config (e.g., `project.yml` for xcodegen), not in the generated file directly.
9. **Cross-platform bugs missed because audit checked one platform.** Every iOS bug-fix ticket gets a sibling Android cross-check before merge, and vice versa.
10. **Memory grows stale.** Memory captures point-in-time state — claims about code behavior or file:line citations may be outdated. Verify against current code before acting on a recalled memory.

---

## §15 — Setup checklist (the agent executes this on first run)

Use the task-tracking tool (TaskCreate / equivalent) to mark each as it lands.

**Phase A — Introspect (read-only):**
- [ ] **A1.** Walk the actual file tree of the current folder + immediate siblings.
- [ ] **A2.** Detect git host org + repo list.
- [ ] **A3.** Detect tracker MCP / CLI availability + team/workspace name.
- [ ] **A4.** Detect local git user.name + user.email.
- [ ] **A5.** Detect existing AGENTS.md / CLAUDE.md / .claude/ / .agents/.
- [ ] **A6.** Detect stack-hint files (package.json, Cargo.toml, build.gradle, etc.).
- [ ] **A7.** Detect docs storage signals (docs/ folder, dedicated docs repo, tracker documents in use, top-level PRD/architecture files).
- [ ] **A8.** Read tracker state (projects, sprints/cycles, labels, built-in Triage availability, active issue count per project) — DON'T WRITE.
- [ ] **A9.** Detect **workflow installation state** (FRESH / PARTIAL / INSTALLED) by scanning for: AGENTS.md "Tracker destinations" section, setup ADR, canonical labels co-existing in tracker, per-repo AGENTS.md files.
- [ ] **A10.** Classify the workspace shape: GREENFIELD / EXISTING-COMPATIBLE / EXISTING-DIVERGENT / AMBIGUOUS.

**Phase B — Ask (single batched turn):**
- [ ] **B1.** If install state is PARTIAL/INSTALLED, ask the scope question first (sync me / complete / team update / re-install). If FRESH, ask workspace classification confirmation.
- [ ] **B2.** Ask follow-up questions only as needed by the chosen mode:
       - LOCAL SYNC: no further questions; skip to memory seed.
       - COMPLETE-PARTIAL: only the questions whose answers aren't already in AGENTS.md / tracker.
       - TEAM UPDATE / FRESH / RE-INSTALL: full Q2-Q15 (skip any auto-detected).

**Phase C — Scaffold files (mode-dependent):**
- [ ] **C1.** LOCAL SYNC: skip to memory seed (C8) only.
- [ ] **C2.** Root `AGENTS.md` from §13.1, including "Tracker destinations" + "Docs location" sections.
- [ ] **C3.** `CLAUDE.md` compatibility shim.
- [ ] **C4.** Per-repo / per-module `AGENTS.md` stubs from §13.2.
- [ ] **C5.** `.claude/skills/defect/SKILL.md` from §11.1 (skills now read destinations from AGENTS.md, not hardcoded).
- [ ] **C6.** `.claude/skills/idea/SKILL.md` from §11.2.
- [ ] **C7.** Add `/.worktrees/` to `.gitignore` if using worktrees.
- [ ] **C8.** ADR placeholder at the user-chosen docs location (skip if user picked tracker-attached or "skip ADRs").
- [ ] **C9.** Memory seed (always): `MEMORY.md` + `user_identity.md` + `project_current_state.md` + `reference_tracker.md`. In LOCAL SYNC mode, seed these from existing AGENTS.md + tracker state.

**Phase D — Tracker writes (only what the user approved; skip in LOCAL SYNC):**
- [ ] **D1.** Create /defect destination project ONLY if user picked "create new" in Q9.
- [ ] **D2.** Create /idea destination project ONLY if user picked "create new" in Q10.
- [ ] **D3.** Create planning artifacts ONLY if user opted in via Q11 (NEVER auto-create "M0 / Current Sprint").
- [ ] **D4.** Add missing labels ONLY if user opted in via Q12.
- [ ] **D5.** Create initiative-attached docs ONLY if user picked tracker-attached docs in Q15.
- [ ] **D6.** Record final destinations + cadence + docs location in AGENTS.md "Tracker destinations" + "Docs location" sections.

**Phase E — Report:**
- [ ] **E1.** Print final summary: files written/skipped, tracker writes performed (or "none — used existing setup"), manual follow-ups, next prompt.

---

## §16 — Notes for adaptation

This spec is intentionally opinionated. Some pieces are universal, others are configurable. Here's what's safe to change vs what holds the workflow together.

### Safe to change

- **Tracker.** Linear-style hierarchy is the model, but the workflow adapts to GitHub Issues, Jira, Notion, or anything with a queryable API.
- **Stack.** Stack-agnostic. The skill files have generic placeholders; the setup fills them in based on what it detects.
- **Sprint cadence.** The default is 10-day sprints with 5 phase milestones. Shorter / longer sprints work fine — adjust the phase milestones to fit.
- **Triad composition.** CTO + CPO + CDO is the default. Drop CDO for non-design-heavy projects. Add Staff <platform> reviewers for complex platform-specific decisions. Add Legal / Security for regulated domains.
- **Operating mode.** PLANNER-ONLY / SOLE-IC / HYBRID — pick whichever fits the team. Switch any time.

### Hold these constant

- **Human owns WHAT, the agent owns HOW.** The authority split is the load-bearing concept.
- **`assignee: null` on every ticket call** unless explicitly assigning to a human. This is the #1 footgun across multiple trackers.
- **Reviews happen in parallel.** Sequential reviews lose orthogonality.
- **ADRs for cross-cutting decisions.** Without them, decisions get re-litigated every sprint.
- **The tracker is the source of truth.** Not chat, not memory.
- **Pre-close verification gate.** Without it, "done" drifts toward "merged".

### When to write a custom adaptation

If you find yourself ignoring §9 (working agreements) for more than one sprint, write down what you're doing instead and put it in your project's AGENTS.md. The spec is meant to be a starting point, not a religion.

---

## §17 — Final notes for the setup agent

After running the setup checklist:
- Print a clean summary of what you created.
- Print a list of manual follow-ups the human needs to do (auth steps, secrets, design uploads).
- Print the exact next prompt the human should run (e.g., "Draft Sprint 1 plan from `<PRD-path>`" or "Scan open alarms").
- Save what you learned about the workspace into memory files (project state, tracker references).
- Do NOT start drafting Sprint 1 yourself — let the human decide when to kick off.

If the operating mode is PLANNER-ONLY, also explain what kinds of work you will and won't auto-pick-up so the human knows when to delegate explicitly.

---

**End of spec.** Edit this file to evolve the workflow. Re-run the prompt against an updated agent session and the harness will pick up changes idempotently.
