P_ID=terraform-test-316516
### Creates a bucket for storage
create-tf-backend-bucket:
	gsutil mb -p $(P_ID) gs://$(P_ID)-terraform-bucket

ENV=dev
terraform-create-workspace:
	cd terraform && terraform workspace new $(ENV)

terraform-init:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform init

terraform-plan: terraform-init
	cd terraform && \
	terraform plan \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars"

terraform-apply: terraform-init
	cd terraform && \
	terraform apply \
	-auto-approve \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars"

terraform-destroy:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform destroy \
	-auto-approve \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars"


SSH_STRING = 'eric_miller@terraform-test-${ENV}-vm'
GITHUB_SHA?=latest
LOCAL_TAG=terraform-test:$(GITHUB_SHA)
REMOTE_TAG=gcr.io/$(P_ID)/$(LOCAL_TAG)
CONTAINER_NAME=my-terraform-container

ssh-cmd:
	@gcloud compute ssh $(SSH_STRING) \
		--project=$(P_ID) \
		--zone='us-central1-a' \
		--command="$(CMD)"

docker-build:
	docker build -t $(LOCAL_TAG) .

docker-push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

docker-deploy: terraform-init
	$(MAKE) ssh-cmd CMD='docker-credential-gcr configure-docker'
	$(MAKE) ssh-cmd CMD='docker pull $(REMOTE_TAG)'
	-$(MAKE) ssh-cmd CMD='docker container stop $(CONTAINER_NAME)'
	-$(MAKE) ssh-cmd CMD='docker container rm $(CONTAINER_NAME)'
	$(MAKE) ssh-cmd CMD='\
		docker run -d --name=$(CONTAINER_NAME) \
		--restart=unless-stopped \
		-p 80:5000 \
		-e PORT=5000 \
		-e ENV=$(ENV) \
		$(REMOTE_TAG)'