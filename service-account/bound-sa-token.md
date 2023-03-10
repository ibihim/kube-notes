%title: Bound Service Account Token
%author: Krzysztof Ostrowski
%date: 10.03.2023

-> # Bound Service Account Token <-

-------------------------------------------------
-> # What is a Service Account <-

An **identity** that an instance or an application can use to make **API requests**:

- Intended to be used for **processes**.
- **Namespace** scoped.
- Pods the have a ServiceAccount, get access to Service Account Token.

-------------------------------------------------
-> # Service Account as a YAML <-

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-sa
  namespace: my-namespace
```

-------------------------------------------------
-> # What is a Bound Service Account Token  <-

- **Bound** to
    - a *resource, like **Pod** or **Secret**
    - an **audience and lifespan**.
- Provided by 
    - **volume projection** or 
    - **TokenRequestAPI**.
- Stored in a Pod at
    - `/var/run/secrets/kubernetes.io/serviceaccount`

-------------------------------------------------
-> # Old Service Account Token Behavior  <-

1. Token was **stored in a secret**.
2. Previously **didn't expire**.
3. Previously could be **used anywhere**.

-------------------------------------------------
-> # Lord of Tokens: Kubelet <-

- Tries to **rotate** it after 80% of its lifetime is over.
- Acquires it from the `kube-apiserver` through the `TokenRequest` API.

-------------------------------------------------
-> # Lord of ServiceAccounts: Service Account Admission Controller <-

Runs within the `kube-apiserver`.

In case that a **Pod Manifest** doesn't have a `ServiceAccount` specified:
- adds the default `ServiceAccount`,
- adds a **projected volume** and

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

Creates a secret, that is asking for a token to being injected into:

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
-> # Lord of Legacy Tokens: Token Controller <-

- Runs within the `kube-controller-manager`.
- Creates a `secret` for a `ServiceAccountToken` 
- Has **private key** to sign the **bearer token**.
- **Public key** needs to be shared with `kube-apiserver`.

