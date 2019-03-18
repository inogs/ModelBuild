#! /bin/bash


  BFM_version=bfmv5   #  BFMv2 or bfmv5
  BFM_BRANCH=dev_ogs

 OGSTM_BRANCH=seik
 VAR3D_BRANCH=WithVb

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

git clone git@gitlab.hpc.cineca.it:OGS/seik.git 

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b dev_ogs origin/dev_ogs

cd "$OGSTM_HOME"
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH  origin/$OGSTM_BRANCH

cd "$OGSTM_HOME"
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH origin/$VAR3D_BRANCH
