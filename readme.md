# AWS Static Website Platform with Secure File Uploads

A production-style AWS project built using Terraform that demonstrates infrastructure provisioning, secure file uploads using pre-signed URLs, multipart uploads for large files, CDN-based website delivery, and automated deployments through GitHub Actions.

---

## What This Project Demonstrates

This repository combines several common AWS patterns that are frequently used in production environments:

### Infrastructure as Code

* Terraform modules
* Remote Terraform state
* Reusable infrastructure design

### Secure Object Storage

* Private S3 buckets
* Server-side encryption
* Bucket versioning
* Lifecycle management

### Secure Upload Workflows

* Pre-signed URL generation
* Direct browser/client uploads to S3
* Temporary access without exposing AWS credentials

### Large File Upload Handling

* Multipart upload initiation
* Chunked uploads
* Upload completion workflow
* Efficient handling of large files

### Content Delivery

* CloudFront CDN
* Origin Access Control (OAC)
* HTTPS delivery
* Edge caching

### CI/CD

* GitHub Actions
* Automated website deployment
* CloudFront cache invalidation

---

# Architecture

```text
                           GitHub
                              |
                              |
                        GitHub Actions
                              |
                              |
                              v

+--------------------------------------------------+
|                     AWS Cloud                    |
+--------------------------------------------------+
|                                                  |
|  CloudFront Distribution                         |
|          |                                       |
|          | OAC                                   |
|          v                                       |
|  Private Website Bucket                          |
|                                                  |
|  Upload Bucket                                   |
|      |                                           |
|      +-- Presigned URLs                          |
|      +-- Multipart Uploads                       |
|                                                  |
|  Terraform State Bucket                          |
|      +-- Versioning                              |
|      +-- Encryption                              |
|                                                  |
+--------------------------------------------------+

                ^                    ^
                |                    |
         Website Users        Upload Clients
```

---

# Key Features

## 1. Static Website Hosting

The portfolio website is hosted using:

* Amazon S3
* Amazon CloudFront

The website bucket remains private at all times.

Users access content exclusively through CloudFront.

Benefits:

* Global content delivery
* Reduced latency
* HTTPS support
* Origin protection

---

## 2. Secure File Uploads with Pre-Signed URLs

Traditional uploads require AWS credentials.

This project demonstrates a safer approach using S3 pre-signed URLs.

Workflow:

```text
Client
  |
  | Request Upload URL
  v
Backend
  |
  | Generate Pre-Signed URL
  v
S3

Client
  |
  | Upload File Directly
  v
S3
```

Benefits:

* AWS credentials never exposed
* Time-limited access
* Reduced backend load
* Scalable architecture

### Example Use Cases

* Profile photo uploads
* Resume uploads
* Media uploads
* User-generated content

---

## 3. Multipart Uploads

Large files are uploaded using S3 Multipart Uploads.

Workflow:

```text
Initiate Upload
       |
       v
Upload Part 1
Upload Part 2
Upload Part 3
...
Upload Part N
       |
       v
Complete Upload
```

Benefits:

* Supports large files
* Parallel uploads
* Better reliability
* Resume capability

This project includes Python scripts demonstrating:

* Upload initiation
* Part upload
* Upload completion
* Error handling

---

## 4. CloudFront Caching

CloudFront uses AWS Managed Cache Policies.

### HTML

```text
Cache-Control: public,max-age=3600
```

### Images and Static Assets

```text
Cache-Control: public,max-age=86400
```

Benefits:

* Faster page loads
* Reduced S3 requests
* Lower costs

---

## 5. Automated Deployments

Every push to the main branch automatically:

1. Validates Terraform
2. Uploads website assets
3. Invalidates CloudFront cache

Deployment pipeline:

```text
git push
    |
    v
GitHub Actions
    |
    +--> Terraform Validate
    |
    +--> S3 Upload
    |
    +--> CloudFront Invalidation
    |
    v
Production Website Updated
```

---

# Project Structure

```text
aws-terraform-portfolio-tring/

├── terraform/
│
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   │
│   └── modules/
│       ├── s3/
│       └── cloudfront/
│
├── website/
│   ├── index.html
│   └── photo.jpg
│
├── presigned-url/
│   ├── generate_put_url.py
│   └── generate_get_url.py
│
├── multipart-upload/
│   ├── initiate_upload.py
│   ├── upload_parts.py
│   └── complete_upload.py
│
└── .github/
    └── workflows/
        └── deploy.yml
```

Adjust folder names as required.

---

# Prerequisites

Install:

* Terraform
* AWS CLI
* Git
* Python 3.10+

Verify:

```bash
terraform version
aws --version
python --version
git --version
```

---

# Initial AWS Setup

## Create an IAM User

Recommended permissions:

* AmazonS3FullAccess
* CloudFrontFullAccess

For learning purposes.

In production, use least privilege permissions.

Configure credentials:

```bash
aws configure
```

---

# Terraform Setup

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Review:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

Destroy:

```bash
terraform destroy
```

---

# Testing Pre-Signed Uploads

Generate upload URL and test Upload:

```bash
python presgined_put.py
```

Verify object:

```bash
aws s3 ls s3://<bucket-name>
```

---

# Testing Pre-Signed Downloads

Generate upload URL and test Download:

```bash
python presgined_get.py
```

Verify object:

```bash
ls
```

---

# Testing Multipart Uploads

Perform Multipart Upload:

```bash
python multipart_upload.py
```

Verify:

```bash
aws s3 ls s3://<bucket-name>
```

---

# Security Considerations

### S3 Buckets

* Private by default
* Public access blocked
* Server-side encryption enabled

### CloudFront

* HTTPS enforced
* Origin Access Control enabled

### Upload Security

* Time-limited pre-signed URLs
* No AWS credentials exposed to clients

### Terraform State

* Stored remotely
* Versioned
* Encrypted

---

## Author

**Tarun Harish**