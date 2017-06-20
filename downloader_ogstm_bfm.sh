#! /bin/bash


  BFM_version=BFMv2   #  BFMv2 or bfmv5
  BFM_RELEASE=branches/new_nutupt

 OGSTM_BRANCH=un24_omp_optimized
 VAR3D_BRANCH=most_optimized

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

if  [ $BFM_version ==  BFMv2 ] ; then

svn co --username $SVN_USER https://hpc-forge.cineca.it/svn/${BFM_version}/${BFM_RELEASE} bfm

else
    # Requirement: to have an account on git server
    git clone git@dev.cmcc.it:bfm
    cd bfm
    git checkout dev
fi

cd $OGSTM_HOME
#svn co --username $SVN_USER https://hpc-forge.cineca.it/svn/ogstm/${OGSTM_RELEASE} ogstm
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH origin/$OGSTM_BRANCH

cd $OGSTM_HOME
# svn co https://hpc-forge.cineca.it/svn/opa_rea/DA/src/3d_var 
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_BRANCH origin/$VAR3D_BRANCH
