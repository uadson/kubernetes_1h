#!/bin/bash

echo "🎯 Setting up Django Kubernetes Stack..."

# Verificar se cluster existe
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ No Kubernetes cluster found!"
    echo "Creating kind cluster..."
    
    # Criar cluster kind se não existir
    cat > kind-config.yml << EOKIND
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
- role: worker
- role: worker
EOKIND

    kind create cluster --name django-cluster --config kind-config.yml
fi

echo "🐳 Building and loading Django image..."
# Construir imagem da aplicação atual
docker build -t django_k8s:v1.0 ./app/

# Carregar no kind
kind load docker-image django_k8s:v1.0 --name django-cluster

echo "🚀 Deploying Django + PostgreSQL + Nginx Stack..."

# Aplicar secrets e configs primeiro
echo "📝 Applying configs and secrets..."
kubectl apply -f manifests/postgres-secret.yml
kubectl apply -f manifests/django-config.yml
kubectl apply -f manifests/nginx-config.yml

# Aplicar PVs e PVCs
echo "💾 Setting up storage..."
kubectl apply -f manifests/postgres-pv.yml
kubectl apply -f manifests/postgres-pvc.yml
kubectl apply -f manifests/media-pvc.yml

# Deploy PostgreSQL
echo "🐘 Deploying PostgreSQL..."
kubectl apply -f manifests/postgres-statefulset.yml
kubectl apply -f manifests/postgres-service.yml

# Aguardar PostgreSQL estar pronto
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

# Deploy Django
echo "🐍 Deploying Django..."
kubectl apply -f manifests/django-deployment.yml
kubectl apply -f manifests/django-service.yml

# Aguardar Django estar pronto
echo "⏳ Waiting for Django to be ready..."
kubectl wait --for=condition=ready pod -l app=django --timeout=300s

# Deploy Nginx
echo "🌐 Deploying Nginx..."
kubectl apply -f manifests/nginx-deployment.yml
kubectl apply -f manifests/nginx-service.yml

echo "✅ Deployment completed!"
echo ""
echo "📊 Checking status..."
kubectl get pods
echo ""
kubectl get services
echo ""
echo "🌐 Access the application:"
echo "   Direct: http://localhost:8080 (if using kind with port mapping)"
echo "   Port-forward: kubectl port-forward svc/nginx-service 8080:80"