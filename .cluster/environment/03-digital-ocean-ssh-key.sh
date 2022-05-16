function description {
  echo "set up ssh keys"
}

function params {
  echo "client: $client"
}

function state {
  echo -n "ssh key digital ocean: "
  doctl compute ssh-key list --format Name | grep $client

  echo -n "local ssh key: "
  ls ~/.ssh/$client-key
}

function desired {
  echo -n "ssh key digital ocean: "
  echo $client

  echo -n "local ssh key: "
  echo $HOME/.ssh/$client-key
}

function apply {
  if [[ ! -f target/$client-key ]]; then
    ssh-keygen -t ecdsa -C $client -P '' -f target/$client-key
  fi
  if [[ ! -f ~/.ssh/$client-key ]]; then
    cp target/$client-key ~/.ssh/$client-key
  fi
  if ! doctl compute ssh-key list | grep $client; then
    doctl compute ssh-key create $client --public-key "$(cat target/$client-key.pub)"
  fi
}