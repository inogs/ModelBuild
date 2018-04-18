#! /bin/bash


  BFM_version=BFMv2   #  BFMv2 or bfmv5
  BFM_RELEASE=tags/release-3.1/

 OGSTM_BRANCH=release-3.2
 VAR3D_BRANCH=release-3.2

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

svn co https://hpc-forge.cineca.it/svn/${BFM_version}/${BFM_RELEASE} -r 120 bfm

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH $OGSTM_BRANCH

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH $VAR3D_BRANCH

