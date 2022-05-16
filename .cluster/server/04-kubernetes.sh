function description {
  echo "install k0s"
}

function params {
  echo "server: $server"
}

function state {
  if ! ssh "$server" command -v k0s; then
    return
  fi
  ssh "$server" k0s status | grep "Role"
}

function desired {
  echo "/usr/local/bin/k0s"
  echo "Role: controller"
}

function apply {
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
  ssh "$server" << EOF
    curl -sSLf https://get.k0s.sh | sh
    k0s install controller --single
    systemctl start k0scontroller
    systemctl enable k0scontroller
    sleep 1
    systemctl status k0scontroller
    k0s status
EOF
}
