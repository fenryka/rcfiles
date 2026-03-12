Draft a changelog snippet for the current branch.

## Instructions

1. Run `git diff main..HEAD --stat` and `git log main..HEAD --oneline` to understand the scope of changes.
2. Read `CHANGELOG.md` (first ~100 lines) to absorb the project's voice and formatting conventions.
3. Read the actual diff (`git diff main..HEAD`) to understand what changed and why.
4. Write a changelog.d/ snippet following these conventions:

### Style rules

- **Heading**: Use `### Changed` for refactors/features, `### Fixed` for bug fixes, `### Added` for wholly new functionality.
- **Opening bullet**: State the high-level goal or problem being solved — the *why*, not a list of files touched.
- **Nested bullets**: Break down the solution, explaining rationale for non-obvious decisions. Use nested bullets to show relationships between changes.
- **Code references**: Use backticks for code identifiers (`trait names`, `function names`, `module paths`).
- **File pointers**: For the most important changes, tell the reader where to look (e.g. "See `generative-domain/src/v2/mod.rs` for the trait definition").
- **British English spelling**: Use "behaviour", "serialise", "standardise", etc.
- **No boilerplate churn**: Don't list mechanical renames, import changes, or derive additions unless they reflect an intentional design decision.
- **Line width**: Wrap at ~95 characters, with continuation lines indented by two spaces.

### Output

- Print the snippet content to the screen so I can review it, always print it as raw text or wrap in a code block to prevent any styling being lost.
- Do NOT write it to a file unless I ask you to.

$ARGUMENTS
