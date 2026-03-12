Fetch the open GitLab merge request targeting the current Git branch and summarise
the review feedback.

## Prerequisites

This command requires `glab` (GitLab CLI) to be installed and authenticated.
All `glab` commands need sandbox disabled (`dangerouslyDisableSandbox: true`)
because `glab` writes to `~/.config/glab-cli/` at runtime.

## Steps

1. Get the current branch name and the URL-encoded project path in parallel:
   - `git branch --show-current`
   - Derive the project path from `git remote get-url origin` by extracting
     the `org/group/repo` portion (strip the host prefix and `.git` suffix),
     then URL-encode slashes as `%2F`.
2. Run `glab mr list --source-branch="<branch>"` (sandbox disabled) to find
   the open MR. If there is no open MR, tell the user and stop.
3. Run these in parallel (both sandbox disabled):
   - `glab mr view <iid>` for title, description, and metadata.
   - `glab api "projects/<encoded-path>/merge_requests/<iid>/notes?sort=asc&per_page=100"`
     for review comments.
4. Present a summary containing:
   - MR title, URL, author, reviewers, and approval status.
   - Each **non-system** review thread grouped by author, noting:
     - Whether it is resolved or unresolved.
     - The file and line it applies to (for diff notes).
     - The substance of the comment (and any code suggestions).
   - A count of unresolved vs total threads.