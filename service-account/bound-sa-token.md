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
2. Token was stored in a secret.

-------------------------------------------------
-> # What is a Bound Service Account Token  <-

- A Service Account Token that is **bound** to an **audience and timespan**.
- Given by **volume projection** or **TokenRequestAPI**.
- kubelet tries to rotate it after 80% of its lifetime is over.
- kubelet acquires it from the apiserver.

-------------------------------------------------
-> # Lord of Tokens: Admission Controller <-

- In case that a Pod doesn't have a `ServiceAccount` specified, it gets the default one by the **Admission Controller**.
- Automounts an extra volume that contains the Bearer Token.
- Path for the Bearer Token is `/var/run/secrets/kubernetes.io/serviceaccount`
- Copies ImagePullSecrets, if not in the PodSpec.

-------------------------------------------------
-> # The other Lord of Tokens: Token Controller <-

- Creates ServiceAccount secrets
- Has private key to sign the bearer token.
- Public key needs to be shared with apiserver.

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

