# Agents.md

This file applies to the whole repository.

## Project Context

This repository is a reusable Terraform module for AWS KMS keys and aliases. Keep changes focused on module behavior, compatibility, examples, and generated documentation.

## Working Guidelines

- Treat the module as Terraform Registry-facing code. Prefer backward-compatible inputs and outputs unless a breaking change is intentional and documented.
- Keep provider constraints as lower bounds for reusable-module compatibility. Root configurations that consume this module should pin their own upper bounds and lock files.
- Do not commit Terraform state, local credentials, plans, or generated `.terraform/` directories.
- Update `README.md` whenever inputs, outputs, requirements, or resources change.
- Keep examples under `examples/` simple, runnable, and representative of recommended usage.

## Validation

Run these checks before handing work back when the required tools are available:

- `terraform fmt -check -recursive`
- `terraform init -backend=false -upgrade`
- `terraform validate`
- `terraform-docs markdown table .`

If `pre-commit` and `tflint` are installed, also run:

- `pre-commit run --all-files`
