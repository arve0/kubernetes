function description {
  echo "login to digital ocean"
}

function params {
  true
}

function state {
  echo -n "auth: "
  doctl auth list | grep current
}

function desired {
  echo "auth: default (current)"
}

function apply {
  doctl auth init
}