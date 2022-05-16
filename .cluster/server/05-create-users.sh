function description {
  echo "create users, output kubeconfig to users/username.kubeconfig"
  mkdir -p users
}

function params {
  echo "server: $server"
  echo "users: $users"
}

function state {
  local usersPipe="\(${users//,/\\|}\)"
  ssh "$server" 'ls /var/lib/k0s/pki/*.crt' | grep "$usersPipe" || true
  ls users/*.kubeconfig || true
}

function desired {
  local users_separated=${users//,/ }
  for user in $users_separated; do
    echo "/var/lib/k0s/pki/$user.crt"
  done

  for user in $users_separated; do
    echo "users/$user.kubeconfig"
  done
}

function apply {
  local users_separated=${users//,/ }
  for user in $users_separated; do
    ssh "$server" k0s kubeconfig create "$user" --groups system:workshop > "users/$user.kubeconfig"
    yq --inplace '.contexts[0].context.namespace = "'"$user"'"' "users/$user.kubeconfig"
    ssh "$server" k0s kubectl create namespace "$user"
  done
}
