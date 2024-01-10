#! /usr/bin/env bash

ARCH=$(uname -m)
OS=$(uname -s | tr '[:lower:]' '[:upper:]')
ROOT=$(dirname -- "${BASH_SOURCE[0]}" | xargs realpath)

usage() {
    more << EOF
NAME
    This script download and compile the coupled OGSTM-BFM model (by default, for Leonardo with GPU support enabled).

SYNOPSIS
    usage: $0 --help
    usage: $0 [options]

DESCRIPTION
    Download options
        --download                              Download the source code from GitHub
        --clone-options     GIT_CLONE_OPTIONS   git-clone options (such as --single-branch)
        --ogstm-branch      OGSTM_BRANCH        Which branch of OGSTM tree to use (default dev_gpu)
        --bfm-branch        BFM_BRANCH          Which branch of BFM tree to use (default dev_gpu)
        --var3d-branch      VAR3D_BRANCH        Which branch of 3DVar tree to use (default dev_gpu)
	--conda-env         CONDA_ENV           Which conda environment name to use for running Python scripts (default ogstm-bfm)
    Compilation options
        --verbose                               Increases verbosity
        --fast                                  Avoids clearing cache/invoking cmake
        --skip-bfm                              Disables BFM building
        --skip-ogstm                            Disables OGSTM building
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

LONGOPTS='help,download,debug,verbose,fast,skip-bfm,skip-ogstm,var3d,clone-options:,var3d-path:,var3d-branch:,conda-env:,bfm-path:,bfm-branch:,ogstm-path:,ogstm-branch:,module-file:,build-path:'
ARGS=$(getopt --options '' --longoptions ${LONGOPTS} -- "${@}")
if [[ $? -ne 0 ]]; then
        usage
        exit 1
fi

# General settings
DOWNLOAD=false
DEBUG=false
VAR3D=false
MOD_NAME=leonardo.nvhpc
BUILD_PATH="${ROOT}/OGSTM_BUILD"
VERBOSE=false
BUILD_BFM=true
BUILD_OGSTM=true
CLEAR_CACHE=true

# BFM settings
BFM_PATH="${ROOT}/bfm"
BFM_REPO=git@github.com:BFM-Community/BiogeochemicalFluxModel.git
BFM_BRANCH=dev_gpu

# OGSTM settings
OGSTM_REPO=git@github.com:inogs/ogstm.git
OGSTM_BRANCH=dev_gpu
OGSTM_PATH="${ROOT}/ogstm"
CONDA_ENV=ogstm-bfm

# VAR3D settings
VAR3D_REPO=git@gitlab.hpc.cineca.it:OGS/3DVar.git
VAR3D_BRANCH=Multivariate
VAR3D_PATH=3DVar

eval "set -- ${ARGS}"
while true; do
    case "${1}" in
        (--verbose)
            VERBOSE=true
            shift
        ;;
        (--fast)
            CLEAR_CACHE=false
            shift
        ;;
        (--skip-bfm)
            BUILD_BFM=false
            shift
        ;;
        (--skip-ogstm)
            BUILD_OGSTM=false
            shift
        ;;
        (--debug)
            DEBUG=true
            DEBUG_SUFFIX=.dbg
            shift
        ;;
        (--download)
	        DOWNLOAD=true
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

if [[ $BUILD_BFM == true || $BUILD_OGSTM == true ]]; then
    echo -e "\n==== Sourcing ${MOD_NAME} ===="
    source "$ROOT/ogstm/compilers/machine_modules/${MOD_NAME}" || :
fi

if [[ $BUILD_BFM == true ]]; then
    echo -e "\n==== Building BFM ===="
    export BFM_INC=${BFM_PATH}/include
    export BFM_LIB=${BFM_PATH}/lib
    cd "${BFM_PATH}/build" || exit
    
    if [[ $CLEAR_CACHE == true ]]; then
        BFM_OPTIONS="-gc"
    else
        BFM_OPTIONS="-fc"
    fi
    if [[ $VERBOSE == true ]]; then
        BFM_OPTIONS="${BFM_OPTIONS}v"
    fi
    ./bfm_configure.sh ${BFM_OPTIONS} -o ../lib/libbfm.a -p OGS_PELAGIC -a ${ARCH}.${OS}.${FC}${DEBUG_SUFFIX}.inc
fi

if [[ $BUILD_OGSTM == true ]]; then
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
    if [[ $MOD_NAME == leonardo.nvhpc ]]; then
        CMAKE_COMMONS+="-DCMAKE_C_COMPILER_ID=PGI "
        CMAKE_COMMONS+="-DCMAKE_Fortran_COMPILER_ID=PGI "
        CMAKE_COMMONS+="-DMPI_C_COMPILER=$(which mpicc) "
        CMAKE_COMMONS+="-DMPI_Fortran_COMPILER=$(which mpif90) "
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
    
    if [[ $CLEAR_CACHE == true ]]; then
        OGSTM_CMAKE_OPTIONS=
        if [[ $VERBOSE == true ]]; then
            OGSTM_CMAKE_OPTIONS=-LAH
        fi
        cmake ${OGSTM_CMAKE_OPTIONS} ${OGSTM_PATH} ${CMAKE_COMMONS}
    fi
    make
fi

if [[ $BUILD_OGSTM == true && $CLEAR_CACHE == true ]]; then
   echo -e "\n==== Generating namelists ===="
   cp "${BFM_PATH}/build/tmp/OGS_PELAGIC/namelist.passivetrc" "${OGSTM_PATH}/bfmv5/"
   cd "${OGSTM_PATH}/bfmv5/" || exit
   conda run -n ${CONDA_ENV} python ogstm_namelist_gen.py
   
   mkdir -p "${OGSTM_PATH}/ready_for_model_namelists/"
   cp "${OGSTM_PATH}/src/namelists/namelist"* "${OGSTM_PATH}/ready_for_model_namelists/"
   cp namelist.passivetrc_new "${OGSTM_PATH}/ready_for_model_namelists/namelist.passivetrc"
   cp "${BFM_PATH}/build/tmp/OGS_PELAGIC/"*.nml "${OGSTM_PATH}/ready_for_model_namelists/"
fi
