#! /bin/bash


 OGSTM_BRANCH=bioptimod_merge
 VAR3D_BRANCH=Multivariate

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b dev_ogs_bioptimod origin/dev_ogs_bioptimod

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git checkout $OGSTM_BRANCH

exit 0

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH origin/$VAR3D_BRANCH
