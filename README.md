# MBAUspTCC


terraform plan -var-file="secrets.tfvars"

# Aplicar os templates
terraform apply -parallelism=6

# Atualizar as informações do Cluster para máquina local
aws eks update-kubeconfig --region us-east-1 --name tcc-mba-usp-eks

# Verificar os nodes
kubectl top nodes

# Verificar os pods
kubectl top pods

# Descrever o Node Group
aws eks describe-nodegroup --cluster-name tcc-mba-usp-eks --nodegroup-name worker-nodes --region us-east-1
