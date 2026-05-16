---
name: idea
description: Triggered when the user types /idea — takes an idea description, infers the cross-repo work needed to ship it, drafts a mini-spec, and files the ticket to the "Ideas / Backlog" view as a parked idea. Use ONLY when the user types /idea.
---

# /idea — file a parking-lot ticket with inferred cross-repo spec

## When to invoke

The user types `/idea <description>` in chat. The description is everything after the slash command — could be a one-liner, a paragraph, or a rambling thought with multiple sub-ideas. Treat the entire post-command text as the raw idea payload.

Do NOT use this skill for `/defect` reports or feature requests the user wants implemented now. Ideas are parking-lot tickets — they file but don't trigger any work.

## What to do

1. **Understand the idea.** Read carefully. If ambiguous, make one reasonable interpretation and note it in the spec as "Assumed: …" rather than asking — `/idea` is low-friction capture.

2. **Infer the cross-repo work.** For every idea, walk the checklist of repos / modules in this project and note what (if anything) each needs. Use `AGENTS.md` (root + per-repo) to know what modules exist:
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

4. **Resolve destination from AGENTS.md, then file.**

   Read `AGENTS.md` → "Tracker destinations" section. The setup writes it; it tells you where /idea should file:
   - Mode `project`: file into the configured ideas project / view. ID is in the section.
   - Mode `label`: file as an unassigned issue with the configured ideas label applied, no specific project.
   - Mode `unset` or missing section: ask the user where ideas should go (single batched question), then write the choice back to AGENTS.md.

   Then call the tracker (Linear, Jira, GitHub Issues, Notion — whichever MCP / CLI is wired up):

   ```
   <tracker>.save_issue({
     project / team / repo: <destination_id_or_null>,
     title: "<6-12 word descriptive, noun-led; no 'Idea:' prefix>",
     description: "<full mini-spec from step 3>",
     priority: 4,
     assignee: null,
     labels: ["feature", "platform:<primary>", <plus configured ideas-label if mode == "label">]
   })
   ```

   Platform label: use `platform:all` if the idea spans 3+ platforms; otherwise the primary user touchpoint.

   **CRITICAL: pass `assignee: null` explicitly.** Many tracker MCPs auto-assign to the caller if `assignee` is omitted.

5. **Report back** (2-3 lines):
   - Ticket URL
   - One-sentence scope summary
   - Any assumption the user may want to correct

## Rules

- Don't enter plan mode, don't ask clarifying questions. Fire-and-forget.
- Don't fabricate detail you don't know. Write "unclear — flag for design review" instead.
- Don't skip cross-repo inference even on small ideas — that's the point of the skill.
- Don't assign to a human. `assignee: null` is mandatory.
- Don't mark Urgent or High. Priority is always Low (4).
- Don't dispatch subagents. The ticket parks until future sprint triage.

## After filing

Done. The ticket sits in "Ideas / Backlog" until DoE triages at a future sprint kickoff.
