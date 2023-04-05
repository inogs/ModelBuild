#! /usr/bin/env bash

ARCH=$(uname -m)
OS=$(uname -s | tr '[:lower:]' '[:upper:]')
ROOT=$(dirname -- "${BASH_SOURCE[0]}" | xargs realpath)

usage() {
    more << EOF
NAME
    This script download and compile the coupled OGSTM-BFM model (by default, for Marconi 100 with GPU support enabled).

SYNOPSIS
    usage: $0 --help
    usage: $0 [options]

DESCRIPTION
    Download options
        --no-download                           Do not download the source code from GitHub
        --clone-options     GIT_CLONE_OPTIONS   git-clone options (such as --single-branch)
        --ogstm-branch      OGSTM_BRANCH        Which branch of OGSTM tree to use (relative to the location of $0, default dev_gpu)
        --bfm-branch        BFM_BRANCH          Which branch of BFM tree to use(relative to the location of $0, default dev_gpu)
        --var3d-branch      VAR3D_BRANCH        Which branch of 3DVar tree to use ( source (relative to the location of $0, default dev_gpu)
    Compilation options
        --debug                                 Compiles debug version
        --var3d                                 Enables data assimilation component
        --machine-modules   MOD_NAME            Specifies which file (among the available ones in OGSTM) to source, to load modules
        --build-path        BUILD_PATH          Where to build OGSTM-BFM (relative to the location of $0, default OGSTM_BUILD)
        --ogstm-path        OGSTM_PATH          Where to look for the OGSTM source (relative to the location of $0, default ogstm)
        --bfm-path          BFM_PATH            Where to look for the BFM source (relative to the location of $0, default bfm)
    Other options
        --help                                  Shows this help
EOF
}

LONGOPTS='help,no-download,debug,var3d,clone-options:,var3d-path:,var3d-branch:,bfm-path:,bfm-branch:,ogstm-path:,ogstm-branch:,module-file:,build-path:'
ARGS=$(getopt --options '' --longoptions ${LONGOPTS} -- "${@}")
if [[ $? -ne 0 ]]; then
        usage
        exit 1
fi

# General settings
DOWNLOAD=true
DEBUG=false
VAR3D=false
MOD_NAME=m100.hpc-sdk
BUILD_PATH="${ROOT}/OGSTM_BUILD"

# BFM settings
BFM_PATH="${ROOT}/bfm"
BFM_REPO=git@github.com:BFM-Community/BiogeochemicalFluxModel.git
BFM_BRANCH=dev_gpu

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
        (--debug)
            DEBUG=true
            DEBUG_SUFFIX=.dbg
            shift
        ;;
        (--no-download)
	        DOWNLOAD=false
            shift
        ;;
        (--var3d)
	        VAR3D=true
            shift
        ;;
        (--clone-options)
	        GIT_CLONE_OPTIONS=${2}
            shift 2
        ;;
        (--var3d-path)
	        VAR3D_PATH="${ROOT}/${2}"
            shift 2
        ;;
        (--var3d-branch)
	        VAR3D_BRANCH=${2}
            shift 2
        ;;
        (--bfm-path)
	        BFM_PATH="${ROOT}/${2}"
            shift 2
        ;;
        (--bfm-branch)
	        BFM_BRANCH=${2}
            shift 2
        ;;
        (--ogstm-path)
	        OGSTM_PATH="${ROOT}/${2}"
            shift 2
        ;;
        (--ogstm-branch)
	        OGSTM_BRANCH=${2}
            shift 2
        ;;
        (--machine-modules)
	        MOD_NAME=${2}
            shift 2
        ;;
        (--build-path)
	        BUILD_PATH="${ROOT}/${2}"
            shift 2
        ;;
        (--help)
	        usage 
            exit 0
        ;;
        (--)
            shift
            break
        ;;
        (*)
            exit 1
        ;;
    esac
done

set -e
set -o pipefail

cd -- "${ROOT}" || exit

if [[ $DOWNLOAD == true ]]; then
    echo -e "\n==== Downloading BFM ===="
    git clone ${GIT_CLONE_OPTIONS} --branch ${BFM_BRANCH} -- ${BFM_REPO} "${BFM_PATH}" || echo "An error occurred while cloning BFM. Skipping."
    echo -e "\n==== Downloading OGSTM ===="
    git clone ${GIT_CLONE_OPTIONS} --branch ${OGSTM_BRANCH} -- ${OGSTM_REPO} "${OGSTM_PATH}" || echo "An error occurred while cloning OGSTM. Skipping"
fi 

echo -e "\n==== Sourcing ${MOD_NAME} ===="
source "$ROOT/ogstm/compilers/machine_modules/${MOD_NAME}" || :

echo -e "\n==== Building BFM ===="
export BFM_INC=${BFM_PATH}/include
export BFM_LIB=${BFM_PATH}/lib
cd "${BFM_PATH}/build" || exit
./bfm_configure.sh -gcfv -o ../lib/libbfm.a -p OGS_PELAGIC -a ${ARCH}.${OS}.${FC}${DEBUG_SUFFIX}.inc

echo -e "\n==== Building OGSTM ===="
export BFM_INCLUDE=$BFM_INC
export BFM_LIBRARY=$BFM_LIB
mkdir -p "${BUILD_PATH}"
cd "${BUILD_PATH}" || exit

if [[ $DEBUG == true ]]; then
    CMAKE_BUILD_TYPE=Debug
else
    CMAKE_BUILD_TYPE=Release
fi
CMAKE_COMMONS="-DCMAKE_VERBOSE_MAKEFILE=ON "
CMAKE_COMMONS+="-DMPIEXEC_EXECUTABLE=$(which mpiexec) "
if [[ $MOD_NAME == m100.hpc-sdk ]]; then
    CMAKE_COMMONS+="-DCMAKE_C_COMPILER_ID=PGI "
    CMAKE_COMMONS+="-DCMAKE_Fortran_COMPILER_ID=PGI "
    CMAKE_COMMONS+="-DMPI_C_COMPILER=$(which mpipgicc) "
    CMAKE_COMMONS+="-DMPI_Fortran_COMPILER=$(which mpipgifort) "
elif [[ $MOD_NAME == m100.gnu ]]; then
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
CMAKE_COMMONS+="-Dbfmv5=ON"
if [[ $VAR3D == true ]]; then

    if [[ $DOWNLOAD == true ]]; then
        echo -e "\n==== Downloading 3DVar ===="
        git clone ${GIT_CLONE_OPTIONS} --branch ${VAR3D_BRANCH} -- ${VAR3D_REPO} "${VAR3D_PATH}" || echo "An error occurred while cloning 3DVar. Skipping"
    fi
    
    cd "${VAR3D_PATH}" || exit
    cp "${ARCH}.${OS}.${FC}${DEBUG_SUFFIX}.inc" compiler.inc

    echo -e "\n==== Building 3DVar ===="
    make
    
    export DA_INCLUDE="${VAR3D_PATH}"
    export DA_LIBRARY="${VAR3D_PATH}"
    export PETSC_LIB="${PETSC_LIB}/libpetsc.so"
    CMAKE_COMMONS+="-DPETSC_LIBRARIES=${PETSC_LIB} "
    CMAKE_COMMONS+="-DPNETCDF_LIBRARIES=${PNETCDF_LIB}/libpnetcdf.a "
    cp "${OGSTM_PATH}/DataAssimilation.cmake" "${OGSTM_PATH}/CMakeLists.txt"
else
    cp "${OGSTM_PATH}/GeneralCmake.cmake" "${OGSTM_PATH}/CMakeLists.txt"
fi
cmake -LAH ${OGSTM_PATH} ${CMAKE_COMMONS}
make

echo -e "\n==== Generating namelists ===="
cp "${BFM_PATH}/build/tmp/OGS_PELAGIC/namelist.passivetrc" "${OGSTM_PATH}/bfmv5/"
cd "${OGSTM_PATH}/bfmv5/" || exit
./ogstm_namelist_gen.py

mkdir -p "${OGSTM_PATH}/ready_for_model_namelists/"
cp "${OGSTM_PATH}/src/namelists/namelist"* "${OGSTM_PATH}/ready_for_model_namelists/"
cp namelist.passivetrc_new "${OGSTM_PATH}/ready_for_model_namelists/namelist.passivetrc"
cp "${BFM_PATH}/build/tmp/OGS_PELAGIC/"*.nml "${OGSTM_PATH}/ready_for_model_namelists/"