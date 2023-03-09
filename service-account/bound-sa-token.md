%title: Bound Service Account Token
%author: Krzysztof Ostrowski
%date: 10.03.2023

-> # Bound Service Account Token <-

--------------------------------------------------
-> # Table of Contents <-
==============

* What is a Service Account Token
* How are they being used
* What changed

-------------------------------------------------
-> # What is a Service Account Token  <-

An identity that an instance or an applicadtion can use to make API requests

1. Intended to be used for processes.
2. Bound to a namespace.
3. Being associated with a ServiceAccount provides a Bearer Token.

-------------------------------------------------
-> # Service Account Token as a YAML <-

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-sa
  namespace: my-namespace
```

-------------------------------------------------
-> # Old Service Account Token Behavior  <-

1. Previously didn't expire.
2. Previously could be used anywhere.
3. Token was stored in a secret.

-------------------------------------------------
-> # What is a Bound Service Account Token  <-

- A Service Account Token that is **bound** to an **audience and lifespan**.
- Given by **volume projection** or **TokenRequestAPI**.
- kubelet tries to rotate it after 80% of its lifetime is over.
- kubelet acquires it from the apiserver through the TokenRequestAPI.

-------------------------------------------------
-> # Lord of ServiceAccounts: Service Account Admission Controller <-

In case that a **Pod Manifest** doesn't have a `ServiceAccount` specified:
- adds the default `ServiceAccount`,
- adds a **projected volume** and
- adds `ImagePullSecrets`

Runs within the `apiserver`.

-------------------------------------------------
-> # Bound Service Account Token in use by a Pod <-

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - mountPath: /var/run/secrets/tokens
      name: vault-token
  serviceAccountName: build-robot 
  volumes:
  - name: vault-token
    projected:
      sources:
      - serviceAccountToken:
          path: vault-token 
          expirationSeconds: 7200 
          audience: vault
```

-------------------------------------------------
-> # Legacy Usage <-

Creates a secret with the token inside:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: build-robot-secret
  annotations:
    kubernetes.io/service-account.name: build-robot
type: kubernetes.io/service-account-token
```

-------------------------------------------------
-> # Lord of Tokens: Token Controller <-

- Creates `ServiceAccount` `secret`
- Has **private key** to sign the **bearer token**.
- **Public key** needs to be shared with **apiserver**.

Runs within the `kube-controller-manager`.

-------------------------------------------------
-> # Misc <-
- Path for the Bearer Token is `/var/run/secrets/kubernetes.io/serviceaccount`

