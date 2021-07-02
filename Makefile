ENV?=prod
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
	-var-file="./environments/common.tfvars" \
	-var-file="./s3_mirror_list.tfvars" \
	-var-file="./gcp_function_list.tfvars" \
	-var="gcp_project_id=$(GCP_PROJECT_ID)" \
	-var="gcs_bucket=$(GCS_BUCKET)" \
	-var="aws_access_key=$(AWS_ACCESS_KEY_ID)" \
	-var="aws_secret_key=$(AWS_SECRET_ACCESS_KEY)"

terraform-apply:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform apply \
	-var-file="./environments/common.tfvars" \
	-var-file="./s3_mirror_list.tfvars" \
	-var-file="./gcp_function_list.tfvars" \
	-var="gcp_project_id=$(GCP_PROJECT_ID)" \
	-var="gcs_bucket=$(GCS_BUCKET)" \
	-var="aws_access_key=$(AWS_ACCESS_KEY_ID)" \
	-var="aws_secret_key=$(AWS_SECRET_ACCESS_KEY)" \
	-auto-approve

terraform-destroy:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform destroy \
	-var-file="./environments/common.tfvars" \
	-var-file="./gcp_function_list.tfvars" \
	-var-file="./s3_mirror_list.tfvars" \
	-var="gcp_project_id=$(GCP_PROJECT_ID)" \
	-var="gcs_bucket=$(GCS_BUCKET)" \
	-var="aws_access_key=$(AWS_ACCESS_KEY_ID)" \
	-var="aws_secret_key=$(AWS_SECRET_ACCESS_KEY)" \
	-auto-approve