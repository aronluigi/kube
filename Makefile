default: help


.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

setup: # setup the project and install dependencies
	@asdf install

deploy: context-local # Deploy to local Kubernetes environment [ctx: docker-desktop]
	@kustomize build ./overlays/local --enable-helm | kubectl apply -f -

diff: context-local # Diff deployment changes vs local Kubernetes environment [ctx: docker-desktop]
	@kustomize build ./overlays/local --enable-helm | kubectl diff -f -

destroy: context-local # Destroy the local Kubernetes environment [ctx: docker-desktop]
	@kustomize build ./overlays/local --enable-helm | kubectl delete -f -

context-local: # set kubectl to local context
	@kubectl config use-context docker-desktop
	@kubectl config set-context --current --namespace=default
