#! /bin/bash


  BFM_version=bfmv5   #  BFMv2 or bfmv5
  BFM_BRANCH=dev_ogs

 OGSTM_BRANCH=coupler
 VAR3D_BRANCH=WithVb

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b dev_ogs origin/dev_ogs

cd $OGSTM_HOME
git clone git@github.com:gcossarini/BFMCOUPLER.git

# now download MITgcm
