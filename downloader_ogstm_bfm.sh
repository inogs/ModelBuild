#! /bin/bash


  BFM_version=bfmv5   #  BFMv2 or bfmv5
  BFM_BRANCH=dev_ogs

 MITGCM_TAG=checkpoint66j

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b $BFM_BRANCH origin/$BFM_BRANCH

cd $OGSTM_HOME
git clone git@github.com:gcossarini/BFMCOUPLER.git

git clone https://github.com/MITgcm/MITgcm.git
cd MITgcm
git checkout -b $MITGCM_TAG $MITGCM_TAG
