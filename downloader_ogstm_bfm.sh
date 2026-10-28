#! /bin/bash

# is_chain_compilation and the other functions shared with the builder
source "$(dirname "${BASH_SOURCE[0]}")/chain_utils.sh"

 OGSTM_BRANCH=neccton
 BFM_RELEASE=neccton
 VAR3D_RELEASE=release-4.2 # todo
 OASIM_RELEASE=release-1.0-opa

# Where the repositories are cloned: the HOST directory of the chain when the
# build is part of an OPA chain, the current working directory otherwise
if is_chain_compilation ; then
   DOWNLOAD_TARGET=$OPA_HOME/HOST/$OPA_HOSTNAME
else
   DOWNLOAD_TARGET=$PWD
fi
echo "DOWNLOAD_TARGET= $DOWNLOAD_TARGET"

# ----------- BFM library ---------------------

cd $DOWNLOAD_TARGET

# Requirement: to have an account on git server
git clone git@github.com:CMCC-Foundation/BiogeochemicalFluxModel.git bfm
cd bfm
git checkout $BFM_RELEASE

cd $DOWNLOAD_TARGET
git clone git@github.com:inogs/ogstm.git
cd ogstm
git switch $OGSTM_BRANCH

cd $DOWNLOAD_TARGET
git clone git@github.com:BIOPTIMOD/Forward_Adjoint.git
cd Forward_Adjoint
git switch $OASIM_RELEASE

cd $DOWNLOAD_TARGET
git clone git@github.com:BIOPTIMOD/OASIM_ATM.git OASIM
cd OASIM
git switch $OASIM_RELEASE

cd $DOWNLOAD_TARGET
git clone git@github.com:inogs/3dVarBio.git 3DVar
cd 3DVar
#git checkout -b $VAR3D_RELEASE $VAR3D_RELEASE
git switch Multivariate


