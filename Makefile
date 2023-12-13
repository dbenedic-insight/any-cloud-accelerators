SHELL                   = /bin/sh
IMAGE_PREFIX           ?= aca
PLATFORM               ?= linux/amd64
PLATFORM_SHORT         ?= $(word 2,$(subst /, ,$(PLATFORM))) ## splits on '/'
BUILD_COMMAND           = docker build --rm --platform $(PLATFORM)
REPO_IMAGES            := $(shell docker images -q '$(PREFIX)*' | uniq)
DANGLING_IMAGES        := $(shell docker images --filter "dangling = true" -q)
BASE_IMAGE              = $(IMAGE_PREFIX)-base
BASE_VERSION           ?= 22.04 ## ubuntu
BASE_IMAGE_TAG          = $(BASE_IMAGE):$(BASE_VERSION)
VAULT_IMAGE             = $(IMAGE_PREFIX)-vault
VAULT_VERSION          ?= 1.15.0
VAULT_IMAGE_TAG         = $(VAULT_IMAGE):$(VAULT_VERSION)
VAULT_DEV_IMAGE_TAG     = $(VAULT_IMAGE)-dev:$(VAULT_VERSION)
VAULT_MODE             ?= dev ## Supports 'dev' or 'ui' ('ui' significantly increases build time)
TERRAFORM_IMAGE         = $(IMAGE_PREFIX)-terraform
TERRAFORM_VERSION      ?= 1.6.0
TERRAFORM_IMAGE_TAG     = $(TERRAFORM_IMAGE):$(TERRAFORM_VERSION)
PACKER_IMAGE            = $(IMAGE_PREFIX)-packer
PACKER_VERSION         ?= latest
PACKER_IMAGE_TAG        = $(PACKER_IMAGE):$(PACKER_VERSION)
CONSUL_IMAGE            = $(IMAGE_PREFIX)-consul
CONSUL_VERSION         ?= 1.16.2
CONSUL_IMAGE_TAG        = $(CONSUL_IMAGE):$(CONSUL_VERSION)
GO_IMAGE                = $(IMAGE_PREFIX)-go
GO_VERSION             ?= 1.21.1
GO_IMAGE_TAG            = $(GO_IMAGE):$(GO_VERSION)
GO_DEV_IMAGE_TAG        = $(GO_IMAGE)-dev:$(GO_VERSION)
RUBY_IMAGE              = $(IMAGE_PREFIX)-ruby
RUBY_VERSION           ?= 3.2.2
RUBY_IMAGE_TAG          = $(RUBY_IMAGE):$(RUBY_VERSION)
TERRAFORMER_IMAGE       = $(IMAGE_PREFIX)-terraformer
TERRAFORMER_VERSION    ?= latest
TERRAFORMER_IMAGE_TAG   = $(TERRAFORMER_IMAGE):$(TERRAFORMER_VERSION)
NODE_IMAGE              = $(IMAGE_PREFIX)-node
NODE_VERSION           ?= 20.7.0
NODE_IMAGE_TAG          = $(NODE_IMAGE):$(NODE_VERSION)
PYTHON_IMAGE            = $(IMAGE_PREFIX)-python
PYTHON_VERSION         ?= 3.11.5
PYTHON_IMAGE_TAG        = $(PYTHON_IMAGE):$(PYTHON_VERSION)
OPENSSL_IMAGE           = $(IMAGE_PREFIX)-openssl
OPENSSL_VERSION        ?= 3.1.3
OPENSSL_IMAGE_TAG       = $(OPENSSL_IMAGE):$(OPENSSL_VERSION)
IBM_CLI_IMAGE           = $(IMAGE_PREFIX)-ibm-cli
IBM_CLI_VERSION        ?= 2.15.0
IBM_CLI_IMAGE_TAG       = $(IBM_CLI_IMAGE):$(IBM_CLI_VERSION)
IBM_TF_IMAGE            = $(IMAGE_PREFIX)-ibm-tf
IBM_TF_VERSION         ?= latest
IBM_TF_IMAGE_TAG        = $(IBM_TF_IMAGE):$(IBM_TF_VERSION)
AZURE_CLI_IMAGE         = $(IMAGE_PREFIX)-az-cli
AZURE_CLI_VERSION      ?= 2.53.0
AZURE_CLI_IMAGE_TAG     = $(AZURE_CLI_IMAGE):$(AZURE_CLI_VERSION)
AZURE_TF_IMAGE          = $(IMAGE_PREFIX)-az-tf
AZURE_TF_IMAGE_TAG      = $(AZURE_TF_IMAGE):$(TERRAFORM_VERSION)
AZURE_TF_DEV_IMAGE      = $(AZURE_TF_IMAGE)-dev
AZURE_TF_DEV_IMAGE_TAG  = $(AZURE_TF_DEV_IMAGE):$(TERRAFORM_VERSION)
GCP_BASE_IMAGE          = ${IMAGE_PREFIX}-gcp-base
GCP_BASE_VERSION        = latest
GCP_BASE_IMAGE_TAG      = ${GCP_BASE_IMAGE}:${GCP_BASE_VERSION}
GCP_CLI_IMAGE           = $(IMAGE_PREFIX)-gcp-sdk
GCP_CLI_VERSION        ?= latest
GCP_CLI_IMAGE_TAG       = $(GCP_CLI_IMAGE):$(GCP_CLI_VERSION)
GCP_TF_IMAGE            = $(IMAGE_PREFIX)-gcp-tf
GCP_TF_IMAGE_TAG        = $(GCP_TF_IMAGE):$(TERRAFORM_VERSION)
GCP_TF_DEV_IMAGE        = $(GCP_TF_IMAGE)-dev
GCP_TF_DEV_IMAGE_TAG    = $(GCP_TF_DEV_IMAGE):$(TERRAFORM_VERSION)
AWS_CLI_IMAGE           = $(IMAGE_PREFIX)-aws-cli
AWS_CLI_VERSION        ?= latest
AWS_CLI_IMAGE_TAG       = $(AWS_CLI_IMAGE):$(AWS_CLI_VERSION)
AWS_TF_IMAGE            = $(IMAGE_PREFIX)-aws-tf
AWS_TF_IMAGE_TAG        = $(AWS_TF_IMAGE):$(TERRAFORM_VERSION)
AWS_TF_DEV_IMAGE        = $(AWS_TF_IMAGE)-dev
AWS_TF_DEV_IMAGE_TAG    = $(AWS_TF_DEV_IMAGE):$(TERRAFORM_VERSION)
ANSIBLE_IMAGE           = $(IMAGE_PREFIX)-ansible
ANSIBLE_VERSION        ?= latest
ANSIBLE_IMAGE_TAG       = $(ANSIBLE_IMAGE):$(ANSIBLE_VERSION)
JQ_IMAGE                = $(IMAGE_PREFIX)-jq
JQ_VERSION             ?= latest
JQ_IMAGE_TAG            = $(JQ_IMAGE):$(JQ_VERSION)
AZAPI_IMAGE             = $(IMAGE_PREFIX)-azapi
AZAPI_VERSION          ?= latest
AZAPI_IMAGE_TAG         = $(AZAPI_IMAGE):$(AZAPI_VERSION)


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

