default: help


.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

setup: # setup the project and install dependencies
	@asdf install
	@pip install -r ./bin/requirements.txt

deploy: context-local # Deploy to local Kubernetes environment [ctx: docker-desktop]
	@kustomize build ./overlays/local --enable-helm | kubectl apply -f -

diff: context-local # Diff deployment changes vs local Kubernetes environment [ctx: docker-desktop]
	@kustomize build ./overlays/local --enable-helm | kubectl diff -f -

destroy: context-local # Destroy the local Kubernetes environment [ctx: docker-desktop]
	@kustomize build ./overlays/local --enable-helm | kubectl delete -f -

context-local: # set kubectl to local context
	@kubectl config use-context docker-desktop
	@kubectl config set-context --current --namespace=default

# sync-s3-data: # copy data from ./data to S3://data/
# 	@if aws --endpoint-url=http://127.0.0.1:4566 s3 ls "s3://data" 2>&1 | grep -q "NoSuchBucket"; then \
# 		aws --endpoint-url=http://127.0.0.1:4566 s3 mb "s3://data"; \
# 	fi
# 	@aws --endpoint-url=http://127.0.0.1:4566 s3 sync ./data/s3 "s3://data"

replay-user-event: # replay userEvent parquet -> kinesis userEvent
	@python ./bin/replay.py -p ./data/s3/user-event -dt kinesis -t userEvent
