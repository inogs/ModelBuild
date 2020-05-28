#! /bin/bash

#
#  generates two output directories:
#  MYCODE
#  READY_FOR_MODEL_NAMELISTS



 COUPLERDIR=$PWD/BFMCOUPLER
     BFMDIR=$PWD/bfm
MITGCM_ROOT=$PWD/MITgcm
     MYCODE=$PWD/MYCODE
  NAMELISTS=$PWD/READY_FOR_MODEL_NAMELISTS

mkdir -p $MYCODE $NAMELISTS

[[ -f $MYCODE/OBCS_OPTIONS.h     ]] ||  cp MITgcm/pkg/obcs/OBCS_OPTIONS.h $MYCODE 
[[ -f $MYCODE/PTRACERS_SIZE.h    ]] ||  cp MITgcm/pkg/ptracers/PTRACERS_SIZE.h $MYCODE
[[ -f $MYCODE/DIAGNOSTICS_SIZE.h ]] ||  cp MITgcm/pkg/diagnostics/DIAGNOSTICS_SIZE.h $MYCODE



echo "Now edit and configure your setup in MYCODE/"

cd $COUPLERDIR
python bfm_config_gen.py -i $BFMDIR/build/tmp/OGS_PELAGIC/namelist.passivetrc --type code     -o $MYCODE
python bfm_config_gen.py -i $BFMDIR/build/tmp/OGS_PELAGIC/namelist.passivetrc --type namelist -o $NAMELISTS
# cp data.diagnostics data.ptracers
python diff_apply.py -i $MITGCM_ROOT  -o $MYCODE



