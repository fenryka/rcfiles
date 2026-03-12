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

---

## Rust

### Development

When refactoring Rust code, always check compilation with `cargo check` after
each significant change before proceeding to the next step. Never batch
multiple refactoring steps without verifying compilation.

For Rust trait refactoring: prefer minimal, incremental changes. Do not
introduce marker traits or overcomplicated abstractions. When adding a method
to a trait, propagate the change to ALL implementors and call sites in one
pass, then compile-check.

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

---

## Git Workflow

When working on git branches, always verify which branch is checked out and
whether you're looking at local or remote state before making changes or
reviews. Use `git branch --show-current` and `git log --oneline -5` to confirm.
