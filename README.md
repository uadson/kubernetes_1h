# kubernetes_1h# 🚀 Bootcamp Kubernetes - 1 Hora Intensiva
## Do Básico ao Intermediário com Exemplos Práticos

---

## 📋 **Pré-requisitos e Setup Inicial** (10 minutos)

### 1. Instalar Docker no WSL2 ou Linux (Ubuntu 22.0*)
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

apt-cache policy docker-ce

sudo apt install docker-ce

sudo systemctl status docker

# Adicionar usuário ao grupo docker
sudo usermod -aG docker ${USER}

# Reiniciar sessão ou executar:
newgrp docker

# Testar Docker
docker --version
docker run hello-world
```

### 2. Instalar kubectl
```bash
# Baixar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Tornar executável e mover para PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verificar instalação
kubectl version --client
```

### 3. Instalar kind (Kubernetes in Docker)
```bash
# Baixar kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verificar instalação
kind version
```

### 4. Criar cluster local
```bash
# Criar cluster
kind create cluster --name k8s-bootcamp

# Verificar contexto
kubectl cluster-info --context kind-k8s-bootcamp

# Ver nós do cluster
kubectl get nodes
```

---

## 🏗️ **Módulo 1: Conceitos Fundamentais** (10 minutos)

### Arquitetura Kubernetes
- **Master Node**: API Server, etcd, Scheduler, Controller Manager
- **Worker Nodes**: kubelet, kube-proxy, Container Runtime
- **Objetos**: Pods, Services, Deployments, ConfigMaps, Secrets

### Comandos Básicos de Exploração
```bash
# Verificar status do cluster
kubectl get all

# Ver namespaces
kubectl get namespaces

# Informações detalhadas do cluster
kubectl cluster-info

# Ver eventos do cluster
kubectl get events

# Ajuda para comandos
kubectl help
kubectl get --help
```

---

## 🐳 **Módulo 2: Pods - A Unidade Básica** (10 minutos)

### Criar e Gerenciar Pods

```bash
# Criar pod simples
kubectl run nginx-pod --image=nginx --port=80

# Ver pods
kubectl get pods
kubectl get pods -o wide

# Descrever pod (informações detalhadas)
kubectl describe pod nginx-pod

# Ver logs do pod
kubectl logs nginx-pod

# Executar comando dentro do pod
kubectl exec -it nginx-pod -- /bin/bash

# Dentro do container: curl localhost

# Sair do container
exit

# Port forward para acessar o pod localmente
kubectl port-forward nginx-pod 8080:80 &
# Testar: curl localhost:8080

# Parar port-forward
pkill -f "kubectl port-forward"
```

### Pod com YAML
```bash
# Criar arquivo pod.yaml
cat > pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
  labels:
    app: my-app
spec:
  containers:
  - name: app-container
    image: nginx:alpine
    ports:
    - containerPort: 80
    env:
    - name: ENV_VAR
      value: "production"
EOF

# Aplicar o YAML
kubectl apply -f pod.yaml

# Ver pods
kubectl get pods

# Deletar pod
kubectl delete pod my-app-pod
```

---

## 🚀 **Módulo 3: Deployments - Gerenciamento de Aplicações** (10 minutos)

### Criar Deployment
```bash
# Criar deployment
kubectl create deployment web-app --image=nginx:alpine --replicas=3

# Ver deployments
kubectl get deployments
kubectl get pods

# Escalar deployment
kubectl scale deployment web-app --replicas=5
kubectl get pods

# Ver histórico de rollout
kubectl rollout history deployment web-app

# Atualizar imagem
kubectl set image deployment/web-app nginx=nginx:1.21
kubectl rollout status deployment/web-app

# Fazer rollback
kubectl rollout undo deployment/web-app
```

### Deployment com YAML
```bash
# Criar deployment.yaml
cat > deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-container
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF

# Aplicar deployment
kubectl apply -f deployment.yaml

# Monitorar pods
kubectl get pods -l app=web-app --watch
# Pressione Ctrl+C para parar
```

---

## 🌐 **Módulo 4: Services - Exposição de Aplicações** (10 minutos)

### Tipos de Services

```bash
# Service ClusterIP (padrão - acesso interno)
kubectl expose deployment web-deployment --port=80 --target-port=80 --name=web-service

# Ver services
kubectl get services
kubectl get svc

# Testar service internamente
kubectl run test-pod --image=curlimages/curl -it --rm -- curl web-service

# Service NodePort (acesso externo)
kubectl expose deployment web-deployment --type=NodePort --port=80 --name=web-nodeport

# Ver NodePort atribuído
kubectl get svc web-nodeport

# Service LoadBalancer (em kind, fica pending)
kubectl expose deployment web-deployment --type=LoadBalancer --port=80 --name=web-loadbalancer
kubectl get svc web-loadbalancer
```

### Service com YAML
```bash
# Criar service.yaml
cat > service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

