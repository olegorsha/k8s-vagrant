#/bin/bash

set -e

[ -d .ssh ] || {
  mkdir .ssh
}

[ -f .ssh/id_rsa ] || {
  ssh-keygen -t rsa -f .ssh/id_rsa -q -N ''
}
