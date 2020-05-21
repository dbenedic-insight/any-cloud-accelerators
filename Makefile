SHELL = /bin/sh
IMAGE_PREFIX 					?= any-cloud-accelerators
REPO_IMAGES 					:= $(shell docker images -q '$(PREFIX)*' | uniq)
BASE_IMAGE 						= $(IMAGE_PREFIX)-base
BASE_VERSION 					?= 18.04
BASE_IMAGE_TAG				= $(BASE_IMAGE):$(BASE_VERSION)
VAULT_IMAGE 					= $(IMAGE_PREFIX)-vault
VAULT_VERSION 				?= 1.4.1
VAULT_IMAGE_TAG				= $(VAULT_IMAGE):$(VAULT_VERSION)
VAULT_MODE						?= dev ## Supports 'dev' or 'ui' ('ui' significantly increases build time)
TERRAFORM_IMAGE 			= $(IMAGE_PREFIX)-terraform
TERRAFORM_VERSION 		?= 0.12.25
TERRAFORM_IMAGE_TAG		= $(TERRAFORM_IMAGE):$(TERRAFORM_VERSION)
PACKER_IMAGE 					= $(IMAGE_PREFIX)-packer
PACKER_VERSION 				?= 1.5.6
PACKER_IMAGE_TAG			= $(PACKER_IMAGE):$(PACKER_VERSION)
GO_IMAGE							= $(IMAGE_PREFIX)-go
GO_VERSION						?= 1.14.3
GO_IMAGE_TAG					= $(GO_IMAGE):$(GO_VERSION)
NODE_IMAGE						= $(IMAGE_PREFIX)-node
NODE_VERSION					?= 10.20.1
NODE_IMAGE_TAG				= $(NODE_IMAGE):$(NODE_VERSION)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

base: docker ## Builds base container
				docker build ./common/base --build-arg VERSION=$(BASE_VERSION) -t $(BASE_IMAGE_TAG)

go: base ## Builds a go build container
				docker build ./common/go --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(GO_VERSION) -t $(GO_IMAGE_TAG)

node: base ## Builds a nodejs build container
				docker build ./common/node --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(NODE_VERSION) -t $(NODE_IMAGE_TAG)

vault: base go node ## Builds vault container
				docker build ./common/vault --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg NODEIMAGE=$(NODE_IMAGE_TAG) --build-arg VERSION=$(VAULT_VERSION) --build-arg MODE=$(VAULT_MODE) -t $(VAULT_IMAGE_TAG)

terraform: base go ## Builds terraform container
				docker build ./common/terraform --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg VERSION=$(TERRAFORM_VERSION) -t $(TERRAFORM_IMAGE_TAG)

packer: base go ## Builds packer container
				docker build ./common/packer --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg VERSION=$(PACKER_VERSION) -t $(PACKER_IMAGE_TAG)

docker: ## Prints docker version
				docker version -f "{{.Client.Platform.Name}} v{{.Client.Version}}"

common: terraform vault ## Builds all common images in toolchain

clean: ## Removes all container images associated with this repo
				docker rmi -f $(REPO_IMAGES)
