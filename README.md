# One-Eye

An infrastructure and deployment automation project on AWS. A GitHub Actions pipeline provisions servers with Terraform, sets up a K3s Kubernetes cluster with Ansible, and deploys a containerized application from Amazon ECR, with no manual steps in between.

## Status

Work in progress. The roadmap at the bottom shows exactly what is finished and what is not. Items are ticked only when they work.

## Problem

Deploying even a simple application by hand means creating servers, installing Kubernetes, building and pushing images, and applying manifests, and each step is easy to get wrong or forget. One-Eye turns that into a repeatable pipeline: the same code produces the same environment every time.

## Architecture

```
GitHub Actions
  |
  |-- Infrastructure workflow
  |     Terraform  -> 3 EC2 instances, IAM roles, Security Groups
  |     Ansible    -> installs K3s on each instance
  |
  '-- Application workflow
        Build Docker image -> push to Amazon ECR
        K3s node pulls the image from ECR
        SSH into EC2 -> copy and apply Kubernetes manifests
```

## Tech stack

| Tool | Purpose |
|---|---|
| Terraform | Provision EC2, IAM, Security Groups, ECR; S3 remote state |
| Ansible | Install and configure K3s on the instances |
| K3s | Lightweight Kubernetes cluster |
| GitHub Actions | CI/CD, authenticating to AWS with OIDC |
| Amazon ECR | Container image registry |
| AWS (EC2, IAM, S3) | Compute, access control, Terraform state |

## Design decisions

- **Remote state with a bootstrap step.** Terraform first creates the S3 bucket that stores state (`bootstrap`), then the main infrastructure (`infra`) uses that bucket as its backend.
- **GitHub OIDC instead of stored AWS keys.** The pipeline assumes an IAM role through OpenID Connect, so no long-lived credentials live in GitHub secrets.
- **OIDC role created manually once.** The role that the pipeline itself depends on is created by hand and documented below, rather than by the pipeline that needs it.
- **Separate pipelines for first-time setup and updates.** Creating the infrastructure and shipping a new app version are different jobs and run separately.
- **K3s instead of a managed Kubernetes service.** K3s keeps the cluster lightweight and cheap enough to run for learning and demos.

## Repository structure

## Repository structure

```
one-eye/
│
├── terraform/
│   ├── bootstrap/           Step 1: creates the S3 bucket for Terraform remote state
│   └── infra/               Step 2: EC2 instances, Security Groups, IAM roles, ECR
│
├── ansible/
│   └── k3s/                 Playbook that installs K3s on each EC2 instance
│
├── k8s/                     Kubernetes manifests (Deployment, Service) for the sample app
│
├── .github/
│   └── workflows/
│       ├── infra.yml        Provisions infrastructure and sets up the K3s cluster
│       └── deploy.yml       Builds the image, pushes to ECR, deploys to the cluster
│
├── .gitignore
└── README.md

```
Folders marked in the roadmap as not done yet are not in the repository yet.

Folders that do not exist yet are still on the roadmap.

## Prerequisites

- An AWS account and a GitHub repository for this project
- The GitHub OIDC role described below
- Repository secrets configured (role ARN, region, SSH key as required by the workflows)

## One-time setup: GitHub OIDC role

1. In IAM, add an identity provider: `https://token.actions.githubusercontent.com`, audience `sts.amazonaws.com`.
2. Create an IAM role that trusts that provider, restricted to this repository: `repo:Pranavshinde-sa/One-Eye:*`.
3. Attach a policy that allows the pipeline to:
   - **S3:** create the state bucket, enable versioning, read, write and list objects
   - **EC2:** create, describe, modify and terminate instances, Security Groups and key pairs
   - **IAM:** create and manage the instance roles and instance profiles for the nodes, plus `iam:PassRole` for them
   - **ECR:** create repositories, push and pull images, get an authorization token
4. Store the role ARN as a repository secret, for example `AWS_ROLE_ARN`.

These permissions are the starting point. After the pipeline works end to end, tighten the policy to specific resources.

## Usage

1. Complete the one-time setup above.
2. Run the infrastructure workflow: Terraform creates the servers and Ansible installs K3s.
3. Run or trigger the application workflow: the image is built, pushed to ECR and deployed to the cluster.
4. To avoid AWS charges, destroy the environment when finished:

```bash
cd terraform/infra
terraform destroy
```

## Roadmap

- [ ] Terraform bootstrap (S3 remote state)
- [ ] Terraform infra (3 EC2 instances, Security Groups, IAM roles, ECR)
- [ ] Ansible playbook to install K3s on all nodes
- [ ] Infrastructure pipeline with GitHub OIDC
- [ ] Application pipeline (build, push to ECR, deploy manifests)
- [ ] Separate update pipeline
- [ ] End-to-end demo with screenshots

## What I am learning

This project is where I am practicing infrastructure as code, configuration management, and pipeline design together. Known gaps: monitoring and logging are not included yet, and the IAM policy still needs to be reduced to least privilege.

## Author

Pranav Shinde
GitHub: https://github.com/Pranavshinde-sa
LinkedIn: https://www.linkedin.com/in/pranavshinde3