docker: ## Prints docker version
	docker version

base: docker ## Builds base container
	$(BUILD_COMMAND) ./common/base --build-arg JQIMAGE=$(JQ_IMAGE_TAG) --build-arg VERSION=$(BASE_VERSION) -t $(BASE_IMAGE_TAG)

openssl: base ## Builds an openssl container
	$(BUILD_COMMAND) ./common/openssl --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(OPENSSL_VERSION) -t $(OPENSSL_IMAGE_TAG)

go: base openssl ## Builds a go build container
	$(BUILD_COMMAND) ./common/go --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(GO_VERSION) --build-arg PLATFORM_SHORT=$(PLATFORM_SHORT) -t $(GO_IMAGE_TAG)

go-dev: base openssl go vault ## Builds a go dev container
	$(BUILD_COMMAND) ./common/go/dev --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg VAULTIMAGE=$(VAULT_IMAGE_TAG) -t $(GO_DEV_IMAGE_TAG)

ruby: base openssl ## Builds a ruby container
	$(BUILD_COMMAND) ./common/ruby --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(RUBY_VERSION) -t $(RUBY_IMAGE_TAG)

node: base ## Builds a nodejs build container
	$(BUILD_COMMAND) ./common/node --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(NODE_VERSION) -t $(NODE_IMAGE_TAG)

python: base openssl ## Builds a python build container
	$(BUILD_COMMAND) ./common/python --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(PYTHON_VERSION) -t $(PYTHON_IMAGE_TAG)

