#! /bin/bash


 OGSTM_BRANCH=28-v13c-quid
 BFM_RELEASE=neccton
 VAR3D_RELEASE=release-4.2 # todo
 OASIM_RELEASE=release-1.0

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout $BFM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git switch $OGSTM_BRANCH

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/Forward_Adjoint.git
cd Forward_Adjoint
git checkout -b $OASIM_RELEASE $OASIM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/OASIM_ATM.git OASIM
cd OASIM
git checkout -b $OASIM_RELEASE $OASIM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:inogs/3dVarBio.git 3DVar
cd 3DVar
#git checkout -b $VAR3D_RELEASE $VAR3D_RELEASE
git switch MultiVariate


