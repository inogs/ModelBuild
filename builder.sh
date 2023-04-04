#! /usr/bin/env bash

OS=$(uname -s | tr '[:lower:]' '[:upper:]')
ROOT=$(dirname -- "${BASH_SOURCE[0]}" | xargs realpath)
ARGS=$(getopt --options 'dvb:o:' --longoptions 'debug,oceanvar,bfmdir:,ogstmdir:' -- "${@}")

if [[ $? -ne 0 ]]; then
        echo 'Usage: ./builder_ogstm_bfm.sh [-d|--debug] [-v|--oceanvar] [-b|--bfmdir] [-o|--ogstmdir] modulefile'
        exit 1
fi

DEBUG=
DEBUG_OCEANVAR=
OCEANVAR=false
MODULEBASENAME=m100.hpc-sdk
BFMDIR="${ROOT}/bfm"
OGSTMDIR="${ROOT}/ogstm"
ARCH=$(uname -m)

eval "set -- ${ARGS}"
while true; do
    case "${1}" in
        (-d | --debug)
            DEBUG=.dbg
            DEBUG_OCEANVAR=.dbg
            shift
        ;;
        (-v | --oceanvar)
	        OCEANVAR=true
            shift
        ;;
        (-b | --bfmdir)
	        BFMDIR=${2}
            shift 2
        ;;
        (-o | --ogstmdir)
	        OGSTMDIR=${2}
            shift 2
        ;;
        (--)
            shift
            break
        ;;
        (*)
            exit 1    # error
        ;;
    esac
done

if [[ ! -z "${@}" ]]; then
    MODULEBASENAME="${@}"
fi

set -e
set -o pipefail

export MODULEFILE="$ROOT/ogstm/compilers/machine_modules/${MODULEBASENAME}"
echo "Sourcing module file located at ${MODULEFILE}"
source "${MODULEFILE}" || :

# BFM library
echo '==== BUILDING BFM ===='
mkdir -p "${BFMDIR}"
cd "${BFMDIR}" || exit
export BFM_INC=${BFMDIR}/include
export BFM_LIB=${BFMDIR}/lib
export BFMversion=bfmv5
cd "${BFMDIR}/build" || exit
./bfm_configure.sh -gcfv -o ../lib/libbfm.a -p OGS_PELAGIC -a ${ARCH}.${OS}.${FC}${DEBUG}.inc

# CMake OGSTM builder
echo '==== BUILDING OGSTM ===='
mkdir -p "${OGSTMDIR}"
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
if [[ $MODULEBASENAME == m100.hpc-sdk ]]; then
    CMAKE_COMMONS+="-DCMAKE_C_COMPILER_ID=PGI "
    CMAKE_COMMONS+="-DCMAKE_Fortran_COMPILER_ID=PGI "
    CMAKE_COMMONS+="-DMPI_C_COMPILER=$(which mpipgicc) "
    CMAKE_COMMONS+="-DMPI_Fortran_COMPILER=$(which mpipgifort) "
elif [[ $MODULEBASENAME == m100.gnu ]]; then
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
echo '==== GENERATING NAMELIST ===='
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
