#!/usr/bin/env bash
set -xeuo pipefail

function cleanup {
  cleanup/dns.sh kube01 arve.dev
  cleanup/droplet.sh kube01 arve.dev
  cleanup/ssh.sh kube01 arve.dev
}

logfile=log/cleanup-$(date +%Y.%m.%d-%H:%M:%S).txt

cleanup 2>&1 | tee "$logfile"