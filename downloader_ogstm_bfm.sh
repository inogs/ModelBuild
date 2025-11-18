#! /bin/bash


 OGSTM_BRANCH=17-integration-with-fabm
 OASIM_RELEASE=release-1.0

# ----------- BFM library ---------------------

OGSTM_HOME=$PWD

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout neccton

cd $OGSTM_HOME
git clone git@github.com:inogs/ogstm.git
cd ogstm
git checkout $OGSTM_BRANCH

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/Forward_Adjoint.git
cd Forward_Adjoint
git checkout -b $OASIM_RELEASE $OASIM_RELEASE

cd $OGSTM_HOME
git clone git@github.com:BIOPTIMOD/OASIM_ATM.git OASIM



# ----------- FABM library ---------------------

cd $OGSTM_HOME
git clone --recursive git@github.com:fabm-model/fabm-plus.git fabm
cd fabm

MODEL_SELECTED="ogstm"

# Create host driver
mkdir -p src/drivers/$MODEL_SELECTED
cat <<EOL > src/drivers/$MODEL_SELECTED/fabm_driver.h
#define _FABM_DIMENSION_COUNT_ 1
#define _FABM_DEPTH_DIMENSION_INDEX_ 1
#define _FABM_VECTORIZED_DIMENSION_INDEX_ 1

#include "fabm.h"
EOL

cd extern
git clone git@github.com:pmlmodelling/fabm-spectral.git
git checkout -b split

cd $OGSTM_HOME
