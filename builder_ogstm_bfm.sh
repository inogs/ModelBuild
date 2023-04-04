#! /usr/bin/env bash
set -e
set -o pipefail

MODULEFILE_=m100.hpc-sdk
OCEANVAR=false
# Release
#DEBUG=
DEBUG_OCEANVAR=
# Debug
DEBUG=.dbg
#DEBUG_OCEANVAR=.dbg

set -e

ARCH=$(uname -m)
OS=$(uname -s | tr '[:lower:]' '[:upper:]')
ROOT=$(dirname -- "${BASH_SOURCE[0]}" | xargs realpath)

export MODULEFILE="$ROOT/ogstm/compilers/machine_modules/${MODULEFILE_}"
source "${MODULEFILE}" || :

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
export BFMversion=bfmv5
cd "${BFMDIR}/build" || exit
./bfm_configure.sh -gcfv -o ../lib/libbfm.a -p OGS_PELAGIC -a ${ARCH}.${OS}.${FC}${DEBUG}.inc

# CMake OGSTM builder
cd "${OGSTMDIR}/.." || exit
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
CMAKE_COMMONS="-DCMAKE_VERBOSE_MAKEFILE=ON "
CMAKE_COMMONS+="-DMPIEXEC_EXECUTABLE=$(which mpiexec) "
if [[ $MODULEFILE_ == m100.hpc-sdk ]]; then
    CMAKE_COMMONS+="-DCMAKE_C_COMPILER_ID=PGI "
    CMAKE_COMMONS+="-DCMAKE_Fortran_COMPILER_ID=PGI "
    CMAKE_COMMONS+="-DMPI_C_COMPILER=$(which mpipgicc) "
    CMAKE_COMMONS+="-DMPI_Fortran_COMPILER=$(which mpipgifort) "
elif [[ $MODULEFILE_ == m100.gnu ]]; then
    CMAKE_COMMONS+="-DCMAKE_C_COMPILER_ID=GNU "
    CMAKE_COMMONS+="-DCMAKE_Fortran_COMPILER_ID=GNU "
    CMAKE_COMMONS+="-DMPI_C_COMPILER=$(which mpicc) "
    CMAKE_COMMONS+="-DMPI_Fortran_COMPILER=$(which mpifort) "
fi
CMAKE_COMMONS+="-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "
CMAKE_COMMONS+="-DNETCDF_INCLUDES_C=${NETCDF_INC} "
CMAKE_COMMONS+="-DNETCDF_LIBRARIES_C=${NETCDF_LIB}/libnetcdf.so "
CMAKE_COMMONS+="-DNETCDFF_INCLUDES_F90=${NETCDFF_INC} "
CMAKE_COMMONS+="-DNETCDFF_LIBRARIES_F90=${NETCDFF_LIB}/libnetcdff.so "
CMAKE_COMMONS+="-D${BFMversion}=ON"
if [[ $OCEANVAR == true ]]; then
    cd "${ROOT}/3DVar" || exit
    cp "${ARCH}.${OS}.${FC}${DEBUG_OCEANVAR}.inc" compiler.inc
    gmake
    
    export DA_INCLUDE="${ROOT}/3DVar"
    export DA_LIBRARY="${ROOT}/3DVar"
    export PETSC_LIB=$PETSC_LIB/libpetsc.so
    CMAKE_COMMONS+="-DPETSC_LIBRARIES=${PETSC_LIB} "
    CMAKE_COMMONS+="-DPNETCDF_LIBRARIES=${PNETCDF_LIB}/libpnetcdf.a "
    cp ../ogstm/DataAssimilation.cmake ../ogstm/CMakeLists.txt
else
    cp ../ogstm/GeneralCmake.cmake ../ogstm/CMakeLists.txt
fi
cmake -LAH ../ogstm/ ${CMAKE_COMMONS}
make

# Namelist generation (also by Frequency Control)
mkdir -p "${OGSTMDIR}/ready_for_model_namelists/"
if [[ $BFMversion == bfmv5 ]]; then
    cp "${BFMDIR}/build/tmp/OGS_PELAGIC/namelist.passivetrc" "${OGSTMDIR}/bfmv5/"
    cd "${OGSTMDIR}/bfmv5/" || exit
    # generates namelist.passivetrc_new
    ./ogstm_namelist_gen.py
    cp "${OGSTMDIR}/src/namelists/namelist"* "${OGSTMDIR}/ready_for_model_namelists/"
    # overwriting namelist
    cp namelist.passivetrc_new "${OGSTMDIR}/ready_for_model_namelists/namelist.passivetrc"
    cp "${BFMDIR}/build/tmp/OGS_PELAGIC/"*.nml "${OGSTMDIR}/ready_for_model_namelists/"
else
    cp "${OGSTMDIR}/src/namelists/namelist"* "${OGSTMDIR}/ready_for_model_namelists/"
    cp "${BFMDIR}/src/namelist/"*.nml "${OGSTMDIR}/ready_for_model_namelists/"
fi
