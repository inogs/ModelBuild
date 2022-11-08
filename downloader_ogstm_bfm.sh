#! /bin/bash


 OGSTM_RELEASE=release-4.6
 BFM_RELEASE=ogs_release-5.2.0
 VAR3D_RELEASE=release-4.1
 OASIM_RELEASE=release-1.0


# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:BFM-Community/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout -b $BFM_RELEASE $BFM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git checkout -b $OGSTM_RELEASE $OGSTM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/Forward_Adjoint.git
cd Forward_Adjoint
git checkout -b $OASIM_RELEASE $OASIM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:pogmat/OASIM-experiments.git OASIM
cd OASIM
git checkout -b $OASIM_RELEASE $OASIM_RELEASE

cd $OGSTM_HOME
git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
cd 3DVar
git checkout -b $VAR3D_RELEASE $VAR3D_RELEASE

