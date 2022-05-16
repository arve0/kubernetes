function description {
  echo "create admin user and save to ~/.kube/config"
  mkdir -p users
}

function params {
  echo "server: $server"
}

function state {
  ssh "$server" ls /var/lib/k0s/pki/remote-admin.crt || true
  kubectl get service/kubernetes -n default -o name || true
}

function desired {
  echo /var/lib/k0s/pki/remote-admin.crt
  echo service/kubernetes
}

function apply {
  if [[ -f ~/.kube/config ]]; then
    mv ~/.kube/config ~/.kube/config.backup
  fi
  ssh "$server" k0s kubeconfig create remote-admin --groups system:master > ~/.kube/config
  ssh "$server" k0s kubectl create clusterrolebinding remote-admin --clusterrole=admin --user=remote-admin
}
