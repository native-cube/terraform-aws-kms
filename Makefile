SHELL := /bin/bash

EXAMPLES := $(wildcard examples/*)

.PHONY: help fmt fmt-check docs docs-check init validate test schema-check examples-init examples-validate check hooks

help:
	@echo "Available targets:"
	@echo "  make fmt                Format all Terraform files"
	@echo "  make fmt-check          Check Terraform formatting"
	@echo "  make docs               Generate README Terraform docs"
	@echo "  make docs-check         Check README Terraform docs are current"
	@echo "  make init               Initialize the root module"
	@echo "  make validate           Validate the root module"
	@echo "  make test               Run native Terraform tests"
	@echo "  make schema-check       Verify all supported provider arguments are wired"
	@echo "  make examples-init      Initialize all examples"
	@echo "  make examples-validate  Validate all examples"
	@echo "  make check              Run local CI-style checks"
	@echo "  make hooks              Enable repo-local Git hooks"

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -check -recursive

docs:
	scripts/terraform-docs.sh

docs-check:
	scripts/terraform-docs.sh --check

init:
	terraform init -backend=false

validate:
	terraform validate

test:
	terraform test -no-color

schema-check:
	scripts/check-provider-arguments.sh

examples-init:
	@for example in $(EXAMPLES); do \
		if [ -d "$$example" ]; then \
			echo "Initializing $$example"; \
			terraform -chdir="$$example" init -backend=false; \
		fi; \
	done

examples-validate:
	@for example in $(EXAMPLES); do \
		if [ -d "$$example" ]; then \
			echo "Validating $$example"; \
			terraform -chdir="$$example" validate; \
		fi; \
	done

check: fmt-check docs-check init validate test schema-check examples-init examples-validate
	git diff --check

hooks:
	git config core.hooksPath .githooks
