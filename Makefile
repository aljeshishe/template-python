SOURCE_FILES = Makefile cookiecutter.json {{cookiecutter.project_name}}/* {{cookiecutter.project_name}}/*/*
GENERATED_PROJECT := template_python_test_repo

ENV := .venv

.PHONY: all
all: install

.PHONY: doctor
doctor:  ## Confirm system dependencies are available
	{{cookiecutter.project_name}}/bin/verchew

# MAIN ########################################################################

.PHONY: ci
ci:
	rm -rf $(GENERATED_PROJECT)
	poetry run cookiecutter . --no-input --overwrite-if-exists github_repo=$(GENERATED_PROJECT)
	cd $(GENERATED_PROJECT) && make repo-init
	# gh repo delete $(GENERATED_PROJECT) --confirm

.PHONY: dev
dev: install clean
	poetry run sniffer

# DEPENDENCIES ################################################################

.PHONY: install
install: $(ENV)
$(ENV): poetry.lock
	@ poetry config virtualenvs.in-project true
ifdef CI
	poetry install --no-dev
else
	poetry install
endif
	@ touch $@

ifndef CI
poetry.lock: pyproject.toml
	poetry lock --no-update
	@ touch $@
endif

# BUILD #######################################################################

.PHONY: build
build: install $(GENERATED_PROJECT)
$(GENERATED_PROJECT): $(SOURCE_FILES)
	cat cookiecutter.json
	poetry run cookiecutter . --no-input --overwrite-if-exists
ifndef CI
endif
	cd $(GENERATED_PROJECT) && poetry lock --no-update
	@ touch $(GENERATED_PROJECT)

# CLEANUP #####################################################################

.PHONY: clean
clean:
	rm -rf $(GENERATED_PROJECT)

.PHONY: clean-all
clean-all: clean
	rm -rf $(ENV)
