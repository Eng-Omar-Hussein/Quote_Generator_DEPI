# Kubernetes Deployment for Quote Generator

This directory contains Kubernetes manifests to deploy the Quote Generator backend and frontend into a cluster.

## Quick Start

### Prerequisites
- A Kubernetes cluster (minikube recommended)
- kubectl configured to talk to the cluster
- Docker or Podman for building images

### Option 1: Automated Deployment (Recommended)

Use the deployment script from the repository root:

```bash
# From repository root
./deploy-k8s.sh
```

This script will:
- Build both backend and frontend images
- Load them into your local cluster (minikube/kind)
- Deploy all Kubernetes resources
- Wait for deployments to be ready

### Option 2: Manual Deployment

#### Step 1: Start Minikube (if not already running)

```bash
minikube start --driver=podman --container-runtime=containerd
```

**Note**: If you see sudo/permission errors, configure rootless mode:
```bash
minikube config set rootless true
minikube start --driver=podman
```

#### Step 2: Build Images

```bash
# Backend
docker build -f Dockerfile -t localhost/quote-backend:local .

# Frontend  
docker build -f frontend/Dockerfile -t localhost/quote-frontend:local ./frontend
```

#### Step 3: Load Images into Minikube

```bash
# Save images to tar files
docker save localhost/quote-backend:local -o /tmp/quote-backend.tar
docker save localhost/quote-frontend:local -o /tmp/quote-frontend.tar

# Load into minikube
minikube image load /tmp/quote-backend.tar
minikube image load /tmp/quote-frontend.tar

# Cleanup
rm /tmp/quote-backend.tar /tmp/quote-frontend.tar
```

#### Step 4: Deploy to Kubernetes

```bash
kubectl apply -k k8s/
```

#### Step 5: Wait for Pods to be Ready

```bash
kubectl -n quote-generator get pods -w
```

Press Ctrl+C once all pods show `1/1 READY` and `Running` status.

## Accessing the Application

### Port Forward Method

```bash
# Backend API
kubectl -n quote-generator port-forward svc/quote-backend 3000:3000

# Frontend
kubectl -n quote-generator port-forward svc/quote-frontend 8080:80
```

Then visit:
- Frontend: http://localhost:8080
- Backend API: http://localhost:3000

### Minikube Service Method

```bash
minikube service -n quote-generator quote-frontend
```

This will automatically open the frontend in your browser.

## Viewing Logs

```bash
# Backend logs
kubectl -n quote-generator logs -l app=quote-backend -f

# Frontend logs
kubectl -n quote-generator logs -l app=quote-frontend -f
```

## Troubleshooting

### ImagePullBackOff / ErrImageNeverPull

These errors mean the images aren't loaded in the cluster. Re-run the image loading steps above.

### Check Pod Status

```bash
kubectl -n quote-generator describe pod <pod-name>
kubectl -n quote-generator get events --sort-by='.metadata.creationTimestamp'
```

### Restart Deployments

```bash
kubectl -n quote-generator rollout restart deployment/quote-backend
kubectl -n quote-generator rollout restart deployment/quote-frontend
```

## Architecture

- **Namespace**: `quote-generator`
- **Backend**: 2 replicas, SQLite DB on PVC
- **Frontend**: 2 replicas, static Nginx serving React app
- **Ingress**: Routes `/` to frontend, `/api/*` to backend
- **HPA**: Auto-scales backend based on CPU (60% threshold)

## Production Deployment

For production clusters (GKE, EKS, AKS):

1. Push images to a container registry:
```bash
docker tag localhost/quote-backend:local <your-registry>/quote-backend:latest
docker push <your-registry>/quote-backend:latest

docker tag localhost/quote-frontend:local <your-registry>/quote-frontend:latest
docker push <your-registry>/quote-frontend:latest
```

2. Update `backend-deployment.yaml` and `frontend-deployment.yaml`:
   - Change `image:` to your registry path
   - Change `imagePullPolicy: Never` to `imagePullPolicy: IfNotPresent`

3. Deploy:
```bash
kubectl apply -k k8s/
```

## Cleanup

```bash
kubectl delete namespace quote-generator
```
