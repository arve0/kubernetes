#!/usr/bin/env bash

name=$1
domain=$2

id=$(doctl compute domain records list "$domain" --output json \
  | jq --raw-output ".[] | select(.name == \"$name\") | .id")


doctl compute domain records delete --force "$domain" "$id"