# Notes about Kubernetes

This repository contains resources and scripts to understand Kubernetes better.

## Table of Contents

- [Setup](#setup)
- [Exploring the Cluster](#exploring-the-cluster)
- [Service Accounts and Tokens](#service-accounts-and-tokens)

## Bound Service-Account

### Setup

To set up the Kubernetes cluster, you can use the YAML files provided in the `service-account/resources` folder.
These files include the necessary configurations for deploying the cluster, including namespace, deployment, service-account, role-binding and cluster-role-binding.
Apply like so:

```Bash
# Apply all resources...
for yaml in $(ls service-account/resources/*.yaml); do
    kubectl apply -f $yaml
done

# Re-Apply for those that had dependencies in the above.
for yaml in $(ls service-account/resources*.yaml); do
    kubectl apply -f $yaml
done
```

### Play

There are scripts in `service-account/resources` that help you to play with the b Service-Account Tokens.

To see a bound service account token that gets into the pod by a projected volume, use `service-account/resources/get-token.sh | service-account/resources/view-token.sh`.

The Header should look like so:
```json
{
  "alg": "RS256",
  "kid": "jZoE8PHuBmMoiNADGf7D0iIVgIWkoeEQsgk5Mqd7vyc"
}
```

The Payload should look like so:

```json
{
  "aud": [
    "https://kubernetes.default.svc.cluster.local"
  ],
  "exp": 1709924650,
  "iat": 1678388650,
  "iss": "https://kubernetes.default.svc.cluster.local",
  "kubernetes.io": {
    "namespace": "my-namespace",
    "pod": {
      "name": "my-deployment-66cfc8dcf7-8czq5",
      "uid": "ea5f52f1-210a-4f96-b25b-550951a649ca"
    },
    "serviceaccount": {
      "name": "my-service-account",
      "uid": "df44d77a-3d83-4e63-880d-7964aa8eabb2"
    },
    "warnafter": 1678392257
  },
  "nbf": 1678388650,
  "sub": "system:serviceaccount:my-namespace:my-service-account"
}
```

It is bound as it has an `exp`iry and and `aud`ience.
It is not stored in a secret.

