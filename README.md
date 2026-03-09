# MBAUspTCC


terraform plan -var-file="secrets.tfvars"

# Aplicar os templates
terraform apply -parallelism=6

# Atualizar as informações do Cluster para máquina local
aws eks update-kubeconfig --region us-east-1 --name tcc-mba-usp-eks

# Observar o AWS-AUTH
kubectl describe configmap aws-auth -n kube-system

# Alterar o AWS-AUTH
kubectl edit configmap aws-auth -n kube-system

# Obter os namespaces
kubectl get ns

# Verificar os nodes
kubectl get nodes --all-namespaces
kubectl top nodes --all-namespaces

kubectl get pods -n <nome-do-namespace>

# Verificar os pods
kubectl get pods --all-namespaces
kubectl top pods --all-namespaces

kubectl get pods -n <nome-do-namespace>

# Descrever o Node Group
aws eks describe-nodegroup --cluster-name tcc-mba-usp-eks --nodegroup-name worker-nodes --region us-east-1

# Descrever o Deployment
kubectl describe deployment sqs-worker-low-load
kubectl describe rs <nome-do-replicaset>
kubectl describe pods <nome-do-pod>

# Obter Logs
kubectl logs <nome-do-pod>

# Aplicar
kubectl apply -f .\worker-deployment.yaml

# Deletar
kubectl delete -f .\worker-deployment.yaml
kubectl delete pod <nome-do-pod>
