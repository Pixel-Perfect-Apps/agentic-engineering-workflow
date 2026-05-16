---
name: defect
description: Triggered when the user types /defect — captures a bug report from chat, infers platform/build/repro/hypothesis, files a ticket to the project's "Bug Triage" view with an inferred severity priority. Use ONLY when the user types /defect.
---

# /defect — file a bug report ticket with inferred context + hypothesis

## When to invoke

The user types `/defect <description>` in chat. The description is everything after the slash command. The user may also drop screenshots into the same message — use them to inform the hypothesis and ticket description.

Do NOT use this skill for anything except `/defect` invocations. For ideas, use `/idea`. For general bug fixes the user wants done now, just do the work without filing a ticket.

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

### 6. Resolve the destination from AGENTS.md

Read `AGENTS.md` → "Tracker destinations" section. The setup writes it; it tells you where /defect should file:

- **Mode `project`**: file into a specific project / team / view. The destination ID is in the section.
- **Mode `triage`**: file into the tracker's built-in Triage inbox (Linear teams support this; Jira's equivalent is the default backlog).
- **Mode `label`**: file as an unassigned issue with the configured bug label applied, no specific project.
- **Mode `unset`** or no "Tracker destinations" section: the setup was skipped or `/defect` wasn't configured. Ask the user where to file (single batched question), then write the choice back to AGENTS.md so this doesn't repeat.

### 7. File via the tracker

The tracker MCP / CLI to use depends on what's wired up in this workspace. Detect from available tools:

- **Linear MCP** (most common): `mcp__linear__save_issue` / `mcp__plugin_linear_linear__save_issue` / `mcp__claude_ai_Linear__save_issue` — try whichever responds.
- **Jira MCP**: `mcp__atlassian__createIssue` or equivalent. Issue type "Bug".
- **GitHub Issues**: `gh issue create --repo <org>/<repo> --title "..." --body "..." --label bug,platform:<X>`.
- **Notion MCP**: `mcp__notion__createPage` with the configured parent.

Universal call shape (adapt to your tracker + the destination mode resolved in step 6):

```
<tracker>.save_issue({
  project / team / repo: <destination_id_or_null>,
  title: "<5-10 word noun-led summary>",
  description: "<full markdown above>",
  priority: <1|2|3|4>,
  assignee: null,
  labels: ["bug", "platform:<primary>", <plus configured bug-label if mode == "label">]
})
```

**CRITICAL: pass `assignee: null` explicitly.** Many tracker MCPs (Linear in particular) auto-assign to the caller if `assignee` is omitted — single most common footgun.

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
