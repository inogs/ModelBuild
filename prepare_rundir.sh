#!/bin/bash

#HOMEDIR=/leonardo_scratch/large/userexternal/ggalli00/OGSTM-BFM-qDeg
#TESTNAME=__TESTNAME__

HOMEDIR=$PWD
SETUPDIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/qDEG_SETUP

#RUNDIR=$HOMEDIR/$TESTNAME/wrkdir/MODEL/
RUNDIR=$HOMEDIR/wrkdir/MODEL
mkdir -p $RUNDIR

# move stuff / create links to RUNDIR

# 1. ogstm-bfm executable
#ln -sf $HOMEDIR/CODE/OGSTM_BUILD/ogstm.xx $RUNDIR
ln -sf $HOMEDIR/CODE/OGSTM_BUILD_DBG/ogstm.xx $RUNDIR

# 2. domdec.110 is for quarter deg resolution
#    (domdec file gets linked by job.slurm)
rsync -aP $SETUPDIR/DOMDEC_JOB/domdec.107.txt $RUNDIR #just a domdec, maybe not optimal
rsync -aP $SETUPDIR/DOMDEC_JOB/domdec.1.txt $RUNDIR #to run 1 core only
rsync -aP $SETUPDIR/DOMDEC_JOB/job.1x107.slurm $RUNDIR/job.slurm

# 3. masks
rsync -aP $SETUPDIR/MASKS/meshmask_025_z125.nc $RUNDIR/meshmask.nc
rsync -aP $SETUPDIR/MASKS/bounmask.nc $RUNDIR
rsync -aP $SETUPDIR/MASKS/bfmmask.nc $RUNDIR

# 4. namelists etc. (!C: differs from the one in camadio v20)
#NMLDIR=$HOMEDIR/CODE/ogstm/ready_for_model_namelists
NMLDIR=$SETUPDIR/NAMELISTS

rsync -aP $NMLDIR/Pelagic_Ecology.nml $RUNDIR      #(!C)
rsync -aP $NMLDIR/Pelagic_Environment.nml $RUNDIR  #(!C) in p_bR123l only
rsync -aP $NMLDIR/Benthic_Environment.nml $RUNDIR  #same
rsync -aP $NMLDIR/Carbonate_Dynamics.nml $RUNDIR   #same
rsync -aP $NMLDIR/BFM_General.nml $RUNDIR          #same (comments differ)
rsync -aP $NMLDIR/Standalone.nml $RUNDIR           #same
rsync -aP $NMLDIR/namelist.passivetrc $RUNDIR      #(!C) (stuff about output?)
rsync -aP $NMLDIR/namelist.init $RUNDIR            #(!C) (lsbc, read_W_from_file, internal_sponging)
rsync -aP $NMLDIR/namelist.optics $RUNDIR          #(!C)
rsync -aP $NMLDIR/namelist.phys $RUNDIR            #(!C)
rsync -aP $NMLDIR/oasim_config.yaml $RUNDIR            #

rsync -aP $NMLDIR/*aveTimes $RUNDIR
rsync -aP $NMLDIR/daTimes $RUNDIR
rsync -aP $NMLDIR/daTimes_sat $RUNDIR
rsync -aP $NMLDIR/optAeroTimes $RUNDIR
rsync -aP $NMLDIR/optatmTimes $RUNDIR
rsync -aP $NMLDIR/optclimTimes $RUNDIR
rsync -aP $NMLDIR/restartTimes $RUNDIR
rsync -aP $NMLDIR/Start_End_Times $RUNDIR
rsync -aP $NMLDIR/forcingsTimes $RUNDIR
rsync -aP $NMLDIR/AtmTimes $RUNDIR
rsync -aP $NMLDIR/carbonTimes $RUNDIR

rsync -aP $NMLDIR/boundaries.nml $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/files_namelist_atl.dat $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/files_namelist_gib.dat $RUNDIR           #(!C, obviously!)
#rsync -aP $NMLDIR/files_namelist_riv.dat $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/atl.nml $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/gi1.nml $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/gi2.nml $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/gi3.nml $RUNDIR           #(!C, obviously!)
#rsync -aP $NMLDIR/riv.nml $RUNDIR           #(!C, obviously!)
rsync -aP $NMLDIR/*.dat $RUNDIR           #(!C, obviously!)

rsync -aP $NMLDIR/bcs $RUNDIR #optics parameters

# 5. Forcings
# 6. Restarts
# taken care of by bdy_linker.sh
