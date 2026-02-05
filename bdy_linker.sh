#!/bin/bash

OPA_HOME=$1

#reads start - end times and links BDYs and RESTARTS
HOMEDIR=/leonardo_work/OGS23_PRACE_IT_0/ggalli00/OGSTM-BFM/qDEG_SETUP
FORCINGS_DIR=$HOMEDIR/FORCINGS
BDY_DIR=$HOMEDIR/BC
NDG_DIR=$HOMEDIR/bc
RST_DIR=$HOMEDIR/RESTARTS
OPT_DIR=$HOMEDIR/OPTICS
RIV_DIR=/leonardo_work/OGS_test2528_0/COPERNICUS/Degradation/SETUP/PREPROC/BC/out

RUNDIR=$CINECA_SCRATCH/$OPA_HOME/wrkdir/MODEL
mkdir -p $RUNDIR/FORCINGS
mkdir -p $RUNDIR/BC
mkdir -p $RUNDIR/bc
mkdir -p $RUNDIR/RESTARTS
mkdir -p $RUNDIR/OPTICS

TFILE=$HOMEDIR/NAMELISTS/Start_End_Times
mapfile -t -O 1 var < $TFILE
start_date=${var[1]}
end_date=${var[2]}

ln -sf $FORCINGS_DIR/* $RUNDIR/FORCINGS #FORCINGS_DIR is already organised as /YYYY/MM/[TUVW]YYYYMM*.nc
ln -sf $BDY_DIR/*.nc $RUNDIR/BC
ln -sf $OPT_DIR/* $RUNDIR/OPTICS
#ln -sf $RST_DIR/*.nc $RUNDIR/RESTARTS
ln -sf $RST_DIR/RST.${start_date}*.nc $RUNDIR/RESTARTS
ln -sf $RIV_DIR/TIN*.nc $RUNDIR/BC
ln -sf $NDG_DIR/R3l*.nc $RUNDIR/bc
ln -sf $HOMEDIR/R3l_bclib/R3l_025.nc $RUNDIR/R3l.nc
# link 2019 as 2020
for f in "$RIV_DIR"/TIN_*.nc; do
  base=$(basename "$f")
  link_name=${base/TIN_[0-9][0-9][0-9][0-9]/TIN_2020}
  ln -sf "$f" "$RUNDIR/BC/$link_name"
done

## cheat because restarts are 1999 but forcings are 2000
#for f in $RUNDIR/RESTARTS/RST.1999*.nc; do
#  ln -s "$f" "${f/1999/1998}"
#  ln -s "$f" "${f/1999/2000}"
#done

# generate datelists
cd $RUNDIR
./genInputDatelists.sh

