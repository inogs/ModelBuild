#! /usr/bin/env bash

# General settings
ROOT="$(dirname -- "${BASH_SOURCE[0]}" | xargs realpath)"
GIT_CLONE_OPTIONS="--single-branch"

# BFM settings

BFM_PATH=bfm
BFM_VERSION=v5

# BFMv2 settings
# User on https://hpc-forge.cineca.it/
BFMv2_USER=svnogs01
BFMv2_REPO=https://hpc-forge.cineca.it/svn/BFMv2
BFMv2_RELEASE=branches/pl_mod 

# BFMv5 settings
# Requirement: to have an account on git server
BFMv5_REPO=git@github.com:BFM-Community/BiogeochemicalFluxModel.git
BFMv5_BRANCH=esiwace_m100_experimental

# OGSTM settings
OGSTM_REPO=git@github.com:stefanocampanella/ogstm.git
OGSTM_BRANCH=esiwace_m100_experimental
OGSTM_PATH=ogstm

# VAR3D settings
VAR3D_REPO=git@gitlab.hpc.cineca.it:OGS/3DVar.git
VAR3D_BRANCH=Multivariate
VAR3D_PATH=3DVar

cd -- "${ROOT}" || exit

echo -e "\n==== Downloading BFM ===="
if  [[ "${BFM_VERSION}" ==  v2 ]]; then
  svn co --username "${BFMv2_USER}" "${BFMv2_REPO}/${BFMv2_RELEASE}" "${BFM_PATH}"
elif [[ "${BFM_VERSION}" == v5 ]]; then
  git clone "${GIT_CLONE_OPTIONS}" -b "${BFMv5_BRANCH}" "${BFMv5_REPO}" "${BFM_PATH}" 
else
  echo "BFM version not recognized or supported."
fi || echo "An error occurred while cloning BFM. Skipping."

echo -e "\n==== Downloading OGSTM ===="
git clone "${GIT_CLONE_OPTIONS}" -b "${OGSTM_BRANCH}" "${OGSTM_REPO}" "${OGSTM_PATH}" || echo "An error occurred while cloning OGSTM. Skipping"

echo -e "\n==== Downloading 3DVar ===="
git clone "${GIT_CLONE_OPTIONS}" -b "${VAR3D_BRANCH}" "${VAR3D_REPO}" "${VAR3D_PATH}" || echo "An error occurred while cloning 3DVar. Skipping"
