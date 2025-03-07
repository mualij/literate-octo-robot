# Kubernetes ArgoCD and NFS Provisioner Demo

This repository contains Kubernetes manifests and configuration files for setting up an NGINX application using ArgoCD with NFS dynamic provisioning.

## Components

- **NFS Subdir External Provisioner**: For dynamic provisioning of NFS storage
- **ArgoCD**: For GitOps-based continuous deployment
- **NGINX Application**: Example deployment managed by ArgoCD

## Repository Structure

- **manifests/**: Contains Kubernetes YAML manifests for the NGINX application
  - `nginx-deployment.yaml`: Defines the NGINX deployment and service
- **nginx-app.yaml**: ArgoCD Application resource that points to this repository
- **setup/**: Contains scripts for setting up the Kubernetes environment
  - `01-install-microk8s.sh`: Installs and configures MicroK8s
  - `02-configure-zfs.sh`: Configures ZFS storage for Kubernetes
  - `03-install-nfs-provisioner.sh`: Installs and configures NFS Subdir External Provisioner
  - `04-install-argocd.sh`: Installs and configures ArgoCD
  - `05-deploy-nginx-app.sh`: Deploys the NGINX application with ArgoCD

## Setup Instructions

### Option 1: Step-by-Step Manual Setup

#### Prerequisites

- Kubernetes cluster (e.g., MicroK8s)
- NFS server
- Helm
- ArgoCD CLI

#### NFS Provisioner Installation

```bash
# Check if there are any existing releases
helm list -n kube-system

# If needed, uninstall existing releases
helm uninstall nfs-subdir-external-provisioner -n kube-system

# Install the nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=<NFS_SERVER_IP> \
  --set nfs.path=/exported/path \
  --set storageClass.name=nfs-client \
  --set storageClass.defaultClass=true \
  -n kube-system
```

#### ArgoCD Installation

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port forwarding for ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

#### Application Deployment

```bash
# Login to ArgoCD
argocd login localhost:8080

# Create ArgoCD application
kubectl apply -f nginx-app.yaml

# Check application status
argocd app get nginx-app
kubectl get pods -n argocd-test
```

### Option 2: Using Automated Setup Scripts

You can use the provided setup scripts to automate the installation and configuration process:

```bash
# 1. Install MicroK8s (if needed)
./setup/01-install-microk8s.sh

# 2. Configure ZFS storage (if needed)
./setup/02-configure-zfs.sh

# 3. Install NFS Provisioner (provide your NFS server IP and path)
./setup/03-install-nfs-provisioner.sh 192.168.1.100 /exported/path

# 4. Install ArgoCD
./setup/04-install-argocd.sh

# 5. Deploy the NGINX application
./setup/05-deploy-nginx-app.sh
```

## Testing the Application

```bash
# Port forwarding for NGINX service
kubectl port-forward svc/nginx-service -n argocd-test 8082:80

# Access NGINX
curl localhost:8082
```

## Maintenance

- To update the application, simply push changes to this repository
- ArgoCD will automatically detect and apply the changes

## Troubleshooting

- Check ArgoCD application status: `argocd app get nginx-app`
- View application logs: `kubectl logs -n argocd-test <pod-name>`
- Check events: `kubectl get events -n argocd-test`
