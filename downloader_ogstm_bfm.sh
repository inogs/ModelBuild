#! /bin/bash

OPA_HOME=$1

OGSTM_BRANCH=neccton
BFM_BRANCH=neccton
VAR3D_RELEASE=release-4.1
OASIM_RELEASE=release-1.0

# some postproc scripts with my paths
PPROC_DIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/qDEG_SETUP/MYCODE/ogstm_postptoc
BITSEA_DIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/qDEG_SETUP/MYCODE/bitsea

# ----------- BFM library ---------------------

#MYCODE=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/MYCODE

OGSTM_HOME=$PWD/CODE
PPROC_HOME=$PWD/wrkdir/POSTPROC
mkdir -p $OGSTM_HOME
mkdir -p $PPROC_HOME

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

cd $PPROC_HOME
git clone git@github.com:inogs/bit.sea.git

# clone ogstm_postproc
# and replace / add / modify relevant files
git clone git@github.com:inogs/ogstm_postproc.git
cd ogstm_postproc/MY_optics

rsync -aP $PPROC_DIR/job.POST.singleyear.slurm .
rsync -aP $PPROC_DIR/VarDescriptor_2.xml .
rsync -aP $PPROC_DIR/VarDescriptor_1.xml .
rsync -aP $PPROC_DIR/VarDescriptorB.xml .
rsync -aP $PPROC_DIR/profiler.tpl .
rsync -aP $PPROC_DIR/timeseries.sh .
rsync -aP $PPROC_DIR/maps.sh .
rsync -aP $PPROC_DIR/maps_MY.sh .

sed "s|__OPA_HOME__|$OPA_HOME|" $PPROC_DIR/config.template.sh > config.sh
sed "s|__OPA_HOME__|$OPA_HOME|" $PPROC_DIR/timeseries_user_settings.txt > timeseries_user_settings.txt
sed -i "s|__CINECA_SCRATCH__|$CINECA_SCRATCH|" timeseries_user_settings.txt
sed -i "s|__TEST_NAME__|$TESTNAME|" timeseries_user_settings.txt

cd $PPROC_HOME
cd ./bit.sea/src/bitsea/validation/deliverables

rsync -aP $BITSEA_DIR/Plotlist_bio.xml . 
