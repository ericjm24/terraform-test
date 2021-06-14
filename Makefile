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
	terraform workspace select $(ENV) && \
	terraform plan \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars"

terraform-apply: terraform-init
	cd terraform && \
	terraform workspace select $(ENV) && \
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

ssh-cmd: terraform-init
	@gcloud compute ssh $(SSH_STRING) \
		--project=$(PROJECT_ID) \
		--zone=$(ZONE) \
		--command="$(CMD)"