vault: base go node jq openssl ## Builds vault container
	$(BUILD_COMMAND) ./common/vault --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg NODEIMAGE=$(NODE_IMAGE_TAG) --build-arg JQIMAGE=$(JQ_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(VAULT_VERSION) --build-arg MODE=$(VAULT_MODE) -t $(VAULT_IMAGE_TAG)

vault-dev: vault terraform ## Builds a vault dev environment container
	$(BUILD_COMMAND) ./common/vault/dev --build-arg BASEIMAGE=$(VAULT_IMAGE_TAG) --build-arg TFIMAGE=$(TERRAFORM_IMAGE_TAG) -t $(VAULT_DEV_IMAGE_TAG)

terraform: base go openssl ## Builds terraform container
	$(BUILD_COMMAND) ./common/terraform --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(TERRAFORM_VERSION) -t $(TERRAFORM_IMAGE_TAG)

packer: base go ## Builds packer container
	$(BUILD_COMMAND) ./common/packer --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(PACKER_VERSION) -t $(PACKER_IMAGE_TAG)

consul: base go jq openssl ## Builds consul container
	$(BUILD_COMMAND) ./common/consul --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg JQIMAGE=$(JQ_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(CONSUL_VERSION) -t $(CONSUL_IMAGE_TAG)

common: terraform vault ## Builds all common images in toolchain

ibm-tf: terraform go ## Builds a terraform container with the IBM provider plugin
	$(BUILD_COMMAND) ./IBM/terraform --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(IBM_TF_VERSION) --build-arg TFIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) -t $(IBM_TF_IMAGE_TAG)

ibm-cli: base openssl ## Builds the IBM Cloud CLI with plugins in a container
	$(BUILD_COMMAND) ./IBM/cli --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(IBM_CLI_VERSION) --build-arg PLATFORM_SHORT=$(PLATFORM_SHORT) -t $(IBM_CLI_IMAGE_TAG)

ibm: ibm-tf ibm-cli ## Builds all IBM Cloud accelerators in containers

az-cli: base openssl python jq ## Builds an azcli container
	$(BUILD_COMMAND) ./azure/cli --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(AZURE_CLI_VERSION) --build-arg PLATFORM_SHORT=$(PLATFORM_SHORT) -t $(AZURE_CLI_IMAGE_TAG)

azapi: base openssl go ## Builds an azapi Terraform provider
	$(BUILD_COMMAND) ./azure/providers/azapi --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg VERSION=$(AZAPI_VERSION) -t $(AZAPI_IMAGE_TAG)

az-tf-dev: az-cli terraform packer jq azapi ## Builds an Azure-specific terraform container
	$(BUILD_COMMAND) ./azure/terraform-dev --build-arg BASEIMAGE=$(AZURE_CLI_IMAGE_TAG) --build-arg TFIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg PACKERIMAGE=$(PACKER_IMAGE_TAG) --build-arg JQIMAGE=$(JQ_IMAGE_TAG) --build-arg AZAPIIMAGE=$(AZAPI_IMAGE_TAG) -t $(AZURE_TF_DEV_IMAGE_TAG)

azure: base az-cli az-tf-dev ## Builds all Azure cloud accelerators in containers

gcp-base: base ## Builds a common intermediate base container for GCP
	$(BUILD_COMMAND) ./gcp/base --build-arg BASEIMAGE=${BASE_IMAGE_TAG} --build-arg VERSION=$(GCP_BASE_VERSION) -t $(GCP_BASE_IMAGE_TAG)

gcp-sdk: gcp-base python openssl ## Builds the Google Cloud Platform (GCP) SDK in a container
	$(BUILD_COMMAND) ./gcp/sdk --build-arg BASEIMAGE=$(GCP_BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(GCP_CLI_VERSION) -t $(GCP_CLI_IMAGE_TAG)

gcp-tf-dev: gcp-sdk terraform packer jq ansible ## Builds an GCP-specific terraform container for terraform development
	$(BUILD_COMMAND) ./gcp/terraform-dev --build-arg BASEIMAGE=$(GCP_CLI_IMAGE_TAG) --build-arg TFIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg PACKERIMAGE=$(PACKER_IMAGE_TAG) --build-arg JQIMAGE=$(JQ_IMAGE_TAG) --build-arg ANSIBLEIMAGE=$(ANSIBLE_IMAGE_TAG) -t $(GCP_TF_DEV_IMAGE_TAG)

gcp: base gcp-sdk

aws-cli: base openssl python ## Builds an azcli container
	$(BUILD_COMMAND) ./aws/cli --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(AWS_CLI_VERSION) -t $(AWS_CLI_IMAGE_TAG)

aws-tf-dev: aws-cli terraform packer jq ## Builds an AWS-specific terraform container
	$(BUILD_COMMAND) ./aws/terraform-dev --build-arg BASEIMAGE=$(AWS_CLI_IMAGE_TAG) --build-arg TFIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg PACKERIMAGE=$(PACKER_IMAGE_TAG) --build-arg JQIMAGE=$(JQ_IMAGE_TAG) -t $(AWS_TF_DEV_IMAGE_TAG)

aws: aws-cli aws-tf-dev

clouds: aws azure gcp ibm ## Builds all cloud accelerators in containers

terraformer: base go openssl python gcp terraform ## Builds terraformer container
	$(BUILD_COMMAND) ./common/terraformer --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg GOIMAGE=$(GO_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg TERRAFORMIMAGE=$(TERRAFORM_IMAGE_TAG) --build-arg GCPCLIIMAGE=$(GCP_CLI_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg VERSION=$(TERRAFORMER_VERSION) -t $(TERRAFORMER_IMAGE_TAG)

ansible: base python
	$(BUILD_COMMAND) ./common/ansible --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg PYTHONIMAGE=$(PYTHON_IMAGE_TAG) --build-arg OPENSSLIMAGE=$(OPENSSL_IMAGE_TAG) --build-arg VERSION=$(ANSIBLE_VERSION) -t $(ANSIBLE_IMAGE_TAG)

jq: base openssl ## Builds jq container
	$(BUILD_COMMAND) ./common/jq --build-arg BASEIMAGE=$(BASE_IMAGE_TAG) --build-arg VERSION=$(JQ_VERSION) -t $(JQ_IMAGE_TAG)

tidy: ## Removes intermediate build containers (aka "dangling")
	docker rmi -f $(DANGLING_IMAGES)

clean: tidy ## Removes all container images associated with this repo
	docker image prune -f
	docker rmi -f $(REPO_IMAGES)
