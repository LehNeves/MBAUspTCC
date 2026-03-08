# MBAUspTCC


terraform plan -var-file="secrets.tfvars"

# Atualizar as informações do Cluster para máquina local
aws eks update-kubeconfig --region us-east-1 --name NOME_DO_CLUSTER