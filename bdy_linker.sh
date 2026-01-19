#!/bin/bash

#reads start - end times and links BDYs and RESTARTS
HOMEDIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/qDEG_SETUP
FORCINGS_DIR=$HOMEDIR/FORCINGS
BDY_DIR=$HOMEDIR/BC
RST_DIR=$HOMEDIR/RESTARTS
OPT_DIR=$HOMEDIR/OPTICS
RIV_DIR=/leonardo_work/OGS_test2528_0/COPERNICUS/Degradation/SETUP/PREPROC/BC/out

RUNDIR=/leonardo_scratch/large/userexternal/ggalli00/OGSTM-BFM-qDeg/__TESTNAME__/wrkdir/MODEL
mkdir -p $RUNDIR/FORCINGS
mkdir -p $RUNDIR/BC
mkdir -p $RUNDIR/RESTARTS
mkdir -p $RUNDIR/OPTICS

TFILE=$HOMEDIR/NAMELISTS/Start_End_Times
mapfile -t -O 1 var < $TFILE
start_date=${var[1]}
end_date=${var[2]}

ln -sf $FORCINGS_DIR/* $RUNDIR/FORCINGS #FORCINGS_DIR is already organised as /YYYY/MM/[TUVW]YYYYMM*.nc
ln -sf $BDY_DIR/*.nc $RUNDIR/BC
ln -sf $OPT_DIR/* $RUNDIR/OPTICS
ln -sf $RST_DIR/*.nc $RUNDIR/RESTARTS
ln -sf $RIV_DIR/TIN*.nc $RUNDIR/BC
# link 2019 as 2020
for f in "$RIV_DIR"/TIN_*.nc; do
  base=$(basename "$f")
  link_name=${base/TIN_[0-9][0-9][0-9][0-9]/TIN_2020}
  ln -sf "$f" "$RUNDIR/BC/$link_name"
done

# cheat because restarts are 1999 but forcings are 2000
for f in $RUNDIR/RESTARTS/RST.1999*.nc; do
  ln -s "$f" "${f/1999/2000}"
done

# generate datelists
cd $RUNDIR
./genInputDatelists.sh

