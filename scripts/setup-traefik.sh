#!/bin/bash

DOMAIN_NAME=$1
POD_SUBNET=$2

# Traefik 1.x
cat <<EOF | helm install traefik stable/traefik --version 1.81.0 --namespace kube-system -f -
dashboard:
  enabled: true
  domain:  "${DOMAIN_NAME}"
loadBalancerIP: "${POD_SUBNET}254"
rbac:
  enabled: true
ssl:
  enabled: true
metrics:
  prometheus:
    enabled: true
kubernetes:
  ingressEndpoint:
    useDefaultPublishedService: true
image: "rancher/library-traefik"
tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
EOF

