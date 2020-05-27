#! /bin/bash

COUPLERDIR=$PWD/BFMCOUPLER
BFMDIR=$PWD/bfm
MITGCM_ROOT=$PWD/MITgcm
MYCODE=$PWD/MYCODE
READY_FOR_MODEL=$PWD/READY_FOR_MODEL_NAMELISTS

mkdir -p $MYCODE $READY_FOR_MODEL

[[ -f $MYCODE/OBCS_OPTIONS.h     ]] ||  cp MITgcm/pkg/obcs/OBCS_OPTIONS.h $MYCODE 
[[ -f $MYCODE/PTRACER_SIZE.h     ]] ||  cp MITgcm/pkg/ptracer/PTRACER_SIZE.h $MYCODE
[[ -f $MYCODE/DIAGNOSTICS_SIZE.h ]] ||  cp MITgcm/pkg/diagnostics/DIAGNOSTICS_SIZE.h $MYCODE



echo "Now edit and configure you setup in USERCODE"

cd $COUPLERDIR
python bfm_config_gen.py -i $BFMDIR/build/tmp/OGS_PELAGIC/namelist.passivetrc --type code     -o $MYCODE
python bfm_config_gen.py -i $BFMDIR/build/tmp/OGS_PELAGIC/namelist.passivetrc --type namelist -o $READY_FOR_MODEL
# cp data.diagnostics data.ptracers
python diff_apply.py -i $MITGCM_ROOT  -o $MYCODE
