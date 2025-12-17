#!/bin/bash

TESTNAME=T00

HOMEDIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/  
RUNDIR=/leonardo_scratch/large/userexternal/ggalli00/OGSTM-BFM-qDeg/$TESTNAME

mkdir -p $RUNDIR

rsync -aP $HOMEDIR/downloader_ogstm_bfm.sh $RUNDIR
rsync -aP $HOMEDIR/builder_ogstm_bfm.sh $RUNDIR
rsync -aP $HOMEDIR/prepare_rundir.sh $RUNDIR
rsync -aP $HOMEDIR/bdy_linker.sh $RUNDIR

cd $RUNDIR
sed -i "s/__TESTNAME__/$TESTNAME/" prepare_rundir.sh
sed -i "s/__TESTNAME__/$TESTNAME/" bdy_linker.sh

# clone code
./downloader_ogstm_bfm.sh

# build code
./builder_ogstm_bfm.sh

# copy everything to run directory
# namelists, meshmasks etc.
./prepare_rundir.sh

# link boundaries and restarts
./bdy_linker.sh

# go to rundir to launch job
echo all done!
#export cd $RUNDIR

