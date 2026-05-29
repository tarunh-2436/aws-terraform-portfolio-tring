# AWS Terraform Portfolio Website

This repository provisions and deploys a static portfolio website on AWS using Terraform, Amazon S3, and Amazon CloudFront. It also includes GitHub Actions automation for website deployment and Python utilities for testing pre-signed uploads, downloads, and multipart uploads.

---

## Architecture

* **Amazon S3** hosts the static website assets.
* **Amazon CloudFront** serves content globally with Origin Access Control (OAC).
* **Terraform** manages all infrastructure as code.
* **GitHub Actions** automates deployment of website assets.
* **Python scripts** generate pre-signed URLs and perform multipart uploads.

### Security Features

* S3 bucket blocks all public access.
* CloudFront accesses S3 through Origin Access Control (OAC).
* Bucket policy restricts object access to CloudFront only.
* Objects can be uploaded and downloaded securely using pre-signed URLs.

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml
├── modules/
│   ├── cloudfront/
│   └── s3/
├── scripts/
│   ├── presigned_put.py
│   ├── presigned_get.py
│   └── multipart_upload.py
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── website/
│   ├── index.html
│   └── assets/
|
└── README.md
```

---

## Prerequisites

### Tools

* Terraform >= 1.5
* AWS CLI configured
* Python 3.9+
* Git

### AWS Permissions

The AWS identity used for deployment should have permissions for:

* Amazon S3
* Amazon CloudFront
* IAM (if creating policies)
* Terraform backend bucket access

---

## Configure Terraform Backend

Update `backend.tf` with your backend bucket information:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "portfolio/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Initialize Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Preview changes:

```bash
terraform plan
```

Deploy infrastructure:

```bash
terraform apply
```

---

## Terraform Outputs

After deployment:

```bash
terraform output
```

Expected outputs include:

```text
cloudfront_domain_name
```

---

## Website Deployment

Place website files inside:

```text
website/
```

Example:

```text
website/
├── index.html
├── css/
├── js/
└── images/
```

Upload manually:

```bash
aws s3 sync website/ s3://<bucket-name> --delete
```

Invalidate CloudFront cache:

```bash
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

---

## GitHub Actions Deployment

The repository includes:

```text
.github/workflows/deploy.yml
```

### Required GitHub Secrets

Add the following repository secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### Required GitHub Variables

```text
WEBSITE_BUCKET
CLOUDFRONT_DISTRIBUTION_ID
```

### Workflow Actions

The deployment workflow:

1. Checks out the repository.
2. Configures AWS credentials.
3. Runs Terraform initialization and validation.
4. Uploads website assets to S3.
5. Invalidates the CloudFront cache.

Pushing changes to the configured branch automatically deploys the latest website version.

---

# Testing

## 1. Verify Terraform Infrastructure

Check deployed resources:

```bash
terraform state list
```

Verify outputs:

```bash
terraform output
```

Expected:

```text
bucket_name
cloudfront_distribution_id
cloudfront_domain_name
```

---

## 2. Verify Website Access Through CloudFront

Retrieve the CloudFront domain:

```bash
terraform output cloudfront_domain_name
```

Open:

```text
https://<cloudfront-domain>
```

Or test via curl:

```bash
curl -I https://<cloudfront-domain>
```

Expected:

```text
HTTP/2 200
```

The website should load successfully.

---

## 3. Verify Direct S3 Access Is Blocked

Attempt direct access:

```bash
curl https://<bucket-name>.s3.amazonaws.com/index.html
```

Expected:

```text
AccessDenied
```

This confirms the bucket is private and only CloudFront can access objects.

---

## 4. Test Pre-Signed Uploads

Generate a pre-signed PUT URL:

```bash
python scripts/presigned_put.py
```

Copy the generated URL and upload a file:

```bash
curl -X PUT \
  --upload-file sample.txt \
  "<presigned-put-url>"
```

Expected:

```text
HTTP 200
```

Verify object exists:

```bash
aws s3 ls s3://<bucket-name>
```

---

## 5. Test Pre-Signed Downloads

Generate a pre-signed GET URL:

```bash
python scripts/presigned_get.py
```

Download the object:

```bash
curl "<presigned-get-url>" -o downloaded-file
```

Verify contents:

```bash
cat downloaded-file
```

Expected:

```text
File contents match uploaded object
```

---

## 6. Test Multipart Uploads

Create a large test file:

```bash
dd if=/dev/zero of=largefile.bin bs=1M count=100
```

Run multipart upload script:

```bash
python scripts/multipart_upload.py
```

Expected:

```text
Upload completed successfully
```

Verify upload:

```bash
aws s3 ls s3://<bucket-name>
```

Confirm the large object exists.

---

## 7. Verify CloudFront Serves Uploaded Objects

After uploading an object:

```bash
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

Access the object:

```bash
https://<cloudfront-domain>/<object-name>
```

Expected:

```text
HTTP 200
```

---

## 8. Verify CloudFront Cache Invalidation

Upload a modified file:

```bash
aws s3 cp index.html s3://<bucket-name>/index.html
```

Create invalidation:

```bash
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

Refresh the website and verify the latest version is displayed.

---

## Cleanup

Destroy all infrastructure:

```bash
terraform destroy
```

Confirm removal:

```bash
aws s3 ls
aws cloudfront list-distributions
```

---

## Troubleshooting

### Terraform Initialization Issues

```bash
terraform init -reconfigure
```

### AWS Credential Issues

Verify:

```bash
aws sts get-caller-identity
```

### CloudFront Changes Not Visible

Create an invalidation:

```bash
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

### S3 Access Denied

Verify:

* Bucket policy is attached.
* OAC is configured correctly.
* CloudFront distribution is deployed.
* S3 Block Public Access remains enabled.