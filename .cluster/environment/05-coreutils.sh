function description {
  echo "install 'timeout'"
}

function params {
  true
}

function state {
  if which timeout; then
    true
  fi
}

function desired {
  echo /usr/local/bin/timeout
}

function apply {
  brew install coreutils
}