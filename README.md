# Terraform EC2 + Jenkins + GitHub Webhook (Credentials version)

This package provisions one Ubuntu 22.04 EC2 instance using Terraform. Jenkins checks out this repository, runs Terraform, and waits for approval before applying the plan.

## Included files

- `Jenkinsfile` — checkout, init, format, validate, AWS identity verification, plan, manual approval, apply, and outputs.
- `main.tf` — AWS provider, Ubuntu AMI lookup, EC2 instance.
- `variables.tf` — region, instance type, name, and environment.
- `outputs.tf` — instance ID, AMI, type, and public IP.
- `.gitignore` — excludes Terraform state, plans, and local provider data.

## Requirements

- Jenkins agent with Git, Terraform, AWS CLI v2, and a POSIX-compatible shell installed.
- Jenkins Git and GitHub plugins installed.
- AWS IAM credentials with permissions to discover AMIs and create, tag, describe, and manage the EC2 instance.
- GitHub repository containing these files.

## Configure AWS credentials in Jenkins

Go to **Manage Jenkins > Credentials > System > Global credentials > Add Credentials**.

- Kind: **Username with password**
- ID: `aws-credentials`
- Username: AWS Access Key ID
- Password: AWS Secret Access Key

The Jenkinsfile binds these values to `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` only inside stages that need them. Never put keys in the Jenkinsfile, Terraform files, GitHub, or build output.

Use a dedicated IAM identity with least-privilege permissions. Because Jenkins runs on EC2, an attached IAM role with temporary credentials is safer for long-term use; this package intentionally uses Jenkins Credentials as requested.

## Jenkins pipeline job

1. Create a **Pipeline** job.
2. Under **Build Triggers**, enable **GitHub hook trigger for GITScm polling**.
3. Under **Pipeline**, select **Pipeline script from SCM**.
4. SCM: Git. Set the GitHub repository URL and SCM credentials if private.
5. Branch specifier: `*/main` or your actual branch (for example `*/feature`).
6. Script Path: `Jenkinsfile`.
7. Save, then use **Build Now** for the first test.

## GitHub webhook

In GitHub repository **Settings > Webhooks > Add webhook**:

- Payload URL: `https://YOUR-JENKINS-DOMAIN/github-webhook/`
- Content type: `application/json`
- Events: Just the push event
- Active: enabled

Replace the placeholder with the real public HTTPS Jenkins URL. GitHub must be able to reach it securely. Do not expose an unsecured Jenkins server to the public internet.

## AWS region and networking

Default region is `ap-south-1` (Mumbai). Change `aws_region` in `variables.tf` if needed.

This example relies on a suitable default VPC/subnet. It does not create inbound security group rules or open SSH. Public IP assignment depends on subnet configuration. If your account has no suitable default VPC/subnet, add explicit VPC and subnet configuration.

## Test and troubleshoot

Run locally with appropriate AWS credentials:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

In Jenkins, check the `Verify AWS Identity` stage first:
- If `aws sts get-caller-identity` fails, check the Jenkins credential ID and key status.
- If it succeeds but Terraform returns `AccessDenied`, update the IAM permissions.
- If `terraform` or `aws` is not found, install it on the agent or fix `PATH`.
- If `terraform fmt -check` fails, run `terraform fmt -recursive` and commit the formatted files.

## State safety

This demo uses local Terraform state in the Jenkins workspace. For repeated/shared deployments, configure an encrypted S3 backend and state locking, and protect state access. Local state can be lost if the workspace is cleaned or the agent changes. The pipeline saves a plan file temporarily and removes it after the build.

Never commit Terraform state, plan files, AWS keys, or secrets to GitHub.
