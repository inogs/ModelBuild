#! /usr/bin/env bash

# General settings
ROOT="$(dirname -- "${BASH_SOURCE[0]}")"

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
BFMv5_REPO=git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git
BFMv5_BRANCH=release_5.3

# OGSTM settings
OGSTM_REPO=git@github.com:inogs/ogstm.git
OGSTM_BRANCH=release_4.5
OGSTM_PATH=ogstm

# VAR3D settings
VAR3D_REPO=git@gitlab.hpc.cineca.it:OGS/3DVar.git
VAR3D_BRANCH=Multivariate
VAR3D_PATH=3DVar

cd -- "${ROOT}"

echo -e "\n==== Downloading BFM ===="
if  [[ "${BFM_VERSION}" ==  v2 ]]; then
  svn co --username "${BFMv2_USER}" "${BFMv2_REPO}/${BFMv2_RELEASE}" "${BFM_PATH}"
elif [[ "${BFM_VERSION}" == v5 ]]; then
  git clone -b "${BFMv5_BRANCH}" "${BFMv5_REPO}" "${BFM_PATH}" 
else
  echo "BFM version not recognized or supported."
fi || echo "An error occurred while cloning BFM. Skipping."

echo -e "\n==== Downloading OGSTM ===="
git clone -b "${OGSTM_BRANCH}" "${OGSTM_REPO}" "${OGSTM_PATH}" || echo "An error occurred while cloning OGSTM. Skipping"

echo -e "\n==== Downloading 3DVar ===="
git clone -b "${VAR3D_BRANCH}" "${VAR3D_REPO}" "${VAR3D_PATH}" || echo "An error occurred while cloning 3DVar. Skipping"
