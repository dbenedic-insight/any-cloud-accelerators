SHELL = /bin/sh
IMAGE_PREFIX 			?= any-cloud-accelerators
REPO_IMAGES 			:= $(shell docker images -q '$(PREFIX)*' | uniq)
BASE_IMAGE 				= $(IMAGE_PREFIX)-base
BASE_VERSION 			?= latest
VAULT_IMAGE 			= $(IMAGE_PREFIX)-vault
VAULT_VERSION 		?= latest
TERRAFORM_VERSION ?= latest

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

base: docker ## Builds base container
				docker build ./common/base --build-arg version=$(BASE_VERSION) -t $(BASE_IMAGE)

vault: base ## Builds vault container
				docker build ./common/vault --build-arg baseimage=$(BASE_IMAGE) --build-arg version=$(VAULT_VERSION) -t $(VAULT_IMAGE)

docker: ## Prints docker version
				docker version -f "{{.Client.Platform.Name}} v{{.Client.Version}}"

clean: ## Removes all container images associated with this repo
				docker rmi -f $(REPO_IMAGES)
