# Claude Instructions

Address the user as "Lady Fenric".

---

## General Workflow

Before making any changes, read the existing implementations of the relevant
feature across the codebase. Summarize the patterns you see, then propose your
approach for my approval before writing any code.

When I point you to an existing pattern or reference implementation (e.g.,
'base it on evaluation-service'), explore that code FIRST before writing
anything. Do not propose your own approach until you've read the reference.

When I point you to specific types, files, or code locations, start there
directly. Do not explore git diffs or the broader codebase first.

When exploring the codebase before a task, limit scope to what is directly
necessary. Do not do broad codebase discovery unless the task scope is
genuinely unclear.

Never modify shared libraries, packages, or services outside the current
project/service boundary. Only modify code you've been explicitly asked to
work in.

When the next step is obvious from context, proceed rather than asking. Do not
over-explore fixtures or the broader codebase before acting on a clear path.

Before changing any code to fix a bug or regression, confirm the root cause
with evidence (grep/read output showing the specific line). Do not patch
unrelated issues or speculate about causes before the real culprit is
identified.

When doing renames or import fixes, search the entire repo including top-level
directories (e.g. `migrations/`), not just `src/` and `tests/`. Run a final
repo-wide verification pass to confirm nothing dangles.

---

## Shell Environment

Claude Code inherits the shell it's invoked in. Always invoke tools by their
name on PATH (`cargo`, `python`, `ruff`, `mypy`, etc.) — never reference
`/nix/store/...` paths directly. The nix devshell has already put everything
on PATH; there is nothing to gain by bypassing it.

---

## Architecture & Design

When the codebase has an existing primitive that solves a coordination
problem (a CAS+watch KV store, a message bus, a state accessor), use it as
the rendezvous. Don't invent parallel in-process state
(`dict[Id, Future]`, local registries) alongside it. The primitives exist
precisely to handle distribution and restart-safety — bypassing them
gives those up for marginal "simplicity".

PoC scaffolding gated behind dev-mode flags should be shaped like the
architecture it stands in for, with externals stubbed. A stubbed shim
that drops in unchanged when the real thing arrives is good. A synthetic
round-trip that doesn't resemble anything we'd actually run isn't.

Don't write user-facing error responses for invariants enforced upstream.
If a router is only mounted when a setting is enabled, the handler can
assume that setting is enabled. Belt-and-braces assertions documenting
non-obvious invariants are fine; HTTP 5xx branches for impossible states
aren't.

A stated directional goal is a hard constraint, whether it comes from the
prompt or from an existing code comment (e.g. "eventually decouple X from Y",
"this should move to the dynamo crate"). Check every change against that
direction before acting. If a change moves against it, stop and say so rather
than proceeding. A local precedent (how a sibling value happens to be wired
today) does not override a stated goal: matching the precedent is the wrong
move when the whole point is to change it.

Before starting a multi-file refactor, state the target domain layer and the
abstraction you'll use, then wait for confirmation before implementing. Do not
begin until the layer placement is agreed.

---

## Rust

### Development

When refactoring Rust code, always check compilation with `cargo check` after
each significant change before proceeding to the next step. Never batch
multiple refactoring steps without verifying compilation.

When refactoring, prefer the simplest approach first (extracting shared code,
trait impls, type aliases) over macros or complex abstractions. Only use macros
if explicitly asked.

For Rust trait refactoring: prefer minimal, incremental changes. Do not
introduce marker traits or overcomplicated abstractions. When adding a method
to a trait, propagate the change to ALL implementors and call sites in one
pass, then compile-check.

Before starting any multi-file refactor, use grep/glob to identify every file
that will be affected. List all affected files with the specific change needed
in each. Do not begin editing until the scope is confirmed.

Do not present work as complete until `cargo check` passes cleanly. If there
are compiler errors or warnings, fix them before reporting done. When declaring
completion, paste the `cargo check` output as evidence. If you cannot run the
check, say so explicitly and list what verification is pending.

Never redefine or move existing types (structs, enums, traits). Always find
the canonical location and import from there. Search the codebase before
assuming a type needs to be created.

Do not introduce a new type (struct, enum, wrapper) to hold config or state
without first naming the existing types you considered and why each won't
serve. The default assumption is that an existing type is the right home. If
the justification doesn't fit in one line, it isn't justified yet: ask before
creating.

### Concurrency

