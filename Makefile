.PHONY: lint lint-yaml lint-go test setup

## Setup — install pre-commit hooks
setup:
	pip install pre-commit gitlint yamllint
	pre-commit install --hook-type commit-msg
	@echo "Setup complete. Run 'make lint' to verify."

## Lint — run all linters (must pass before every PR)
lint: lint-yaml lint-go

## Lint YAML files
lint-yaml:
	yamllint -c .yamllint $$(find . -type f -regex ".*y[a]ml" -not -path './vendor/*' -print)

## Lint a single YAML file: make lint-file FILE=task/git-clone/0.9/git-clone.yaml
lint-file:
	yamllint -c .yamllint $(FILE)

## Check Go formatting
lint-go:
	@diff=$$(gofmt -d $$(find * -name '*.go' ! -path 'vendor/*' ! -path 'third_party/*')); \
	if [ -n "$$diff" ]; then echo "$$diff"; exit 1; fi

## Test a single task: make test TASK=git-clone VERSION=0.9
test:
	./test/run-test.sh task $(TASK) $(VERSION)

## Run full e2e test suite (requires Kind cluster)
test-e2e:
	./hack/setup-kind.sh \
		--registry-url registry.local:5000 \
		--cluster-suffix cluster.local \
		--nodes 1 \
		--pipeline-version v1.9.0 \
		--e2e-script ./test/e2e-tests.sh \
		--e2e-env ./test/e2e-tests-kind-gha.env
