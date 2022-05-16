function description {
  echo "droplet ssh config"
}

function params {
  echo "server: $server"
  echo "client: $client"
  echo "domain: $domain"
}

function state {
  if grep "$server" ~/.ssh/config; then
    true
  fi
}

function desired {
  echo "Host $server"
  echo -e "\tHostName $server.$domain"
}

function apply {
  set +x
  i=0
  until timeout 1 bash -c "</dev/tcp/$server.$domain/22"; do
    echo -n "."
    sleep 1;
    i=$((i+1))

    if [[ $i -gt 30 ]]; then
      echo "Unable to open port 22 on $server.$domain"
      exit 1
    fi
  done
  echo ""
  set -x

  echo -e "
Host $server
\tHostName $server.$domain
\tUser root
\tStrictHostKeyChecking no
\tIdentityFile ~/.ssh/$client-key" \
  >> ~/.ssh/config

  ssh "$server" echo SSH OK
}
