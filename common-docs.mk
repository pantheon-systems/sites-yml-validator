# When run in dev container, markdown-toc is run from the local install (to avoid complications due to nested docker/podman volume mounts).
# When run by CircleCI, markdown-toc is run as a container.
#
# DOCKER_PATH can be used to override the path to the docker command (i.e., "podman --remote" or "/usr/local/bin/podman-devcontainer.sh").
DOCKER_PATH ?= "docker"

## Append tasks to the global tasks
test:: test-readme-toc

## doc related tasks
test-readme-toc: ## test if table of contents in README.md needs to be updated
	$(call INFO, "validating documentation TOC")
	@if grep -q '<!-- toc -->' ./README.md; then \
		if [ -x /usr/local/bin/markdown-toc ]; then \
			bash -c "diff -c --ignore-blank-lines --strip-trailing-cr \
						<(cat ./README.md | /usr/local/bin/markdown-toc -; echo) \
						<(cat ./README.md | awk '/<!-- toc -->/{flag=1;next}/<!-- tocstop -->/{flag=0}flag' | sed '1d;\$$d')\
					" > /dev/null 2>&1 \
			|| { echo "ERROR: README.md table of contents needs updating. Run 'make update-readme-toc', commit and push changes to your branch."; exit 1; }; \
		else \
			bash -c "diff -c --ignore-blank-lines --strip-trailing-cr \
						<(cat ./README.md | $(DOCKER_PATH) run --rm -i quay.io/getpantheon/markdown-toc -; echo) \
						<(cat ./README.md | awk '/<!-- toc -->/{flag=1;next}/<!-- tocstop -->/{flag=0}flag' | sed '1d;\$$d')\
					" > /dev/null 2>&1 \
			|| { echo "ERROR: README.md table of contents needs updating. Run 'make update-readme-toc', commit and push changes to your branch."; exit 1; }; \
		fi \
	fi

update-readme-toc: ## update the Table of Contents in ./README.md (replaces <!-- toc --> tag)
	$(call INFO, "updating documentation TOC")
	@if [ -x /usr/local/bin/markdown-toc ]; then \
		/usr/local/bin/markdown-toc -i README.md; \
	else \
		$(DOCKER_PATH) run --platform linux/amd64 --rm -v `pwd`:/src quay.io/getpantheon/markdown-toc -i /src/README.md > /dev/null; \
	fi

.PHONY:: test-readme-toc update-readme-toc
