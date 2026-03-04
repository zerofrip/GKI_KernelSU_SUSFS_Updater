# GKI KernelSU SUSFS Updater — Local Action Detection Test

Minimal repository structure to verify that a local composite action at `.github/actions/susfs/action.yml` is correctly detected and executed by GitHub Actions.

## Repository Structure

```
.
├── .github/
│   ├── workflows/
│   │   └── test.yml          # Workflow that tests the local action
│   └── actions/
│       └── susfs/
│           └── action.yml    # Composite action under test
└── README.md
```

## What This Tests

| Step | Purpose |
|------|---------|
| `actions/checkout@v4` | Ensures the full repository (including `.github/`) is present in the runner workspace |
| `pwd` | Confirms the working directory is the repository root |
| `ls -R` | Shows the full file tree so you can visually verify structure |
| `ls -la .github/actions/susfs/` | Confirms the action directory and `action.yml` are checked out |
| `test -f .github/actions/susfs/action.yml` | Fails the workflow explicitly if the file is missing |
| `uses: ./.github/actions/susfs` | Executes the local composite action |

## Why This Confirms Correct Local Action Resolution

1. **`actions/checkout` is required.** GitHub runners start with an empty workspace. Without checkout, no repository files exist, and `uses: ./.github/actions/susfs` will fail with `Can't find 'action.yml'`.

2. **The path must be relative to the repository root.** `uses: ./.github/actions/susfs` tells the runner to look for `action.yml` inside `.github/actions/susfs/` relative to `$GITHUB_WORKSPACE`.

3. **`action.yml` must use `runs.using: "composite"`.** This is the required declaration for a local composite action. Without it, the runner cannot interpret the action.

4. **The explicit existence check (`test -f`)** ensures the workflow fails with a clear error message if the file is missing, instead of a cryptic GitHub Actions resolution error.
