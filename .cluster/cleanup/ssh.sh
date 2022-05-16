#!/usr/bin/env bash

name=$1
domain=$2

sed -i '' -e "/Host $name/,+4d" ~/.ssh/config
sed -i '' -e "/^$name.$domain/d" ~/.ssh/known_hosts
