#! /bin/bash


  BFM_version=bfmv5  #  BFMv2 or bfmv5
 OGSTM_BRANCH=IscraB_Medsea

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b dev_ogs origin/dev_ogs


cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH origin/$OGSTM_BRANCH
