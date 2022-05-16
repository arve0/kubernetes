#!/usr/bin/env bash

server=$1
domain=$2

doctl compute droplet delete --force "$server.$domain"
