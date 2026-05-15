# Agentic Engineering Workflow

> Turn Claude into a **Director of Engineering** for your team. Sprint cadence, multi-agent review triad, ADR discipline, and one-keystroke bug + idea capture — installed as a single [Claude Code](https://claude.com/claude-code) plugin.

A portable, opinionated workflow for software teams where Claude is part of the team. Drop it into any workspace and you get:

- 🎯 **A bootstrap skill** that scaffolds `AGENTS.md`, a `CLAUDE.md` shim, ADR structure, memory bootstrap, tracker projects + labels — all adapted to your project's actual layout (greenfield, monorepo, or single-repo).
- 🐛 **`/defect`** — fire-and-forget bug capture from chat. Infers platform, build, repro steps, severity, root-cause hypothesis, and likely-culprit files. Files a tracker ticket with all of it.
- 💡 **`/idea`** — parking-lot idea capture. Infers cross-repo scope, drafts a mini-spec, files it for future sprint triage.
- 📚 **A full workflow spec** (sprint phases, triad review pattern, contract-lock discipline, working agreements, common pitfalls) you can read once and reference forever.

Tracker-agnostic (Linear, GitHub Issues, Jira, Notion). Stack-agnostic. Works solo, scales to small teams.

---

## Install

```
/plugin marketplace add Pixel-Perfect-Apps/agentic-engineering-workflow
/plugin install agentic-engineering-workflow@agentic-engineering-workflow
```

Then ask Claude to **"bootstrap the agentic engineering workflow"** in any workspace, or invoke `/agentic-engineering-workflow:bootstrap` directly. Claude will:

1. Walk the workspace's file tree and classify it (greenfield / existing-compatible / existing-divergent).
2. Ask one batched round of clarifying questions.
3. Scaffold AGENTS.md + ADR placeholder + memory bootstrap.
4. Create the tracker's "Bug Triage" + "Ideas / Backlog" projects + label taxonomy.
5. Report what it built, what needs your manual follow-up, and the next prompt to run.

After install, `/defect` and `/idea` are available globally — no project-by-project setup.

---

## What you get

### The bootstrap

A single skill that turns any workspace into a structured project with:

- **`AGENTS.md`** at the root — the working guide Claude reads on every session start.
- **Per-repo / per-module `AGENTS.md`** stubs at the module boundaries.
- **`CLAUDE.md`** compatibility shim pointing to `AGENTS.md`.
- **`docs/decisions/0001-bootstrap.md`** — the first ADR, marking workflow adoption.
- **Memory bootstrap** (`user_identity.md`, `project_current_state.md`, `reference_tracker.md`) at the Claude harness's per-workspace memory path.
- **Tracker scaffolding** — "Bug Triage" + "Ideas / Backlog" projects, canonical label taxonomy (`bug`, `feature`, `improvement`, `kind:spec`, `sprint:s1`, `platform:*`, `area:*`, `blocker`, `alarm:deploy-failure`, `gate:beta-ready`).
- **An initial "M0 / Current Sprint"** document with a placeholder body.

### `/defect <description>`

Fire-and-forget bug capture. Type the bug as you'd describe it to a teammate; Claude infers everything else (platform, build, repro, hypothesis, severity, likely-culprit module + files) and files a ticket. Screenshots in the same message get attached when the tracker supports it.

### `/idea <description>`

Parking-lot idea capture. Claude infers which repos / modules would need work to ship it, drafts a mini-spec (Why / Proposed shape / Work inferred / Open questions / Size / Trigger to revisit), and files it as a low-priority backlog ticket.

### The workflow itself

After bootstrap, your project runs on:

- **Roles separated.** Humans own **WHAT**. Claude owns **HOW**. Disputes → human wins.
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

| Mode | When to use | Claude does |
|---|---|---|
| **PLANNER-ONLY** | You have a team of humans + agents | Plans, dispatches reviewers, files tickets, monitors, posts status. Others execute implementation. |
| **SOLE-IC** | Solo founder + Claude | Executes every ticket end-to-end, sequentially. Code → test → push → watch deploy → next. |
| **HYBRID** | Mixed setups | Planner by default; executes when explicitly delegated. |

---

## Without the plugin

Don't want to install? The spec is a single self-contained markdown file you can drop into any workspace:

```bash
curl -O https://raw.githubusercontent.com/Pixel-Perfect-Apps/agentic-engineering-workflow/main/plugins/agentic-engineering-workflow/skills/bootstrap/references/team-process-spec.md
```

Then paste the [bootstrap prompt](./plugins/agentic-engineering-workflow/skills/bootstrap/references/team-process-spec.md#-prompt-to-paste-) into a fresh Claude session. Claude reads the spec and executes the same five-phase bootstrap — just without the slash-command skills (you can copy those manually from §11 of the spec if you want them).

---

## What this is good for (and not)

**Good fit:**
- Solo founder + Claude (SOLE-IC mode)
- Small teams (2-5 humans) where Claude is a peer agent / coordinator (PLANNER-ONLY)
- Multi-platform products (web + mobile + backend) where contracts between layers matter
- Single-platform projects (web-only, backend-only) — skip platforms that don't apply
- Open-source projects with mixed human/AI contributors

**Probably not a fit:**
- Research / exploratory code where ADR overhead slows you down
- Throwaway prototypes
- Projects with a deeply embedded existing workflow you don't want to disrupt

---

## License

[MIT](./LICENSE) — fork it, adapt it, share your version.

---

## Contributing

Issues + PRs welcome. The spec is opinionated by design, but if you've adopted it for a team and found something missing or wrong, file an issue — that's exactly the feedback we want.

The spec's §16 (Notes for adaptation) lists what's safe to change vs what holds the workflow together; that's the place to start if you're proposing a structural revision.
