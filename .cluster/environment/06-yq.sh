function description {
  echo "install 'yq'"
}

function params {
  true
}

function state {
  if which yq; then
    true
  fi
}

function desired {
  echo /usr/local/bin/yq
}

function apply {
  brew install yq
}