function description {
  echo "authorization for workshop users"
  mkdir -p users
}

function params {
  echo "server: $server"
  echo "users: $users"
}

function state {
  ssh "$server" k0s kubectl get clusterrole workshop-edit -o name 2>/dev/null || true
  ssh "$server" k0s kubectl get rolebinding -A -o json \
    | jq --raw-output '.items[] | .metadata.name + "/" + .metadata.namespace' \
    | grep workshop || true
}

function desired {
  echo "clusterrole.rbac.authorization.k8s.io/workshop-edit"

  local users_separated=${users//,/ }
  for user in $users_separated; do
    echo "workshop-edit/$user"
    echo "workshop-view/$user"
  done
}

function apply {
  local users_separated=${users//,/ }
  local folder=$(dirname "${BASH_SOURCE[0]}")

  ssh "$server" k0s kubectl apply -f- < "$folder/rbac-common.yaml"

  for user in $users_separated; do
    user=$user envsubst < "$folder/rbac-user.yaml" \
      | ssh "$server" k0s kubectl apply -f-
  done
}
