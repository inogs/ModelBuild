#! /usr/bin/env bash

MODULEFILE_=m100.hpc-sdk
CMAKE=true
OCEANVAR=false
# Release
DEBUG=
DEBUG_OCEANVAR=
# Debug
# DEBUG=.dbg
# DEBUG_OCEANVAR=.dbg


ARCH=$(uname -m)
OS=$(uname -s | tr '[:lower:]' '[:upper:]')
ROOT=$(dirname -- "${BASH_SOURCE[0]}")

export MODULEFILE="$ROOT/ogstm/compilers/machine_modules/${MODULEFILE_}"
source "${MODULEFILE}"

if [[ $# -eq 2 ]]; then
    BFMDIR=$1
    OGSTMDIR=$2
elif [[ $# -eq 0 ]]; then
    BFMDIR="${ROOT}/bfm"
    OGSTMDIR="${ROOT}/ogstm"
else
    echo "SYNOPSYS"
    echo "Build BFM and ogstm model"
    echo "builder_ogstm_bfm.sh [ BFMDIR ] [ OGSTMDIR ]"
    echo ""
    echo " Dirs have to be expressed as full paths "
    echo "EXAMPLE"
    echo " ./builder_ogstm_bfm.sh $PWD/bfm $PWD/ogstm "
    exit 1
fi

# BFM library
cd "${BFMDIR}" || exit
export BFM_INC=${BFMDIR}/include
export BFM_LIB=${BFMDIR}/lib
# exit status 1 if bfmv5
if svn info 2>&1; then
    BFMversion=BFMv2
    cd "${BFMDIR}/compilers" || exit
    cp "${ARCH}.${OS}.${FC}${DEBUG}.inc" compiler.inc
    # just because R1.3 does not have include/
    mkdir -p "${BFMDIR}/include"
    cd "${BFMDIR}/build" || exit
    ./config_BFM.sh -a "${ARCH}" -c ogstm
    cd BLD_OGSTMBFM || exit
    gmake
else
   BFMversion=bfmv5
   echo "Skipping BFM"
   # in-place replace the entire ARCH line
   sed -i "s/.*ARCH.*/        ARCH    = '${ARCH}.${OS}.${FC}${DEBUG}.inc'  /" build/configurations/OGS_PELAGIC/configuration
   cd "${BFMDIR}/build" || exit
   ./bfm_configure.sh -gcv -o ../lib/libbfm.a -p OGS_PELAGIC
fi

# CMake OGSTM builder
cd "${OGSTMDIR}/.." || exit
if [[ $CMAKE == true ]]; then
    export BFM_INCLUDE=$BFM_INC
    export BFM_LIBRARY=$BFM_LIB
    if [[ $DEBUG == .dbg ]]; then
        CMAKE_BUILD_TYPE=Debug
        OGSTM_BLD_DIR=OGSTM_BUILD_DBG
    else
        CMAKE_BUILD_TYPE=Release
        OGSTM_BLD_DIR=OGSTM_BUILD
    fi
    mkdir -p "${OGSTM_BLD_DIR}"
    cd "${OGSTM_BLD_DIR}" || exit
    CMAKE_COMMONS="-DMPIEXEC_EXECUTABLE=$(which mpiexec) -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "
    CMAKE_COMMONS+="-DNETCDF_INCLUDES_C=$NETCDF_INC -DNETCDF_LIBRARIES_C=$NETCDF_LIB/libnetcdf.so -DNETCDFF_INCLUDES_F90=$NETCDFF_INC -DNETCDFF_LIBRARIES_F90=$NETCDFF_LIB/libnetcdff.so -D${BFMversion}=ON"
    if [[ $OCEANVAR == true ]]; then
        cd "${ROOT}/3DVar" || exit
        cp "${ARCH}.${OS}.${FC}${DEBUG_OCEANVAR}.inc" compiler.inc
        gmake
        
        export DA_INCLUDE="${ROOT}/3DVar"
        export DA_LIBRARY="${ROOT}/3DVar"
        export PETSC_LIB=$PETSC_LIB/libpetsc.so
        cp ../ogstm/DataAssimilation.cmake ../ogstm/CMakeLists.txt
        cmake ../ogstm/ "${CMAKE_COMMONS}" -DPETSC_LIBRARIES="${PETSC_LIB}" -DPNETCDF_LIBRARIES="${PNETCDF_LIB}/libpnetcdf.a"
    else
        cp ../ogstm/GeneralCmake.cmake ../ogstm/CMakeLists.txt
        cmake ../ogstm/ "${CMAKE_COMMONS}"
    fi
    make
else
    # standard OGSTM builder
    cd "${OGSTMDIR}/compilers" || exit
    cp "${ARCH}.${OS}.${FC}${DEBUG}.inc" compiler.inc
    cd "${OGSTMDIR}/build" || exit
    ./config_OGSTM.sh "${ARCH}"
    cd BLD_OGSTM || exit
    make -f MakeLib
    rm -f get_mem_mod.o
    gmake
fi

# Namelist generation (also by Frequency Control)
mkdir -p "${OGSTMDIR}/ready_for_model_namelists/"
if [[ $BFMversion == bfmv5 ]]; then
    cp "${BFMDIR}/build/tmp/OGS_PELAGIC/namelist.passivetrc" "${OGSTMDIR}/bfmv5/"
    cd "${OGSTMDIR}/bfmv5/" || exit
    # generates namelist.passivetrc_new
    ./ogstm_namelist_gen.py
    cp "${OGSTMDIR}/src/namelists/namelist*" "${OGSTMDIR}/ready_for_model_namelists/"
    # overwriting namelist
    cp namelist.passivetrc_new "${OGSTMDIR}/ready_for_model_namelists/namelist.passivetrc"
    cp "${BFMDIR}/build/tmp/OGS_PELAGIC/*.nml" "${OGSTMDIR}/ready_for_model_namelists/"
else
    cp "${OGSTMDIR}/src/namelists/namelist*" "${OGSTMDIR}/ready_for_model_namelists/"
    cp "${BFMDIR}/src/namelist/*.nml" "${OGSTMDIR}/ready_for_model_namelists/"
fi
