#! /bin/bash


  BFM_RELEASE=ogs_release-5.1.0

 OGSTM_RELEASE=release-4.4
 VAR3D_BRANCH=release-4.0

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

git clone git@github.com:BFM-Community/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b $BFM_RELEASE $BFM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git checkout -b $OGSTM_RELEASE $OGSTM_RELEASE

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH $VAR3D_BRANCH

