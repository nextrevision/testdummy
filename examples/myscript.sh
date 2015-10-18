#!/bin/bash

_usage() {
  echo "usage: $0 [string]"
  echo
  echo "outputs the specified string"
  echo
}

_error() {
  echo "ERROR: ${1}"
  exit 1
}

_main() {
  [ -z "${1}" ] && _error "must specify a string"
  echo "$@"
  return 0
}

# allow for sourcing
if [[ $(basename ${0//-/}) == "myscript.sh" ]]; then
  _main "$@"
fi
