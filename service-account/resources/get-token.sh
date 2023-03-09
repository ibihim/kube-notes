#!/usr/bin/env bash

NAMESPACE="my-namespace"

# Get the pod name of the last pod, which should be the only one.
PODNAME="$(kubectl -n "$NAMESPACE" get pods | tail -n1 | awk '{ print $1 }')"

# Get the token from the pod's projected service account.
TOKEN="$(kubectl -n "$NAMESPACE" exec pod/"$PODNAME" -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

# Print the token value without a new line.
printf "%s" "$TOKEN"

