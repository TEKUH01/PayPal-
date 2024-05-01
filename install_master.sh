#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <advertise_address>"
    echo "Example: $0 192.168.1.100"
    exit 1
}

# Check for required arguments
if [ $# -ne 1 ]; then
    usage
fi

# Assign argument to variable
ADVERTISE_ADDRESS=$1

# Install Docker
install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "Docker installed successfully."
}

# Install kubeadm, kubelet, and kubectl
install_kube_tools() {
    echo "Installing kubeadm, kubelet, and kubectl..."
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    echo "kubeadm, kubelet, and kubectl installed successfully."
}

# Initialize Kubernetes master
init_kubernetes_master() {
    echo "Initializing Kubernetes master..."
    sudo kubeadm init --apiserver-advertise-address=$ADVERTISE_ADDRESS --pod-network-cidr=192.168.0.0/16
    echo "Kubernetes master initialized successfully."
}

# Configure kubectl for non-root user
configure_kubectl() {
    echo "Configuring kubectl for non-root user..."
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    echo "kubectl configured successfully."
}

# Install Calico network plugin
install_calico() {
    echo "Installing Calico network plugin..."
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    echo "Calico installed successfully."
}

# Main function
main() {
    install_docker
    install_kube_tools
    init_kubernetes_master
    configure_kubectl
    install_calico
}

# Call the main function
main
