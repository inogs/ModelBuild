#!/bin/bash

#export set -Eeuo pipefail

TESTNAME=T0X
SCRATCHDIR=OGSTM-BFM-qDeg

start_date=19990101
end_date=20060101

OPA_HOME=$SCRATCHDIR/$TESTNAME
HOMEDIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/  
RUNDIR=/leonardo_scratch/large/userexternal/ggalli00/$OPA_HOME

##################################
### From here on all automated ###
##################################

# write StartEndTimes
echo "${start_date}-00:00:00" > $HOMEDIR/qDEG_SETUP/NAMELISTS/StartEndTimes
echo -e "${end_date}-00:00:00" >> $HOMEDIR/qDEG_SETUP/NAMELISTS/StartEndTimes

mkdir -p $RUNDIR

rsync -aP $HOMEDIR/downloader_ogstm_bfm.sh $RUNDIR
rsync -aP $HOMEDIR/builder_ogstm_bfm.sh $RUNDIR
rsync -aP $HOMEDIR/prepare_rundir.sh $RUNDIR
rsync -aP $HOMEDIR/bdy_linker.sh $RUNDIR

cd $RUNDIR

# clone code
./downloader_ogstm_bfm.sh $OPA_HOME

# build code
./builder_ogstm_bfm.sh

# copy everything to run directory
# namelists, meshmasks etc.
./prepare_rundir.sh $OPA_HOME

# link boundaries and restarts
echo linking boundary conditions etc...
./bdy_linker.sh $OPA_HOME

# go to rundir to launch job
echo all done!
#export cd $RUNDIR

