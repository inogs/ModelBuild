#! /usr/bin/env bash

ARCH=$(uname -m)
OS=$(uname -s | tr '[:lower:]' '[:upper:]')
ROOT=$(dirname -- "${BASH_SOURCE[0]}" | xargs realpath)
ARGS=$(getopt --options '' --longoptions 'download,debug,var3d,var3dpath:,var3drepo:,var3dbranch:,bfmpath:,bfmrepo:,bfmbranch:,ogstmpath:,ogstmrepo:,ogstmbranch:,modulename:' -- "${@}")

if [[ $? -ne 0 ]]; then
        echo 'Usage: ./builder_ogstm_bfm.sh [-d|--debug] [--var3d] [--var3dpath=] [--var3drepo=] [--var3dbranch=] [--bfmpath=] [--bfmrepo=] [--bfmbranch=] [--ogstmpath=] [--ogstmrepo=] [--ogstmbranch=] [--modulename=]'
        exit 1
fi

# General settings

DOWNLOAD=false
DEBUG=
OCEANVAR=false
MODULEBASENAME=m100.hpc-sdk

# BFM settings
BFM_PATH="${ROOT}/bfm"
BFM_VERSION=v5
BFMv5_REPO=git@github.com:BFM-Community/BiogeochemicalFluxModel.git
BFMv5_BRANCH=dev_gpu

# OGSTM settings
OGSTM_REPO=git@github.com:inogs/ogstm.git
OGSTM_BRANCH=dev_gpu
OGSTM_PATH="${ROOT}/ogstm"

# VAR3D settings
VAR3D_REPO=git@gitlab.hpc.cineca.it:OGS/3DVar.git
VAR3D_BRANCH=Multivariate
VAR3D_PATH=3DVar

eval "set -- ${ARGS}"
while true; do
    case "${1}" in
        (-d | --debug)
            DEBUG=.dbg
            shift
        ;;
        (--download)
	        DOWNLOAD=true
            shift
        ;;
        (--var3d)
	        OCEANVAR=true
            shift
        ;;
        (--var3dpath)
	        VAR3D_PATH=${2}
            shift 2
        ;;
        (--var3drepo)
	        VAR3D_REPO=${2}
            shift 2
        ;;
        (--var3dbranch)
	        VAR3D_BRANCH=${2}
            shift 2
        ;;
        (--bfmpath)
	        BFM_PATH=${2}
            shift 2
        ;;
        (--bfmrepo)
	        BFMv5_REPO=${2}
            shift 2
        ;;
        (--bfmbranch)
	        BFMv5_BRANCH=${2}
            shift 2
        ;;
        (--ogstmpath)
	        OGSTM_PATH=${2}
            shift 2
        ;;
        (--ogstmrepo)
	        OGSTM_REPO=${2}
            shift 2
        ;;
        (--ogstmbranch)
	        OGSTM_BRANCH=${2}
            shift 2
        ;;
        (--modulename)
	        MODULEBASENAME=${2}
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

set -e
set -o pipefail

cd -- "${ROOT}" || exit

if [[ $DOWNLOAD == true ]]; then
    echo -e "\n==== Downloading BFM ===="
    git clone ${GIT_CLONE_OPTIONS} --branch ${BFMv5_BRANCH} -- ${BFMv5_REPO} "${BFM_PATH}" || echo "An error occurred while cloning BFM. Skipping."
    echo -e "\n==== Downloading OGSTM ===="
    git clone ${GIT_CLONE_OPTIONS} --branch ${OGSTM_BRANCH} -- ${OGSTM_REPO} "${OGSTM_PATH}" || echo "An error occurred while cloning OGSTM. Skipping"
fi 

export MODULEFILE="$ROOT/ogstm/compilers/machine_modules/${MODULEBASENAME}"
echo "Sourcing module file located at ${MODULEFILE}"
source "${MODULEFILE}" || :

echo '==== Building BFM ===='
mkdir -p "${BFM_PATH}"
cd "${BFM_PATH}" || exit
export BFM_INC=${BFM_PATH}/include
export BFM_LIB=${BFM_PATH}/lib
export BFMversion=bfmv5
cd "${BFM_PATH}/build" || exit
./bfm_configure.sh -gcfv -o ../lib/libbfm.a -p OGS_PELAGIC -a ${ARCH}.${OS}.${FC}${DEBUG}.inc

echo '==== Building OGSTM ===='
mkdir -p "${OGSTM_PATH}"
cd "${OGSTM_PATH}/.." || exit
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

    if [[ $DOWNLOAD == true ]]; then
        echo -e "\n==== Downloading 3DVar ===="
        git clone ${GIT_CLONE_OPTIONS} --branch ${VAR3D_BRANCH} -- ${VAR3D_REPO} "${VAR3D_PATH}" || echo "An error occurred while cloning 3DVar. Skipping"
    fi
    
    cd "${ROOT}/3DVar" || exit
    cp "${ARCH}.${OS}.${FC}${DEBUG}.inc" compiler.inc
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
echo '==== Generating namelists ===='
mkdir -p "${OGSTM_PATH}/ready_for_model_namelists/"
if [[ $BFMversion == bfmv5 ]]; then
    cp "${BFM_PATH}/build/tmp/OGS_PELAGIC/namelist.passivetrc" "${OGSTM_PATH}/bfmv5/"
    cd "${OGSTM_PATH}/bfmv5/" || exit
    # generates namelist.passivetrc_new
    ./ogstm_namelist_gen.py
    cp "${OGSTM_PATH}/src/namelists/namelist"* "${OGSTM_PATH}/ready_for_model_namelists/"
    # overwriting namelist
    cp namelist.passivetrc_new "${OGSTM_PATH}/ready_for_model_namelists/namelist.passivetrc"
    cp "${BFM_PATH}/build/tmp/OGS_PELAGIC/"*.nml "${OGSTM_PATH}/ready_for_model_namelists/"
else
    cp "${OGSTM_PATH}/src/namelists/namelist"* "${OGSTM_PATH}/ready_for_model_namelists/"
    cp "${BFM_PATH}/src/namelist/"*.nml "${OGSTM_PATH}/ready_for_model_namelists/"
fi
