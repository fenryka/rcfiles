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
are compiler errors or warnings, fix them before reporting done.

Never redefine or move existing types (structs, enums, traits). Always find
the canonical location and import from there. Search the codebase before
assuming a type needs to be created.

### Concurrency

Never use `try_join_all`, `join_all`, or `FuturesUnordered` without a
concurrency bound. Unbounded concurrency is dangerous in production — always
use `buffer_unordered(BUFFER_UNORDERED)` or equivalent bounded dispatch.

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
returns `HashSet<T>`, accept `HashSet<T>` — don't force callers through
unnecessary conversions via overly generic signatures like `impl IntoIterator`.

---

## Python

### Development

When refactoring, do not remove or replace existing patterns (caching,
decorators, etc.) unless the task specifically requires it. Adapt inputs to
preserve existing behaviour.

When a function needs values from Settings, prefer passing the specific values
as parameters rather than the Settings object. pydantic-settings handles env
var mapping automatically — do not use `os.getenv` for values that belong in
Settings.

Do not add comments to explain away code that should be changed or removed.
If something is wrong, fix it; don't annotate it.

Never add `noqa`, `type: ignore`, or equivalent suppression comments to bypass
linter or type-checker rules. If the linter flags your code, fix the code. If
you believe a rule is wrong for the project, raise it for discussion rather
than suppressing it.

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

---

## Changelogs

Describe the final state and user-facing impact only. Do NOT include the
implementation journey, intermediate attempts, or internal refactoring details.

---

## Testing

When fixing test failures, keep retry logic and workarounds in tests only. Do
not push them into client libraries or production code unless explicitly asked.

---

## Schema & Versioning

This project uses versioned schema types (v5/v6/v7+). When working across
versions, always check which versions are affected and handle them separately
unless explicitly told to unify. Generate separate per-version files (e.g.,
`models_v5.py`, `models_v6.py`) rather than a single combined file.

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
