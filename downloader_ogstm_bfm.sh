#! /bin/bash


  BFM_version=BFMv2   #  BFMv2 or bfmv5
  BFM_RELEASE=branches/new_nutupt

 OGSTM_BRANCH=un24_omp_optimized
 VAR3D_BRANCH=release-3.0

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

svn co https://hpc-forge.cineca.it/svn/${BFM_version}/${BFM_RELEASE} -r 118 bfm

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH origin/$OGSTM_BRANCH
git checkout c67940a4a842d579116ca27a369beb85d38b93ec

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH $VAR3D_BRANCH
