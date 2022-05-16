server_ip=$(doctl compute droplet get --no-header --format PublicIPv4 "$server.$domain" | tr -d '\n')

function description {
  echo "add dns entry for droplet"
}

function params {
  echo "server: $server"
  echo "domain: $domain"
  echo "server_ip (derived): $server_ip"
}

function state {
  doctl compute domain records list "$domain" --output json \
    | jq --raw-output ".[] | select(.name == \"$server\") | .name + \" \" + .data"
}

function desired {
  echo "$server $server_ip"
}

function apply {
  doctl compute domain records create "$domain" \
    --record-name "$server" \
    --record-type A \
    --record-ttl 300 \
    --record-data "$server_ip"

  echo "Waiting for DNS to resolve"
  set +x
  until dig +short "$server.$domain" | grep "$server_ip"; do
    echo -n "."
    sleep 1
  done
  echo ""
}
