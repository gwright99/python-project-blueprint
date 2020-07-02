# REFERENCE: https://github.com/MartinHeinz/python-project-blueprint/blob/master/Makefile
# The binary to build (just the base name)
MODULE := blueprint
REGISTRY ?= docker.pkg.github.com/gwright99/python-project-blueprint
IMAGE := $(REGISTRY)/$(MODULE)

# This version strategy uses git tags to set the version string
TAG := $(shell git describe --tags --always --dirty)

BLUE='\033[0;34m'
NC='\033[0m' # No color


# GW NOTES:
# 1) 	Must use tabs, not spaces.
# 2)  	> sed -e command seems to be a substitute. We look for the {NAME} and {VERSION} at the bottom
# 		of the dev.Dockerfile and replace them with the MODULE and TAG variables specified at top of Makefile.
# 3) Note that TEST & LINT commands are invoking packages directly (instead of using python -m, like "RUN")
# 	I think Heinz expects you to create a virtualenv first, install some base packages via pip, and then copy in the
#	project skeleton. Tested this out in WSL2 implementation and it works:
#	- Create venv folder, create source folder in VENVFOLDER, copy -R * blueprint files to VENVFOLDER/source,
#	  activate VENVFOLDER, pip install pytest pytest-cov bandit pylint flake8
#	- Once this is done you can invoke "make <COMMAND>" here without needing to preface with "python -m" (except
#	  for the 'run' command which still needs it)

run:
	@python3 -m $(MODULE)

# Needed to use 'python3 -m pytest' when i didnt use venv first
test:
	@pytest
	@echo "\nDirty git tag: $(TAG)\n"

lint:
	@echo "\n${BLUE}Running Pylint against source and test files...${NC}\n"
	@pylint --rcfile=setup.cfg **/*.py
	@echo "\n${BLUE}Running Flake8 against source and test files...${NC}\n"
	@flake8
	@echo "\n${BLUE}Running Bandit against source files...${NC}\n"
	@bandit -r --ini setup.cfg

build-dev:
	@echo "\n${BLUE}Building Development image with labels:\n"
	@echo "name: $(MODULE)"
	@echo "version: $(TAG)${NC}\n"
	@sed							\
		-e 's|{NAME}|$(MODULE)|g'	\
		-e 's|{VERSION}|$(TAG)|g'	\
		dev.Dockerfile | docker build -t $(IMAGE):$(TAG) -f- .

# Example: make build-prod VERSION=1.0.0
build-prod:
	@echo "\n${BLUE}Building Production image with labels:\n"
	@echo "name: $(MODULE)"
	@echo "version: $(VERSION)${NC}\n"
	@sed							\
		-e 's|{NAME}|$(MODULE)|g'	\
		-e 's|{VERSION}|$(VERSION)|g'	\
		prod.Dockerfile | docker build -t $(IMAGE):$(VERSION) -f- .

# NOTE how "shell" and "push" entries call the build-x methods above!!
# Create way to debug Docker container
# Example: > make shell CMD="-c 'date > datefile'"
shell: build-dev
	@echo "\n${BLUE}Launching a shell in the containerized build environment...${NC}\n"
	@docker run -ti --rm --entrypoint /bin/bash \
	-u $$(id -u):$$(id -g) $(IMAGE):$(TAG) $(CMD)

# Example: > make push VERSION=0.0.2
push: build-prod
	@echo "\n${BLUE}Pushing image to GitHub Docker Registry...${NC}\n"
	@docker push $(IMAGE):$(VERSION)
	# This requires us to be logged into the Docker registry. Must use "docker login" first.

# Example Makefile has a bunch of Kubernetes stuff here

version:
	@echo $(TAG)

.PHONY: clean image-clean build-prod test

clean:
	rm -rf .pytest_cache .coverage .pytest_cache coverage.xml

docker-clean:
	@docker system prune -f --filter "label=name=$(MODULE)"
