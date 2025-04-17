#! /bin/bash


 OGSTM_BRANCH=V12C
 BFM_BRANCH=dev_ogs_V12C
 VAR3D_RELEASE=release-4.1
 OASIM_RELEASE=release-1.0

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git switch dev_ogs_V12C

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
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_RELEASE $VAR3D_RELEASE