Never use `try_join!`, `try_join_all`, `join_all`, or `FuturesUnordered`.
Always use `buffer_unordered(BUFFER_UNORDERED)` for concurrent async
operations. Unbounded concurrency is dangerous in production.

When refactoring async code, preserve the concurrency characteristics of the
original. If the old code ran things in parallel, the new code must too unless
explicitly simplifying.

### Style

When a language limitation forces a non-obvious workaround (e.g. `mem::take`
to get owned values past async lifetime constraints), always add a comment
explaining *why* the workaround exists.

Don't introduce new types (structs, enums) solely to work around borrow
checker limitations. Prefer extracting a function and restructuring ownership
(e.g. passing owned values through a stream) over adding intermediate data
structures.

### API Design

Match the types your callers and callees actually use. If lower-level code
returns `HashSet<T>`, accept `HashSet<T>`, don't force callers through
unnecessary conversions via overly generic signatures like `impl IntoIterator`.

---

## Python

### Development

When refactoring, do not remove or replace existing patterns (caching,
decorators, etc.) unless the task specifically requires it. Adapt inputs to
preserve existing behaviour.

When a function needs values from Settings, prefer passing the specific values
as parameters rather than the Settings object. pydantic-settings handles env
var mapping automatically, do not use `os.getenv` for values that belong in
Settings.

Do not add comments to explain away code that should be changed or removed.
If something is wrong, fix it; don't annotate it.

Never add `noqa`, `type: ignore`, or equivalent suppression comments to bypass
linter or type-checker rules. If the linter flags your code, fix the code. If
you believe a rule is wrong for the project, raise it for discussion rather
than suppressing it.

When implementing service clients, never return raw HTTP responses. Always
return typed values with appropriate error handling, following the pattern of
existing sibling services.

Organise new types and models by concept, co-located in their domain files.
Do not create a catch-all `models.py` to dump unrelated types into.

Do not present Python work as complete until `ruff check`, `mypy`, and `pytest`
all pass. If the project uses `nix flake check`, run that instead. Say so
explicitly if you cannot run checks, and list what verification is pending.

### Commands

Run `pytest` directly, not `python -m pytest`. Similarly prefer `ruff`, `mypy`, etc. over `python -m ruff`, `python -m mypy`.

### Testing

Write tests as discrete top-level functions (`def test_foo`), not wrapped in a
class. Do not use `class TestFoo` grouping.

Express helper data as pytest fixtures, not module-level or class-level static
variables. If a test needs data, inject it via a fixture.

---

## Continuation Sessions

When resuming work from a prior session where the plan is already decided, skip
re-exploration and re-planning. Start implementing immediately. Only re-explore
if compilation or tests reveal something unexpected.

For multi-session features, treat `plan.md` (or a ticket-named equivalent) as
the source of truth. At the start of each session on a multi-stage feature,
read the plan file first and confirm which stage is current before proposing or
taking any action. When starting a new multi-stage feature, create the plan
file before writing any code.

---

## Drafting Written Artifacts

When drafting commit messages, MR/PR replies, or any written artifact on my
behalf, apply the Writing Style guide below regardless of whether I've
explicitly asked you to "write in my style". Key constraints:
- No em-dashes in any drafted text
- Commit messages: concise, no verbose narratives, use terse active voice
- MR replies: plain conversational tone — not corporate or flowery

---

## Changelogs

Describe the final state and user-facing impact only. Do NOT include the
implementation journey, intermediate attempts, or internal refactoring details.

Keep entries proportional to the scope of the change — a one-line fix does
not warrant five bullet points. Use asterisk bullets (`*`), not dashes.

---

## Testing

When fixing test failures, keep retry logic and workarounds in tests only. Do
not push them into client libraries or production code unless explicitly asked.

A test that exercises a high-level concern using a low-level backend as
a test double belongs at the high-level layer of the test tree, not
under the backend's directory. Mirror the existing structure (e.g.
`tests/bus/exploration_state/` testing the accessor against the in-memory
backend) — not `tests/bus/backends/in_memory/test_accessor.py`.

### Readability: show the story

I value tests I can read as a story, with the meaningful values visible, as
much as I value correctness. When writing tests:

- Put the values that matter in the test body where they can be read. Don't
  bury them in builder helpers or comparison helpers (e.g. a `by_sort_key`
  that hides what was actually stored and returned). Minimise indirection.
- Assert against literal expected values so correctness is verifiable from the
  assertion alone — e.g. with composite keys, assert the fetch returns exactly
  `["a#0", "a#1"]`, so a reader sees what went in and what came back.
