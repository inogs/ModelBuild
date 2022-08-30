#! /bin/bash


  BFM_RELEASE=release_5.3

 OGSTM_BRANCH=release_4.5
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:BFM-Community/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout $BFM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git checkout $OGSTM_BRANCH

