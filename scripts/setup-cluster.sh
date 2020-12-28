#!/bin/bash

MASTER_IP=$1
POD_SUBNET=$2

cat <<EOF > /tmp/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- ttl: "0"
localAPIEndpoint:
  advertiseAddress: ${MASTER_IP}
nodeRegistration:
  kubeletExtraArgs:
    "feature-gates": "EphemeralContainers=true"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: ${MASTER_IP}:6443
networking:
  podSubnet: ${POD_SUBNET}
apiServer:
  extraArgs:
    "feature-gates": "EphemeralContainers=true"
scheduler:
  extraArgs:
    "feature-gates": "EphemeralContainers=true"
controllerManager:
  extraArgs:
    "feature-gates": "EphemeralContainers=true"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
  EphemeralContainers: true
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
featureGates:
  EphemeralContainers: true
EOF
sudo kubeadm init --config /tmp/kubeadm-config.yaml

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubeadm token create --print-join-command > ./joincluster.sh
