function description {
  echo "install digital ocean command line tool"
}

function params {
  true
}

function state {
  if command -v doctl &>/dev/null; then
    echo doctl installed
  else
    echo doctl not installed
  fi
}

function desired {
  echo doctl installed
}

function apply {
  brew install doctl 2>&1
}