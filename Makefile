ENV?=dev
GCP_PROJECT_ID?="terraform-test-316516"
GCS_BUCKET?="ericjm24-temp-bucket"

create-tf-backend-bucket:
	gsutil mb -p $(GCP_PROJECT_ID) gs://$(GCP_PROJECT_ID)-terraform-bucket

terraform-create-workspace:
	cd terraform && terraform workspace new $(ENV)

terraform-init:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform init

terraform-plan:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform plan \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars" \
	-var="gcp_project_id=$(GCP_PROJECT_ID)" \
	-var="gcs_bucket=$(GCS_BUCKET)"

terraform-apply:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform apply \
	-auto-approve \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars" \
	-var="gcp_project_id=$(GCP_PROJECT_ID)" \
	-var="gcp_bucket=$(GCP_BUCKET)"

terraform-destroy:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform destroy \
	-auto-approve \
	-var-file="./environments/${ENV}/config.tfvars" \
	-var-file="./environments/common.tfvars" \
	-var="gcp_project_id=$(GCP_PROJECT_ID)" \
	-var="gcp_bucket=$(GCP_BUCKET)"