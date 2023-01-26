#! /bin/bash


  BFM_BRANCH=dev_ogs_Hg

 OGSTM_BRANCH=bioptimod_Hg

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:BFM-Community/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout $BFM_BRANCH

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git checkout $OGSTM_BRANCH


