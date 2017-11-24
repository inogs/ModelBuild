#! /bin/bash


  BFM_version=BFMv2   #  BFMv2 or bfmv5
  BFM_RELEASE=tags/release-2.1

 OGSTM_BRANCH=release-2.3
 VAR3D_BRANCH=most_optimized

SVN_USER=gbolzon  # user on https://hpc-forge.cineca.it/
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
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH $OGSTM_BRANCH

cd $OGSTM_HOME
svn co https://hpc-forge.cineca.it/svn/opa_rea/tags/DA_3d_var_release-2.1/ 3d_var
