#!/bin/bash

set -ex

CRD_OPTIONS="$1"
PKGS="$2"
GENS="$3"
IFS=" " read -r -a PKGS <<< "${PKGS}"
export GOFLAGS=-mod=readonly

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd "${KUBE_ROOT}" || exit

for PKG in "${PKGS[@]}"; do
  if grep -qw "deepcopy" <<<"${GENS}"; then
    echo "Generating deepcopy for ${PKG}"
    controller-gen object:headerFile=./hack/boilerplate.go.txt paths=./staging/src/kubesphere.io/api/"${PKG}"
  else
    echo "Generating manifests for ${PKG}"
    controller-gen object:headerFile=./hack/boilerplate.go.txt paths=./staging/src/kubesphere.io/api/"${PKG}" rbac:roleName=controller-perms "${CRD_OPTIONS}" output:crd:artifacts:config=config/ks-core/charts/ks-crds/crds
  fi
done
