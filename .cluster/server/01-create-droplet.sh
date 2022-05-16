size=s-2vcpu-4gb # doctl compute size list
image=ubuntu-22-04-x64 # doctl compute image list-distribution

function description {
  echo "create droplet"
}

function params {
  echo "server: $server"
  echo "client: $client"
  echo "domain: $domain"
}

function state {
  doctl compute droplet list --output json \
    | jq --raw-output ".[] | select(.name == \"$server.$domain\") | .name + \" \" + .size.slug"
}

function desired {
  echo "$server.$domain $size"
}

function apply {
  ssh_key=$(doctl compute ssh-key list | grep "$client" | awk '{ print $1 }' | tr -d '\n')
  region=$(
    doctl compute region list \
    | grep Amsterdam \
    | grep true \
    | cut -f 1 -d " " \
    | tr -d "\n"
  )

  doctl compute droplet create \
    --size $size \
    --image $image \
    --ssh-keys "$ssh_key" \
    --region "$region" \
    --wait \
    "$server.$domain"
}
