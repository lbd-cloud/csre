# CSRE Repository Overview

This repository contains the necessary configurations and scripts for setting up and managing a Kubernetes cluster on Google Cloud Platform (GCP) using Terraform, and for deploying resources in a GitOps manner using Flux. NGINX is used as ingress controler.

## Repository Structure

- `clusters/`: Contains Flux configuration and Kubernetes manifests for cluster resources.
- `iac/`: Terraform Infrastructure as Code (IaC) for provisioning the GCP Kubernetes (GKE) cluster and related resources.
- `scripts/`: Utility scripts for cluster setup and management.
- `.github/workflows/`: CI/CD workflows for automating infrastructure deployment and Flux operations.

## Processes

## Getting Started

1. **Set up GCP Credentials**: Add your GCP credentials as GitHub Secrets.
2. **Run Terraform**: Go to the `iac/` directory and apply the Terraform configurations to create the GKE cluster.
3. **Bootstrap Flux**: Use the GitHub Actions workflow to bootstrap Flux onto the GKE cluster.
4. **Deploy Resources**: Push changes to the `clusters/` directory to automatically deploy resources via Flux.

### Cluster Creation

- **Location**: `iac/`
- **Description**: Terraform configurations for provisioning a GKE cluster, including VPC and service accounts.
- **Usage**:
  - Initialize Terraform: `terraform init`
  - Create a plan: `terraform plan`
  - Apply the configuration: `terraform apply`

### Flux Bootstrap

- **Workflow File**: `.github/workflows/flux-bootstrap.yml`
- **Description**: GitHub Actions workflow to bootstrap Flux on the GKE cluster. It sets up Flux to monitor the specified directories in the repository and apply Kubernetes manifests automatically.
- **Triggering the Workflow**:
  - Manually via GitHub UI: Go to Actions tab > `flux-bootstrap` workflow > "Run workflow".
  - Automatically: Push changes to the Flux configuration files.

### Deployment of Ingress Controller

- **Location**: `clusters/csre-cluster/nginx-ingress/`
- **Files**:
  - `nginx-ingress.yaml`: Kubernetes manifests for Nginx Ingress Controller.
  - `kustomization.yaml`: Kustomize configuration for applying the manifests.
- **Description**: Flux automatically applies these manifests to deploy the Nginx Ingress Controller in the cluster.
- **Manual Deployment**:
  - Run the `flux-sync` job in the `.github/workflows/flux-bootstrap.yml` workflow to synchronize changes.

### Utility Scripts

- **Location**: `scripts/`
- **Key Scripts**:
  - `setup-kubeconfig.sh`: Generates and encodes the kubeconfig file for GitHub Secrets.
- **Usage**:
  - Run `bash scripts/setup-kubeconfig.sh` to generate the encoded kubeconfig.


## Cosmos Devnet Setup and Testing

The `cosmospg` folder includes configurations and a Makefile for setting up and testing a Cosmos Devnet environment.

### Quick Start with Makefile

- **Location**: `cosmospg/`
- **Description**: Contains a Makefile to streamline the setup and testing of the Cosmos Devnet.
- **Usage**:
  - Navigate to the `cosmospg` directory.
  - Use the Makefile commands to manage the Cosmos Devnet setup and testing. For example, to start the network, run `make start-network`.

### Detailed Instructions

For detailed instructions on the setup, configuration options, and testing procedures, refer to the [`cosmos.md`](doc/cosmos.md) file in the `cosmospg` directory. This document provides comprehensive guidance on working with the Cosmos Devnet environment.

