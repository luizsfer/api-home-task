.PHONY: install
install:
	pip3 install -r app/requirements.txt
	pip3 install -r app/tests/requirements.txt

.PHONY: build
build: clean
	./infra/build_lambda.sh

.PHONY: test
test: install
	pytest app/tests

.PHONY: deploy
deploy: build
	cd infra && terraform init
	cd infra && terraform apply -auto-approve

.PHONY: empty-bucket
empty-bucket:
	aws s3 rm s3://luiz-ferreira-test-lambda-bucket --recursive

.PHONY: destroy
destroy: empty-bucket
	cd infra && terraform destroy -auto-approve

.PHONY: clean
clean:
	rm -rf package app/lambda.zip

.PHONY: add-user
add-user:
	@echo "Adding user..."
	@curl -X POST -H "Content-Type: application/json" -d '{"dateOfBirth": "1990-12-13"}' $(shell cd infra && terraform output -raw api_endpoint)/hello/username
