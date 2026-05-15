# Agentic Engineering Workflow

> Turn your AI coding agent into a **Director of Engineering** for your team. Sprint cadence, multi-agent review triad, ADR discipline, and one-keystroke bug + idea capture.

A portable, opinionated workflow for software teams where an AI coding agent is part of the team. Distributed as a Claude Code plugin for one-command install — and the underlying skills + spec are agent-agnostic, so Codex, Cursor, Cline, and any other agent that reads SKILL.md-style instructions can use the same workflow with a manual install.

Drop it into any workspace and you get:

- 🎯 **A bootstrap skill** that scaffolds `AGENTS.md`, a `CLAUDE.md` shim, ADR structure, memory bootstrap, tracker projects + labels — all adapted to your project's actual layout (greenfield, monorepo, or single-repo).
- 🐛 **`/defect`** — fire-and-forget bug capture from chat. Infers platform, build, repro steps, severity, root-cause hypothesis, and likely-culprit files. Files a tracker ticket with all of it.
- 💡 **`/idea`** — parking-lot idea capture. Infers cross-repo scope, drafts a mini-spec, files it for future sprint triage.
- 📚 **A full workflow spec** (sprint phases, triad review pattern, contract-lock discipline, working agreements, common pitfalls) you can read once and reference forever.

Tracker-agnostic (Linear, GitHub Issues, Jira, Notion). Stack-agnostic. Agent-agnostic. Works solo, scales to small teams.

---

## Install — Claude Code (one command)

```
/plugin marketplace add Pixel-Perfect-Apps/agentic-engineering-workflow
/plugin install agentic-engineering-workflow@agentic-engineering-workflow
```

After install, ask your agent to **"bootstrap the agentic engineering workflow"** in any workspace, or invoke `/agentic-engineering-workflow:bootstrap` directly.

`/defect` and `/idea` are available globally after install — no project-by-project setup.

## Install — Codex, Cursor, Cline, or other agents (manual)

These agents don't share Claude Code's plugin format, but the **skills + spec are portable**. Two options:

**A. Per-project install (Codex `.agents/skills/` convention):**

```bash
# From your project root:
mkdir -p .agents/skills
git clone --depth 1 https://github.com/Pixel-Perfect-Apps/agentic-engineering-workflow /tmp/aew
cp -r /tmp/aew/plugins/agentic-engineering-workflow/skills/* .agents/skills/
rm -rf /tmp/aew
```

Then point your agent at `.agents/skills/bootstrap/SKILL.md` to kick off the bootstrap. The skill content is generic — it works for any agent that follows SKILL.md-style instructions.

**B. Drop-in spec only (no skills, any agent):**

Save just the spec into your workspace and paste the bootstrap prompt to a fresh agent session:

```bash
curl -O https://raw.githubusercontent.com/Pixel-Perfect-Apps/agentic-engineering-workflow/main/plugins/agentic-engineering-workflow/skills/bootstrap/references/team-process-spec.md
```

Then open the file, find the `⌜ PROMPT TO PASTE ⌟` block, and paste it to your agent. The agent reads the spec and executes the same five-phase bootstrap. You miss the `/defect` and `/idea` slash commands but the rest works.

---

## What the bootstrap produces

A single skill turns any workspace into a structured project with:

