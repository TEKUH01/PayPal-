#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <master_ip> <token> <ca_cert_hash>"
    echo "Example: $0 192.168.1.100 abc123def456ghi789 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
    exit 1
}

# Check for required arguments
if [ $# -ne 3 ]; then
    usage
fi

# Assign arguments to variables
MASTER_IP=$1
TOKEN=$2
CA_CERT_HASH=$3

# Install Docker
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
echo "Docker installed successfully."

# Install kubelet and kubectl
echo "Installing kubelet and kubectl..."
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo "kubelet and kubectl installed successfully."

# Join the node to the Kubernetes cluster
echo "Joining node to the Kubernetes cluster..."
sudo kubeadm join $MASTER_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$CA_CERT_HASH
echo "Node joined to the Kubernetes cluster."
