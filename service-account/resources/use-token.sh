#!/usr/bin/env bash

KUBE_PROXY="http://127.0.0.1:8001"
NAMESPACE="my-namespace"

# Start kubectl proxy in the background
kubectl proxy &
KUBECTL_PROXY_PID=$!

# Ensure kubectl proxy process is killed when script exits
trap 'kill $KUBECTL_PROXY_PID' EXIT

# Wait for kubectl proxy to start listening on port 8001
while ! curl -s -k "$KUBE_PROXY" > /dev/null; do
  sleep 1
done

# Read the token from stdin
read -r TOKEN

# Query the Kubernetes API server for pods in the "my-namespace" namespace using the authentication token.
# Return only the names of the pods.
curl -k \
    -H "Authorization: Bearer $TOKEN" \
    "$KUBE_PROXY/api/v1/namespaces/$NAMESPACE/pods" \
    | jq '.items[].metadata.name'
