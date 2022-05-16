function description {
  echo "set up domain"
}

function params {
  echo "domain: $domain"
}

function state {
  doctl compute domain list --format Domain | grep $domain
}

function desired {
  echo $domain
}

function apply {
  if ! doctl compute domain list | grep arve.dev; then
    doctl compute domain create arve.dev
  fi
}