#! /bin/bash

OGSTM_BRANCH=neccton
BFM_BRANCH=neccton
VAR3D_RELEASE=release-4.1
OASIM_RELEASE=release-1.0

# ----------- BFM library ---------------------

#MYCODE=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/MYCODE

OGSTM_HOME=$PWD/CODE
mkdir -p $OGSTM_HOME

cd $OGSTM_HOME

# Requirement: to have an account on git server
git clone git@github.com:BFM-Community/BiogeochemicalFluxModel.git bfm

cd bfm
git checkout $BFM_BRANCH

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git ogstm

cd ogstm
git checkout $OGSTM_BRANCH
# TO FIX IN OGSTM AND COMMIT!

#rsync -aP $MYCODE/GeneralCmake.cmake ./            #these are for gdept1d
#rsync -aP $MYCODE/forcing_phys.f90 ./src/IO/       #ditto

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/Forward_Adjoint.git
cd Forward_Adjoint
git checkout -b $OASIM_RELEASE $OASIM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/OASIM_ATM.git OASIM
cd OASIM
#git checkout -b $OASIM_RELEASE $OASIM_RELEASE

# this should not be necessary (data assimilation)
#cd $OGSTM_HOME
#git clone git@gitlab.hpc.cineca.it:OGS/3DVar.git
#cd 3DVar
#git checkout -b $VAR3D_RELEASE $VAR3D_RELEASE