# Aplicar service
kubectl apply -f service.yaml

# Testar acesso (no kind, use port-forward)
kubectl port-forward svc/web-svc 8080:80 &
curl localhost:8080
pkill -f "kubectl port-forward"
```

---

## 🔧 **Módulo 5: ConfigMaps e Secrets** (5 minutos)

### ConfigMaps
```bash
# Criar ConfigMap literal
kubectl create configmap app-config --from-literal=database_url=mongodb://localhost:27017 --from-literal=debug=true

# Ver ConfigMap
kubectl get configmaps
kubectl describe configmap app-config

# ConfigMap de arquivo
echo "log_level=info" > app.properties
kubectl create configmap app-properties --from-file=app.properties

# Verificar se foi criado
kubectl get configmap app-config

# Usar ConfigMap em Pod
cat > pod-with-config.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx:alpine
    envFrom:
    - configMapRef:
        name: app-config
EOF

kubectl apply -f pod-with-config.yaml
kubectl exec app-pod -- env | grep database_url
```

### Secrets
```bash
# Criar Secret
kubectl create secret generic app-secret --from-literal=username=admin --from-literal=password=secret123

# Ver Secrets (valores são base64)
kubectl get secrets
kubectl describe secret app-secret

# Ver valores decodificados
kubectl get secret app-secret -o jsonpath='{.data.username}' | base64 -d
echo
```

---

## 📊 **Módulo 6: Conceitos Intermediários** (5 minutos)

### Namespaces
```bash
# Criar namespace
kubectl create namespace development

# Ver recursos em namespace específico
kubectl get pods -n development

# Criar pod em namespace
kubectl run dev-pod --image=nginx -n development

# Ver pods em todos os namespaces
kubectl get pods --all-namespaces
```

### Labels e Seletores
```bash
# Adicionar labels
kubectl label pods nginx-pod environment=production
kubectl label pods nginx-pod version=v1.0

# Ver pods com labels
kubectl get pods --show-labels

# Filtrar por labels
kubectl get pods -l environment=production
kubectl get pods -l environment=production,version=v1.0

# Remover pods por seletor
kubectl delete pods -l app=web-app
```

### Comandos Úteis de Debug
```bash
# Top de recursos (requer metrics-server)
# kubectl top nodes
# kubectl top pods

# Events ordenados por tempo
kubectl get events --sort-by=.metadata.creationTimestamp

# Descrever todos os recursos
kubectl describe all

# Ver YAML de recursos existentes
kubectl get deployment web-deployment -o yaml

# Dry run (testar sem aplicar)
kubectl create deployment test-deploy --image=nginx --dry-run=client -o yaml
```

---

## 🧹 **Limpeza e Finalização** (Tempo restante)

### Comandos de Limpeza
```bash
# Deletar recursos específicos
kubectl delete deployment --all
kubectl delete service --all
kubectl delete pod --all
kubectl delete configmap --all
kubectl delete secret app-secret

# Deletar namespace (deleta tudo dentro)
kubectl delete namespace development

# Ver recursos restantes
kubectl get all

# Deletar cluster kind
kind delete cluster --name k8s-bootcamp
```

---

## 📚 **Resumo de Comandos Essenciais**

### Comandos Básicos
```bash
kubectl get <resource>           # Listar recursos
kubectl describe <resource>      # Detalhes do recurso
kubectl create <resource>        # Criar recurso
kubectl apply -f <file>          # Aplicar YAML
kubectl delete <resource>        # Deletar recurso
kubectl logs <pod>               # Ver logs
kubectl exec -it <pod> -- <cmd>  # Executar comando
kubectl port-forward <pod> <port> # Encaminhar porta
```

### Recursos Principais
- **Pod**: Menor unidade executável
- **Deployment**: Gerencia Pods e ReplicaSets
- **Service**: Expõe aplicações na rede
- **ConfigMap**: Configurações não-sensíveis
- **Secret**: Dados sensíveis
- **Namespace**: Isolamento lógico

---

## 🎯 **Próximos Passos**

1. **Praticar**: Repetir os exercícios variando parâmetros
2. **Explorar**: Volumes, Ingress, RBAC, NetworkPolicies
3. **Ferramentas**: Helm, Kustomize, kubectl plugins
4. **Produção**: EKS, GKE, AKS ou clusters próprios
5. **Monitoramento**: Prometheus, Grafana, Jaeger

---

## 💡 **Dicas Finais**

- Use `kubectl explain <resource>` para documentação
- Aliases úteis: `alias k=kubectl`
- Sempre use namespaces em produção
- Monitore recursos com limits e requests
- Mantenha YAMLs em controle de versão
- Pratique troubleshooting com `describe` e `logs`

**Parabéns! 🎉 Você completou o bootcamp intensivo de Kubernetes!**