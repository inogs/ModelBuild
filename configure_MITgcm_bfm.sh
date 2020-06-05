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

[[ -f $MYCODE/SIZE.h             ]] ||  cp MITgcm/model/inc/SIZE.h $MYCODE
[[ -f $MYCODE/CPP_OPTIONS.h      ]] ||  cp MITgcm/model/inc/CPP_OPTIONS.h $MYCODE
[[ -f $MYCODE/OBCS_OPTIONS.h     ]] ||  cp MITgcm/pkg/obcs/OBCS_OPTIONS.h $MYCODE 
[[ -f $MYCODE/RBCS_SIZE.h        ]] ||  cp MITgcm/pkg/rbcs/RBCS_SIZE.h $MYCODE 
[[ -f $MYCODE/EXF_OPTIONS.h      ]] ||  cp MITgcm/pkg/exf/EXF_OPTIONS.h $MYCODE 
[[ -f $MYCODE/GCHEM.h            ]] ||  cp MITgcm/pkg/gchem/GCHEM.h $MYCODE 
[[ -f $MYCODE/GCHEM_OPTIONS.h    ]] ||  cp MITgcm/pkg/gchem/GCHEM_OPTIONS.h $MYCODE 
[[ -f $MYCODE/PTRACERS_SIZE.h    ]] ||  cp MITgcm/pkg/ptracers/PTRACERS_SIZE.h $MYCODE
[[ -f $MYCODE/DIAGNOSTICS_SIZE.h ]] ||  cp MITgcm/pkg/diagnostics/DIAGNOSTICS_SIZE.h $MYCODE

# temporary access to code_NADRI

cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/SIZE.h_020p $MYCODE/SIZE.h
cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/CPP_OPTIONS.h $MYCODE
cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/OBCS_OPTIONS.h $MYCODE 
cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/RBCS_SIZE.h $MYCODE 
cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/EXF_OPTIONS.h_ALADIN $MYCODE/EXF_OPTIONS.h
cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/PTRACERS_SIZE.h $MYCODE/PTRACERS_SIZE.h
cp /gpfs/work/OGS20_PRACE_P/CADEAU/CODE/code_NADRI/DIAGNOSTICS_SIZE.h $MYCODE/DIAGNOSTICS_SIZE.h

echo "Now edit and configure your setup in $MYCODE/"

cp $COUPLERDIR/BFMcoupler*.F $MYCODE
cp $COUPLERDIR/BFMcoupler*.h $MYCODE

cd $COUPLERDIR
python bfm_config_gen.py -i $BFMDIR/build/tmp/OGS_PELAGIC/namelist.passivetrc --type code     -o $MYCODE
python bfm_config_gen.py -i $BFMDIR/build/tmp/OGS_PELAGIC/namelist.passivetrc --type namelist -o $NAMELISTS

python diff_apply.py -i $MITGCM_ROOT  -o $MYCODE

