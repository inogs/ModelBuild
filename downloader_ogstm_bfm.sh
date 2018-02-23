#! /bin/bash


  BFM_version=BFMv2   #  BFMv2 or bfmv5
  BFM_RELEASE=branches/new_nutupt

 OGSTM_BRANCH=mfs16_degradation

SVN_USER=svnogs01  # user on https://hpc-forge.cineca.it/
# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

if  [ $BFM_version ==  BFMv2 ] ; then
svn co https://hpc-forge.cineca.it/svn/${BFM_version}/${BFM_RELEASE} -r 119 bfm
else
    # Requirement: to have an account on git server
    git clone git@dev.cmcc.it:bfm
    cd bfm
    git checkout dev
fi


cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/ogstm.git
cd ogstm
git checkout -b $OGSTM_BRANCH origin/$OGSTM_BRANCH

