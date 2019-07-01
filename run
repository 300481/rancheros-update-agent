#!/usr/bin/env bash

CUSTOMER=${1}

[[ $# -eq 0 ]] && { echo "usage: $0 CUSTOMER" ; exit ;}

# templating the secret for the private ssh key
docker run -i --rm \
    -v $(pwd)/manifests:/manifests \
    -v $(pwd)/../3141-customers/${CUSTOMER}/.ssh:/.ssh \
    300481/render:v0.1.3 \
    --var keyfile=/.ssh/id_rsa \
    --in /manifests/secret.yaml.tmpl \
    --out /manifests/secret.yaml

# install the daemonset
docker run -i --rm \
    -v $(pwd)/../3141-customers/${CUSTOMER}:/data \
    -v $(pwd)/manifests:/manifests \
    300481/kubectl:v1.14.3 \
    apply -f /manifests/*.yaml