#!/bin/bash

# Quote Generator Kubernetes Deployment Script
# This script builds images, loads them into minikube/kind, and deploys the application

set -e

echo "🚀 Quote Generator - Kubernetes Deployment Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Detect cluster type
if kubectl config current-context | grep -q "minikube"; then
    CLUSTER_TYPE="minikube"
    echo -e "${GREEN}✅ Detected minikube cluster${NC}"
elif kubectl config current-context | grep -q "kind"; then
    CLUSTER_TYPE="kind"
    echo -e "${GREEN}✅ Detected kind cluster${NC}"
else
    CLUSTER_TYPE="other"
    echo -e "${YELLOW}⚠️  Unknown cluster type. Will use registry images.${NC}"
fi

# Build images
echo ""
echo "📦 Building Docker images..."
docker build -f Dockerfile -t localhost/quote-backend:local .
docker build -f frontend/Dockerfile -t localhost/quote-frontend:local ./frontend
echo -e "${GREEN}✅ Images built successfully${NC}"

# Load images into cluster
if [ "$CLUSTER_TYPE" = "minikube" ]; then
    echo ""
    echo "📥 Loading images into minikube..."
    
    # Save images to tar
    docker save localhost/quote-backend:local -o /tmp/quote-backend.tar
    docker save localhost/quote-frontend:local -o /tmp/quote-frontend.tar
    
    # Load into minikube
    minikube image load /tmp/quote-backend.tar
    minikube image load /tmp/quote-frontend.tar
    
    # Cleanup
    rm /tmp/quote-backend.tar /tmp/quote-frontend.tar
    echo -e "${GREEN}✅ Images loaded into minikube${NC}"
    
elif [ "$CLUSTER_TYPE" = "kind" ]; then
    echo ""
    echo "📥 Loading images into kind..."
    kind load docker-image localhost/quote-backend:local
    kind load docker-image localhost/quote-frontend:local
    echo -e "${GREEN}✅ Images loaded into kind${NC}"
    
else
    echo -e "${YELLOW}⚠️  For non-local clusters, please push images to a registry and update k8s manifests${NC}"
    echo "Example:"
    echo "  docker tag localhost/quote-backend:local <your-registry>/quote-backend:latest"
    echo "  docker push <your-registry>/quote-backend:latest"
    exit 1
fi

# Deploy to Kubernetes
echo ""
echo "🚀 Deploying to Kubernetes..."
kubectl apply -k k8s/

echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl -n quote-generator wait --for=condition=available --timeout=300s deployment/quote-backend
kubectl -n quote-generator wait --for=condition=available --timeout=300s deployment/quote-frontend

echo ""
echo -e "${GREEN}✅ Deployment successful!${NC}"
echo ""
echo "📊 Deployment status:"
kubectl -n quote-generator get all

echo ""
echo "🔍 To access the application:"
echo "  Backend:  kubectl -n quote-generator port-forward svc/quote-backend 3000:3000"
echo "  Frontend: kubectl -n quote-generator port-forward svc/quote-frontend 8080:80"
echo ""
echo "  Or use minikube service:"
echo "  minikube service -n quote-generator quote-frontend"
echo ""
echo "📝 To view logs:"
echo "  kubectl -n quote-generator logs -l app=quote-backend -f"
echo "  kubectl -n quote-generator logs -l app=quote-frontend -f"