- Include at least one fully-inline example showing the complete shape and real
  values (no helper). Use a thin builder only for incidental detail in tests
  focused on something else, and have it foreground the keys/fields under test.
- Test a low-level mechanism directly with plain values (e.g. a composite range
  key driven with bare `{"HK": ..., "RK": "a#0"}` items), separately from the
  high-level mapping that sits on top. Don't only prove the mechanism
  transitively through noisy domain types.
- Prefer unpacking like `[only] = result` to assert "exactly one" and bind it
  readably.

This is in addition to correctness, never instead of it.

---

## Schema & Versioning

Projects uses versioned schema types (v5/v6/v7+). When working across
versions, always check which versions are affected and handle them separately
unless explicitly told to unify. Generate separate per-version files (e.g.,
`models_v5.py`, `models_v6.py`) rather than a single combined file.

---

## GitLab

Always use the `gitlab-api` skill for any GitLab API interaction — fetching MR details, posting comments, replying to discussion threads, checking pipelines, etc. Never attempt GitLab API calls manually via `glab` or `curl` when this skill is available.

When handling MR review feedback: summarize all unresolved threads first before
making any changes. Present the full summary for confirmation, then fix
systematically.

---

## Git Workflow

When working on git branches, always verify which branch is checked out and
whether you're looking at local or remote state before making changes or
reviews. Use `git branch --show-current` and `git log --oneline -5` to confirm.

When reviewing a branch or MR, always run `git fetch origin <branch>` first
and compare against the remote state, not local. Confirm the correct branch
before starting any review.

Before posting MR/PR comments or committing, always show drafts to me for
review first. Never post or commit without explicit approval.

Never assume a rebase is ongoing or complete — always confirm actual state
with `git status` before reporting or continuing.

---

## Writing Style (use when asked to "write in my style")

### Voice & Tone
- Conversational and direct. Not corporate, not performative.
- Warm but intellectually sharp — thinks out loud, invites discussion.
- Self-deprecating humour is common ("I'm getting possibly carried away",
  "I agree, I was being lazy").
- Comfortable expressing uncertainty openly ("I could be wrong but",
  "I'm not close enough to the requirements to really have a strong opinion").
- Uses hedging that reads as genuine thought, not weakness ("I think",
  "I don't love", "probably", "might be worth").
- Dry wit lands through understatement, not jokes ("here, there be dragons",
  "all hail our overlords").

### Sentence Structure
- Short, often fragmentary sentences. Drops subjects freely ("will fix",
  "done!", "killed", "fair point").
- Frequently starts with lowercase. Minimal capitalisation.
- Ellipsis-style trailing thoughts with "but" or "..." ("I don't love it
  but... its probably fine", "can always change in the future").
- Parenthetical asides are common and conversational ("(which turns out is
  someones actual user name)", "(I found this out the hard way by doing that
  change, then reverting)").

### Argumentation Style
- Leads with position, then reasoning. Not the other way around.
- Uses "I don't love X" as the go-to soft objection — stronger than "maybe"
  but leaves room.
- Frames disagreements as invitations: "Happy to discuss if you feel strongly
  though", "not a hill I'd die on".
- When making a technical case, structures it clearly with concrete specifics
  but keeps the register informal.
- Acknowledges good points readily and genuinely ("Good shout", "good catch",
  "That's a fair concern, and worth thinking through").

### Vocabulary & Phrasing
- British-inflected: "alas", "betwixt", "vexing", "pedantic point",
  "juice worth the squeeze".
- Emoji-light: mostly :thumbsup: and :smile: — never decorative.
- "I don't love" (objection), "fair point" / "fair!" (concession),
  "good catch" / "good shout" (acknowledgement), "will fix" / "done!"
  (action taken), "out of scope for this but" (deferral).
- Uses rhetorical questions to surface concerns without being prescriptive.

### Common Patterns
- Acknowledges then redirects: "I'm fine with the change as is, but it feels
  like we're bodging a bodge."
- Defers gracefully: "can always retro add", "will raise a ticket for it",
  "out of scope for now".
- Approvals are brief: "LGTM!", "LGTM", "AFAICT looks good!", ":thumbsup:".
- Typos are natural and frequent — do NOT artificially insert typos, but do
  not over-polish either. Keep the feel of someone typing quickly and thinking
  as they go.
