# workflint-pre-commit

The [pre-commit](https://pre-commit.com) hook of [workflint](https://github.com/stokehold/workflint), a linter for GitHub Actions workflows that is compatible with actionlint. The hook installs workflint from PyPI, so it needs Python, which pre-commit already has, and no Rust toolchain.

## Usage

Add the hook to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/stokehold/workflint-pre-commit
    rev: v0.0.1
    hooks:
      - id: workflint
```

The hook runs on the YAML files in `.github/workflows/`. It runs one workflint process on all of them, so reusable workflows resolve across files. Pass flags to workflint with `args`, for example `args: [-shellcheck=]` to skip the shellcheck check.

`rev` is a tag of this repository. Each tag `v<version>` pins workflint `<version>`. To move to the latest release, run:

```sh
pre-commit autoupdate
```

If you install workflint some other way, use the `workflint-system` hook of the main repository instead. It runs the `workflint` on your `PATH`:

```yaml
repos:
  - repo: https://github.com/stokehold/workflint
    rev: v0.0.1
    hooks:
      - id: workflint-system
```

## How this repository is updated

On each workflint release, `.github/workflows/update.yml` opens a pull request that pins the new version in `pyproject.toml` and changes `rev` above. It merges once the `test` checks pass, and `.github/workflows/tag.yml` then tags the merge commit `v<version>` and creates a GitHub release. A daily run of `update.yml` catches a release whose event was missed.

## License

MIT. See [LICENSE](LICENSE).
