#! /bin/bash


  BFM_version=bfmv5   #  BFMv2 or bfmv5

 OGSTM_BRANCH=Multivariate
 VAR3D_BRANCH=Multivariate

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

if  [ $BFM_version ==  BFMv2 ] ; then

svn co --username $SVN_USER https://hpc-forge.cineca.it/svn/${BFM_version}/${BFM_RELEASE} bfm

else
    # Requirement: to have an account on git server
    git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
    cd bfm
    git checkout -b dev_ogs origin/dev_ogs
fi

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH origin/$OGSTM_BRANCH

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH origin/$VAR3D_BRANCH