- **`AGENTS.md`** at the root — the working guide your agent reads on every session start.
- **Per-repo / per-module `AGENTS.md`** stubs at the module boundaries.
- **`CLAUDE.md`** compatibility shim pointing to `AGENTS.md` (for Claude Code's session start lookup).
- **`docs/decisions/0001-bootstrap.md`** — the first ADR, marking workflow adoption.
- **Memory bootstrap** (`user_identity.md`, `project_current_state.md`, `reference_tracker.md`) at the agent harness's per-workspace memory path.
- **Tracker scaffolding** — "Bug Triage" + "Ideas / Backlog" projects, canonical label taxonomy (`bug`, `feature`, `improvement`, `kind:spec`, `sprint:s1`, `platform:*`, `area:*`, `blocker`, `alarm:deploy-failure`, `gate:beta-ready`).
- **An initial "M0 / Current Sprint"** document with a placeholder body.

### `/defect <description>`

Type the bug as you'd describe it to a teammate; the agent infers everything else (platform, build, repro, hypothesis, severity, likely-culprit module + files) and files a ticket. Screenshots in the same message get attached when the tracker supports it.

### `/idea <description>`

The agent infers which repos / modules would need work to ship it, drafts a mini-spec (Why / Proposed shape / Work inferred / Open questions / Size / Trigger to revisit), and files it as a low-priority backlog ticket.

---

## The workflow itself

After bootstrap, your project runs on:

- **Roles separated.** Humans own **WHAT**. The agent owns **HOW**. Disputes → human wins.
- **Triad review.** Every sprint plan / cross-cutting decision gets reviewed in parallel by a CTO subagent (technical feasibility), CPO subagent (product priority — cites PRD), and CDO subagent (design fidelity — cites design system). Their HOW guidance is incorporated; their WHAT pushback becomes open questions for the human.
- **Sprint phases.** Contract Lock → Core Build → UX Layer → Integration → Beta Readiness.
- **Contract lock.** Cross-module contracts freeze at end-of-Day-2. Late changes require explicit reopen + fan-out.
- **ADRs.** Anything touching multiple modules gets a numbered Architecture Decision Record.
- **Tracker as source of truth.** Not chat, not memory, not commits.
- **Pre-close verification gate.** No sprint closes while a deploy is failing or verification is "deferred."

Full spec: [`team-process-spec.md`](./plugins/agentic-engineering-workflow/skills/bootstrap/references/team-process-spec.md).

---

## Operating modes

Pick one at bootstrap (switchable later):

| Mode | When to use | The agent does |
|---|---|---|
| **PLANNER-ONLY** | You have a team of humans + agents | Plans, dispatches reviewers, files tickets, monitors, posts status. Others execute implementation. |
| **SOLE-IC** | Solo founder + one agent | Executes every ticket end-to-end, sequentially. Code → test → push → watch deploy → next. |
| **HYBRID** | Mixed setups | Planner by default; executes when explicitly delegated. |

---

## What this is good for (and not)

**Good fit:**
- Solo founder + AI agent (SOLE-IC mode)
- Small teams (2-5 humans) where the agent is a peer / coordinator (PLANNER-ONLY)
- Multi-platform products (web + mobile + backend) where contracts between layers matter
- Single-platform projects (web-only, backend-only) — skip platforms that don't apply
- Open-source projects with mixed human/AI contributors

**Probably not a fit:**
- Research / exploratory code where ADR overhead slows you down
- Throwaway prototypes
- Projects with a deeply embedded existing workflow you don't want to disrupt

---

## Agent compatibility

| Agent | Plugin install | Manual install | Notes |
|---|---|---|---|
| Claude Code | ✅ one command | — | Native marketplace + skill format |
| Codex (OpenAI CLI) | — | ✅ `.agents/skills/` | SKILL.md format compatible |
| Cursor | — | ⚠️ spec only | No SKILL.md mechanism; paste prompt manually |
| Cline (VS Code) | — | ⚠️ spec only | Same as Cursor |
| Aider | — | ⚠️ spec only | Same as Cursor |
| Any AI chat | — | ⚠️ spec only | Paste the bootstrap prompt block |

If you've adopted this for another agent and found a clean install pattern worth documenting, please file an issue.

---

## License

[MIT](./LICENSE) — fork it, adapt it, share your version.

## Versioning + releases

SemVer. See [`CHANGELOG.md`](./CHANGELOG.md) for release history.

To cut a new release as a maintainer:

```bash
scripts/release.sh 0.2.0
```

The script bumps `version` in both manifests, promotes the `[Unreleased]` section in `CHANGELOG.md`, commits, tags `v0.2.0`, pushes, and the `.github/workflows/release.yml` workflow creates the GitHub Release with extracted changelog notes.

---

## Contributing

Issues + PRs welcome. The spec is opinionated by design, but if you've adopted it for a team and found something missing or wrong, file an issue — that's exactly the feedback we want.

The spec's §16 (Notes for adaptation) lists what's safe to change vs what holds the workflow together; that's the place to start if you're proposing a structural revision.
