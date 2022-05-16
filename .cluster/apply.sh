#!/usr/bin/env bash
set -euo pipefail

file_to_apply=${1:-}

export client=imac
export domain=arve.dev
export users=arve,frida,yngvild

function main {
  # 2021.04.25-21:13:50
  logfile=log/apply-$(date +%Y.%m.%d-%H:%M:%S).txt
  touch "$logfile"

  for action in environment/*.sh; do
    if [[ ! $action =~ .*$file_to_apply.* ]]; then
      continue
    fi

    apply_action_if_not_desired_state "$action" 2>&1 | tee -a "$logfile"
  done

  servers=(kube01)

  for server in "${servers[@]}"; do
    export server=$server

    for action in server/*.sh; do
      if [[ ! $action =~ .*$file_to_apply.* ]]; then
        continue
      fi

      apply_action_if_not_desired_state "$action" 2>&1 | tee -a "$logfile"
    done
  done
}

function apply_action_if_not_desired_state {
  action=$1
  source "$action"

  echo "# $action - $(description) #"

  desired_state=$(desired)
  current_state=$(state)

  if [[ $desired_state == "$current_state" ]]; then
    echo "  ✅ desired state"
    echo -e "$current_state" | sed -e 's/^/       /'
    return
  fi

  echo "  ▶️ apply"

  params_output=$(params)
  if [[ $params_output != "" ]]; then
    echo "  params:"
    echo -e "$params_output" | sed -e 's/^/       /'
  fi

  set -x
  if ! apply; then
    set +x
    echo "❌ apply failed"
    exit 1
  fi
  set +x

  after_apply_state=$(state)

  if [[ $desired_state != "$after_apply_state" ]]; then
    echo "❌ apply failed"
    echo "$desired_state != $after_apply_state"
    exit 1
  fi

  echo -e "\n"
}

function errexit() {
  local err=$?
  set +o xtrace
  local code="${1:-1}"
  echo "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]}. '${BASH_COMMAND}' exited with status $err"
  # Print out the stack trace described by $function_stack
  if [ ${#FUNCNAME[@]} -gt 2 ]
  then
    echo "Call tree:"
    for ((i=1;i<${#FUNCNAME[@]}-1;i++))
    do
      echo " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
    done
  fi
  echo "Exiting with status ${code}"
  exit "${code}"
}

# trap ERR to provide an error handler whenever a command exits nonzero
#  this is a more verbose version of set -o errexit
trap 'errexit' ERR
# setting errtrace allows our ERR trap handler to be propagated to functions,
#  expansions and subshells
set -o errtrace

main