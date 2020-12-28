#!/bin/bash 

# Metrics
helm install metrics-server stable/metrics-server --version 2.11.4 --set 'args={--kubelet-insecure-tls, --kubelet-preferred-address-types=InternalIP}' --namespace kube-system
