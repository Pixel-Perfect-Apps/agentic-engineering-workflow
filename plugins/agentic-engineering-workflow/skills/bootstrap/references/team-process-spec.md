# Agentic Engineering Workflow — Spec

> A portable, opinionated workflow for software teams where Claude is part of the team. Two ways to adopt it: install the [Claude Code plugin](#install-via-plugin-recommended) (one command, everything scaffolded), or drop this single `.md` file into a workspace and paste the [bootstrap prompt](#-prompt-to-paste-) into a fresh Claude session.
>
> Tracker-agnostic, stack-agnostic. Works for solo founders, small teams, or multi-agent setups.

---

## What this is

A bundle of opinions about how to run a software project where Claude is one of the contributors:

- **Roles are separated.** A human (or humans) owns **WHAT** to build. Claude owns **HOW**. When the two disagree on WHAT, the human wins. HOW guidance is incorporated.
- **Cross-cutting decisions get reviewed by 2-3 orthogonal critics in parallel** (CTO subagent for tech, CPO for product, CDO for design — pick whichever fit the project). The triad reviews proposals before they land; their feedback is mandatory input, not optional.
- **The issue tracker is the source of truth.** Not chat, not memory, not commits. Whatever tracker the team uses (Linear, GitHub Issues, Jira, Notion — pick one) becomes the single dashboard. Claude updates it as work progresses.
- **Decisions leave a paper trail (ADRs).** Anything touching multiple modules / repos gets a numbered Architecture Decision Record.
- **Contract lock + phase milestones.** Sprints have explicit phases (Contract Lock → Core Build → UX → Integration → Beta Readiness). Contracts between layers freeze at end-of-Day-2.
- **Bug + idea capture is fire-and-forget.** `/defect` and `/idea` slash commands take a one-liner, infer everything (priority, repro, hypothesis, cross-repo scope), file a ticket with no follow-up questions. Zero ceremony during testing.
- **Verification gates the close.** Sprints don't close while a deploy is failing or verification is "deferred."

### Good fit for

- Solo founder + Claude (Claude executes; human approves)
- Small teams (2-5 humans) where Claude is a peer agent / coordinator
- Multi-platform products (web + mobile + backend) where contracts between layers matter
- Single-platform projects (web-only, backend-only) — just skip the platforms that don't apply
- Open-source projects with mixed human/AI contributors

### Probably not a fit

- Research / exploratory code where ADR overhead slows you down (use this after the prototype hardens)
- Throwaway prototypes
- Projects that already have a deeply embedded workflow you don't want to disrupt

---

## Install via plugin (recommended)

The workflow is published as a Claude Code plugin. One-time install:

```
/plugin marketplace add Pixel-Perfect-Apps/agentic-engineering-workflow
/plugin install agentic-engineering-workflow@agentic-engineering-workflow
```

After install, three things become available in any workspace:
- `/defect` and `/idea` slash commands for fire-and-forget bug + idea capture.
- A **bootstrap** skill that scaffolds AGENTS.md / tracker / ADR / memory for a workspace. Invoke it by asking Claude to "bootstrap the agentic engineering workflow" or directly via `/agentic-engineering-workflow:bootstrap`.
- This full spec, available as a reference doc inside the plugin.

## Install manually (no plugin)

Don't want a plugin install? Drop just this `.md` file into your workspace root and paste the [prompt block](#-prompt-to-paste-) below into a fresh Claude session. Claude will read the file end-to-end and execute the bootstrap.

## Prerequisites (either path)

- An issue-tracker connection: Linear MCP, GitHub via `gh` CLI, Jira via its MCP, or any tracker with a queryable API.
- Git access (`gh auth login` or equivalent).
- Whatever CLIs your stack needs (npm, gradle, xcodebuild, vercel, etc.).

---

## ⌜ PROMPT TO PASTE ⌟

> Copy this entire block verbatim into a fresh Claude session. If you've installed the plugin, you can invoke the bootstrap skill directly instead; this prompt is for manual installs where you dropped the spec `.md` into the workspace yourself.

```text
You are taking on the "Director of Engineering" (DoE) role for this project.
We follow a specific opinionated workflow that I want you to set up here,
end-to-end, in one pass.

Read the agentic engineering workflow spec end-to-end before doing anything
else. The spec lives either at `team-process-spec.md` in this workspace
(manual install), or inside the installed plugin's bootstrap skill
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
   
   What to look at:
   - Folder contents at the top level. Is it empty, near-empty (only
     dotfiles), or does it contain real code / repos / config?
   - Workspace layout: single repo, multi-repo monorepo (sibling folders
     each with their own `.git`), workspace-style monorepo (root
     `package.json` with `workspaces`, Turborepo `turbo.json`, Nx
     `nx.json`, pnpm-workspace.yaml), or something else.
   - Git hosting: `gh auth status` for GitHub, `glab auth status` for
     GitLab, etc. Capture the org/group + repo names.
   - Issue tracker MCP availability: try in this order — Linear
     (mcp__linear__*, mcp__plugin_linear_linear__*, mcp__claude_ai_Linear__*),
     Jira (mcp__atlassian__*, mcp__jira__*), Notion (mcp__notion__*),
     Plain GitHub Issues via `gh issue`. Use whichever responds first.
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
   batched-question mechanism) in a SINGLE turn. Lead with the
   classification confirmation so we anchor on the right starting point
   before drilling into details.

   **Question 1 (ALWAYS) — classification confirmation:**
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
   
   2. **Project name + short slug** (used in branch names, ADR
      filenames, etc.).
   3. **Issue tracker confirmation** — which tracker, and what are the
      default project / view names you want for "Bug Triage" and
      "Ideas / Backlog"?
   4. **Issue ID prefix** (e.g., PROJ-NN — used in branch names + PR
      trailers). For trackers that auto-generate IDs, what's the
      format?
   5. **Branch convention** (e.g., `<username>/<id>-<slug>` or
      `feature/<id>-<slug>` or just `<id>-<slug>`).
   6. **Operating mode**:
        a) PLANNER-ONLY — Claude plans, dispatches reviewers, files
           tickets, monitors. Other humans/agents execute.
        b) SOLE-IC — Claude executes every ticket end-to-end,
           sequentially.
        c) HYBRID — Planner by default; executes when explicitly
           delegated.
   7. **Worktree usage**: yes (`.worktrees/<slug>` inside each repo)
      or no (just feature branches in the main checkout).
   8. **Sprint cadence**: fixed (1-week, 2-week, etc.) or
      event-driven.
   9. **Triad reviewers to enable** (any subset of the canonical
      three):
        - CTO (technical feasibility)
        - CPO (product priority — needs a PRD reference to be
          effective)
        - CDO (design fidelity — needs a design source to be
          effective)
        - Or specify others (Staff <platform>, Legal, Security, etc.)
   10. **Canonical artifacts** to feed reviewers (paths if local,
       URLs if hosted):
        - PRD / product spec
        - Design source (Figma, design system docs)
        - Architecture overview
   11. **Stacks present** in the project (so per-repo AGENTS.md
       templates can be filled correctly): backend lang/framework, web
       stack, mobile platforms, shared-types layer, infra/deploy, QA
       harness, etc. SKIP this question entirely if introspection
       already gave you a confident answer.

C. SCAFFOLD THE FILES
   After I answer, create or update (idempotently — check before
   overwriting). **Adapt every template to the workspace's actual
   layout** — don't blindly copy the templates if the project doesn't
   match. In particular:
   
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
   - An ADR placeholder noting the workflow was adopted, in whichever
     `decisions/` directory makes sense for the layout: `docs/decisions/`
     for single-repo, `<docs-repo>/decisions/` for multi-repo. If no
     docs location exists, create `docs/decisions/0001-bootstrap.md`.
   - Memory bootstrap files at the path the Claude harness uses
     (typically `~/.claude/projects/<slugified-workdir>/memory/` for
     Claude Code): `MEMORY.md` + `user_identity.md` +
     `project_current_state.md` + `reference_tracker.md`.

D. SET UP THE ISSUE TRACKER
   Using whichever tracker MCP/CLI you detected, create (idempotent — check
   before creating):
   - "Bug Triage" project / view / label.
   - "Ideas / Backlog" project / view / label.
   - Label taxonomy (adapt label names to the tracker's conventions; some
     trackers use tags, others use components, others use projects):
       - Kind: `bug`, `feature`, `improvement`, `kind:spec`
       - Sprint: `sprint:s1` (next active sprint)
       - Platform: one per platform present (`platform:web`, `:ios`,
         `:android`, `:backend`, `:all`)
       - Area: `area:<module>` for each module present
       - Ops: `blocker`, `alarm:deploy-failure`, `gate:beta-ready`
   - Initial "M0 / Current Sprint" document or epic with a placeholder body.

E. REPORT
   Print a final summary:
   - Files created / updated (paths).
   - Tracker objects created (with URLs/IDs).
   - Manual follow-ups required (auth steps, secrets to set, design files to
     link, etc.).
   - The exact next prompt I should run to start working in this setup
     (e.g., "Draft Sprint 1 plan from <PRD path>" or "Scan open alarms").

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
2. **AI agents work best with explicit operating contracts.** Telling Claude "you're the DoE" with clear authority boundaries produces better results than treating it as an oracle that knows what to do.
3. **Reviews catch things makers miss.** A draft that survives three orthogonal critiques (technical, product, design) is meaningfully more durable than one signed off by a single reviewer.
4. **Process pays back proportionally to project complexity.** The triad-review + ADR overhead is overkill for a single-file script and essential for a multi-repo product. The bootstrap asks about operating mode so the overhead can scale.
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
| Director of Engineering (DoE) | Claude | **HOW** it ships. Implementation, sequencing, tickets, ADRs. |
| CTO (subagent) | Claude dispatching a general-purpose subagent | Technical feasibility, architecture, risk. |
| CPO (subagent) | Claude dispatching a general-purpose subagent | Product priority, sequencing — **MUST cite the PRD** if one exists. |
| CDO (subagent) | Claude dispatching a general-purpose subagent | Design fidelity — **MUST cite design system** if one exists. |
| Additional reviewers (optional) | Claude dispatching subagents | Staff-level platform-specific review (e.g., Staff iOS, Staff Backend), Legal, Security, etc. |

The triad reviewers are **reviewers, not scope-deciders.** When they recommend scope changes ("cut this feature", "this isn't in the PRD"), DoE flags to the human — DoE does NOT cut from scope on triad pushback alone. **Human wins when scope is disputed.** Triad's HOW guidance is incorporated; their WHAT pushback becomes open questions for the human.

### Operating modes

Pick one at bootstrap. Switchable later.

- **PLANNER-ONLY** (recommended when there's a team of humans + agents): Claude drafts plans, dispatches reviewers, files tickets, monitors, files defects/ideas, posts status updates. Other humans / agents pick up implementation. Claude does NOT auto-execute implementation work unless explicitly delegated.
- **SOLE-IC** (recommended for solo founder + Claude): Claude executes every ticket end-to-end. Sequentially, one ticket at a time. Code → test → push → watch deploy → next ticket.
- **HYBRID**: Defaults to planner; executes only when explicitly delegated. Each delegation is one ticket — does not generalize into permanent IC mode.

---

## §3 — Repo / monorepo layout

Pick whichever fits the project.

### Layout A — Sibling-repo monorepo (recommended for multi-platform products)

```
<parent-folder>/                    ← NOT a git repo; holds AI config + sibling repos
  AGENTS.md                         ← root working guide (this is what Claude reads first)
  CLAUDE.md                         ← compatibility shim → AGENTS.md
  .claude/                          ← Claude Code config
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

**ALWAYS pass `assignee: null` explicitly** on every ticket-creation call when the tracker MCP defaults to "assign to caller". The caller is often Claude's authenticated user (= the human running the session), which pollutes the human's queue with tickets they shouldn't be on the hook for. The title-prefix convention is the only way a ticket gets assigned at creation; everything else stays in the triage pool.

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
- **Commit author:** the human's git identity, not Claude's. Configure on first run if needed.
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

Each skill goes in `.claude/skills/<name>/SKILL.md` (Claude Code) and/or `.agents/skills/<name>/SKILL.md` (Codex). The bootstrap Claude should:
1. Detect which CLI is configured in the workspace and write to the right path.
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

### 6. File via the tracker

```
<TRACKER_MCP_PREFIX>save_issue({
  team / project: "<BUG_TRIAGE_PROJECT_ID>",
  title: "<5-10 word noun-led summary>",
  description: "<full markdown above>",
  priority: <1|2|3|4>,
  assignee: null,
  labels: ["bug", "platform:<primary>"]
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

4. **File via the tracker:**

   ```
   <TRACKER_MCP_PREFIX>save_issue({
     team / project: "<IDEAS_PROJECT_ID>",
     title: "<6-12 word descriptive, noun-led; no 'Idea:' prefix>",
     description: "<full mini-spec from step 3>",
     priority: 4,
     assignee: null,
     labels: ["feature", "platform:<primary>"]
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

The Claude harness stores auto-memory per-workspace. The exact path depends on the harness:

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
team-process-bootstrap.md for definitions.>

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
- **Canonical labels:** see §4 of team-process-bootstrap.md.

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

### 13.3 — Initial `MEMORY.md` bootstrap

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

## §15 — Setup checklist (Claude executes this on first run)

Use the task-tracking tool (TaskCreate / equivalent) to mark each as it lands.

- [ ] **A1.** Walk the actual file tree of the current folder + immediate siblings.
- [ ] **A2.** Detect git host org + repo list. Record findings.
- [ ] **A3.** Detect tracker MCP / CLI availability + team/workspace name.
- [ ] **A4.** Detect local git user.name + user.email.
- [ ] **A5.** Detect existing AGENTS.md / CLAUDE.md / .claude/ / .agents/.
- [ ] **A6.** Detect stack-hint files (package.json, Cargo.toml, build.gradle, etc.).
- [ ] **A7.** **Classify** the workspace as GREENFIELD / EXISTING-COMPATIBLE / EXISTING-DIVERGENT / AMBIGUOUS. Record reasoning.
- [ ] **B1.** AskUserQuestion: confirm classification (Q1) + ask anything else not detected (Q2-Q11). Single batched turn.
- [ ] **C1.** Write root `AGENTS.md` from §13.1 template, filled with answers.
- [ ] **C2.** Write `CLAUDE.md` compatibility shim.
- [ ] **C3.** Write per-repo / per-module `AGENTS.md` stubs from §13.2.
- [ ] **C4.** Write `.claude/skills/defect/SKILL.md` from §11.1, with tracker MCP prefix + project IDs filled in.
- [ ] **C5.** Write `.claude/skills/idea/SKILL.md` from §11.2.
- [ ] **C6.** Add `/.worktrees/` to each repo's `.gitignore` if using worktrees.
- [ ] **C7.** Write `docs/decisions/0001-bootstrap.md` ADR.
- [ ] **C8.** Bootstrap memory: `MEMORY.md` + `user_identity.md` + `project_current_state.md` + `reference_tracker.md`.
- [ ] **D1.** Tracker: ensure team / workspace exists. Capture ID.
- [ ] **D2.** Tracker: create "Bug Triage" project / view / label. Capture ID.
- [ ] **D3.** Tracker: create "Ideas / Backlog" project / view / label. Capture ID.
- [ ] **D4.** Tracker: ensure label taxonomy exists.
- [ ] **D5.** Tracker: create initial "M0 / Current Sprint" document with placeholder.
- [ ] **D6.** Patch project IDs into the freshly-written skill files (C4-C5).
- [ ] **E1.** Print final summary: files, tracker objects, follow-ups, next prompt.

---

## §16 — Notes for adaptation

This spec is intentionally opinionated. Some pieces are universal, others are configurable. Here's what's safe to change vs what holds the workflow together.

### Safe to change

- **Tracker.** Linear-style hierarchy is the model, but the workflow adapts to GitHub Issues, Jira, Notion, or anything with a queryable API.
- **Stack.** Stack-agnostic. The skill files have generic placeholders; the bootstrap fills them in based on what it detects.
- **Sprint cadence.** The default is 10-day sprints with 5 phase milestones. Shorter / longer sprints work fine — adjust the phase milestones to fit.
- **Triad composition.** CTO + CPO + CDO is the default. Drop CDO for non-design-heavy projects. Add Staff <platform> reviewers for complex platform-specific decisions. Add Legal / Security for regulated domains.
- **Operating mode.** PLANNER-ONLY / SOLE-IC / HYBRID — pick whichever fits the team. Switch any time.

### Hold these constant

- **Human owns WHAT, Claude owns HOW.** The authority split is the load-bearing concept.
- **`assignee: null` on every ticket call** unless explicitly assigning to a human. This is the #1 footgun across multiple trackers.
- **Reviews happen in parallel.** Sequential reviews lose orthogonality.
- **ADRs for cross-cutting decisions.** Without them, decisions get re-litigated every sprint.
- **The tracker is the source of truth.** Not chat, not memory.
- **Pre-close verification gate.** Without it, "done" drifts toward "merged".

### When to write a custom adaptation

If you find yourself ignoring §9 (working agreements) for more than one sprint, write down what you're doing instead and put it in your project's AGENTS.md. The spec is meant to be a starting point, not a religion.

---

## §17 — Final notes for the bootstrap Claude

After running the setup checklist:
- Print a clean summary of what you created.
- Print a list of manual follow-ups the human needs to do (auth steps, secrets, design uploads).
- Print the exact next prompt the human should run (e.g., "Draft Sprint 1 plan from `<PRD-path>`" or "Scan open alarms").
- Save what you learned about the workspace into memory files (project state, tracker references).
- Do NOT start drafting Sprint 1 yourself — let the human decide when to kick off.

If the operating mode is PLANNER-ONLY, also explain what kinds of work you will and won't auto-pick-up so the human knows when to delegate explicitly.

---

**End of spec.** Edit this file to evolve the workflow. Re-run the prompt against an updated Claude session and the harness will pick up changes idempotently.
