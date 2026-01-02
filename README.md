# fastapi-devops-ci-cd

# CI/CD Workflow Summary

1. Source Code Management

Jenkins checks out the latest FastAPI code from GitHub.

2. Automated Testing

Dependencies are installed.

Unit tests are executed to ensure code quality.

3. Docker Image Build

A Docker image is built from the FastAPI application.

Image is tagged as bibekk477/fastapi-devops-ci-cd:latest.

4. Docker Hub Push

The image is pushed to Docker Hub.

The image is public, so no Kubernetes registry secrets are required.

5. Refresh Kubeconfig

Updates Jenkins’ kubectl context to point to Minikube.

6. Kubernetes Deployment (Minikube)

Jenkins deploys the application to a running Minikube cluster.

A Kubernetes Deployment runs 2 replicas for high availability.

A NodePort Service exposes the application externally.

5.  Health Checks & Reliability

    Readiness Probe

        Ensures traffic is sent only to ready pods.

        Prevents requests from hitting unready containers.

    Liveness Probe

        Automatically restarts pods if the application becomes unresponsive.

        This guarantees self-healing, zero-downtime, and stable deployments.

## CI/CD WORKFLOW (FIGURE)

```
┌──────────────┐
│    GitHub    │
│   (Source)   │
└──────┬───────┘
       │ 1️⃣ Checkout Code
       ▼
┌──────────────┐
│   Jenkins    │
│  Pipeline    │
└──────┬───────┘
       │
       │ 2️⃣ Run Unit Tests (pytest)
       ▼
┌──────────────┐
│  Test Stage  │
│ ✔ Pass / ✖ Fail │
└──────┬───────┘
       │
       │ 3️⃣ Build Docker Image
       ▼
┌──────────────┐
│ Docker Build │
│  fastapi-app │
└──────┬───────┘
       │
       │ 4️⃣ Push Image
       ▼
┌──────────────┐
│  Docker Hub  │
│  (Registry)  │
│ Public Image │
└──────┬───────┘
       │
       │ 5️⃣ Refresh kubeconfig
       │    (minikube update-context)
       ▼
┌──────────────────────────┐
│   kubeconfig Updated     │
│  Jenkins → Minikube      │
└────────┬─────────┘
         │
         │ 6️⃣ Deploy to Minikube
         ▼
┌─────────────────────────┐
│    Minikube Cluster     │
│                         │
│  ┌───────────────────┐ │
│  │ Deployment (2 Pods)│ │
│  │ FastAPI Container  │ │
│  └───────────────────┘ │
│            │
│            ▼
│     ┌───────────────┐
│     │ Service       │
│     │ NodePort 32557│
│     └───────────────┘
└─────────────────────────┘
```


## LIVELINESS & READINESS(FIGURE)
```
User / Browser
       |
       v
NodePort Service (32557)
       |
       v
┌────────────────────────────┐
│      Kubernetes Service     │
│  (Load Balancer inside K8s)│
└─────────────┬──────────────┘
              |
              v
     ┌───────────────────────┐
     │          Pods          │
     │                       │
     │  ┌─────────────────┐  │
     │  │   FastAPI Pod 1 │  │
     │  │                 │  │
     │  │ 🔍 Readiness ✔  │◀─ Service sends traffic
     │  │ ❤️ Liveness ✔  │  │
     │  └─────────────────┘  │
     │                       │
     │  ┌─────────────────┐  │
     │  │   FastAPI Pod 2 │  │
     │  │                 │  │
     │  │ 🔍 Readiness ✔  │◀─ Service sends traffic
     │  │ ❤️ Liveness ✔  │  │
     │  └─────────────────┘  │
     │                       │
     │ If Liveness ❌ → Pod Restarted
     │ If Readiness ❌ → Traffic Stopped
     └────────────────────────┘
```


