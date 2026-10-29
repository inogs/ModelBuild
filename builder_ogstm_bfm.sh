#! /bin/bash

#      builder_ogstm_bfm.sh

#      Edit the file builder_config.inc in this directory to configure compilation and linking
#      (the file is ignored when the build is part of an OPA chain)

# is_chain_compilation and the other functions shared with the downloader
source "$(dirname "${BASH_SOURCE[0]}")/chain_utils.sh"

if is_chain_compilation ; then
   # The configuration comes from the variables of the chain; the environment
   # (compilers and libraries) is the one of the chain, so no module is loaded
   OGSTM_ARCH=$OPA_ARCH
   OGSTM_OS=${OPA_OS^^}    # the names of the *.inc files use LINUX, the chain linux
   OGSTM_COMPILER=$OPA_COMPILER
   DEBUG=
   export OPENMP_FLAG=
   OCEANVAR=true
   DEBUG_OCEANVAR=
   # The *.inc files for the chain are the ones with this suffix
   CHAIN_INC_SUFFIX=.opa_chain
   # Compilers, cmake and libraries of the spack environment of the chain, as
   # the module file would set them; they are needed by cmake for ogstm (the
   # *.inc files of the other components set them by themselves)
   SPACK_VIEW=$OPA_HOME/HOST/$OPA_HOSTNAME/spack_env/.spack-env/view
   export I_MPI_ROOT=$SPACK_VIEW/mpi/latest
   export PATH=$SPACK_VIEW/oneapi-compilers/compiler/latest/bin:$I_MPI_ROOT/bin:$SPACK_VIEW/bin:$PATH
   for LIBNAME in NETCDF NETCDFF PNETCDF PETSC ; do
      export ${LIBNAME}_INC=$SPACK_VIEW/include
      export ${LIBNAME}_LIB=$SPACK_VIEW/lib
   done
   cd $OPA_HOME/HOST/$OPA_HOSTNAME
else
   source "$(modelbuild_dir)/builder_config.inc"
fi


usage() {
echo "SYNOPSYS"
echo "Build BFM and ogstm model"
echo "builder_ogstm_bfm.sh [ BFMDIR ] [ OGSTMDIR ]"
echo ""
echo " Dirs have to be expressed as full paths "
echo "EXAMPLE"
echo " ./builder_ogstm_bfm.sh $PWD/bfm $PWD/ogstm "

}

if [ $# -eq 1 ] || [ $# -gt 2 ]; then
   usage
   exit 1
fi

if [ $# -eq 2 ] ; then
   BFMDIR=$1
   OGSTMDIR=$2
else
   BFMDIR=$PWD/bfm
   OGSTMDIR=$PWD/ogstm
   BIOPTIMOD_3STREAM_DIR=$PWD/Forward_Adjoint
   OASIM_DIR=$PWD/OASIM
fi





# -------------- 3d_var _____
if [ $OCEANVAR == true ] ; then
   cd 3DVar
   INC_FILE=${OGSTM_ARCH}.${OGSTM_OS}.${OGSTM_COMPILER}${DEBUG_OCEANVAR}${CHAIN_INC_SUFFIX}.inc
   cp $INC_FILE compiler.inc
   # make clean
   gmake
   if [ $? -ne 0 ] ; then  echo  ERROR; exit 1 ; fi
   export DA_INC=$PWD
   echo DA_INC= $DA_INC
fi

# ----------- BFM library ---------------------
cd $BFMDIR
A=`svn info 2>&1 `  # exit status 1 if bfmv5
if [ $? == 0 ] ; then 
   BFMversion=BFMv2
else
   BFMversion=bfmv5
fi

INC_FILE=${OGSTM_ARCH}.${OGSTM_OS}.${OGSTM_COMPILER}${DEBUG}${CHAIN_INC_SUFFIX}.inc

if [ $BFMversion == BFMv2 ] ; then
   cd ${BFMDIR}/compilers
   cp $INC_FILE compiler.inc

   ###################################################### just because R1.3 does not have include/
   mkdir -p  ${BFMDIR}/include

   cd ${BFMDIR}/build
   ./config_BFM.sh -a ${OGSTM_ARCH} -c ogstm
   cd BLD_OGSTMBFM
   # make clean
   gmake

else
   # in-place replace the entire ARCH line
   sed -i "s/.*ARCH.*/        ARCH    = '$INC_FILE'  /"  build/configurations/OGS_PELAGIC/configuration
   cd $BFMDIR/build
   ./bfm_configure.sh -gcv -o ../lib/libbfm.a -p OGS_PELAGIC
   if [ $? -ne 0 ] ; then  echo  ERROR; exit 1 ; fi
fi

export BFM_INC=${BFMDIR}/include
export BFM_LIB=${BFMDIR}/lib


###### BIOPTIMOD SECTION ###############
cd $BIOPTIMOD_3STREAM_DIR/src
INC_FILE=${OGSTM_ARCH}.${OGSTM_OS}.${OGSTM_COMPILER}${DEBUG}${CHAIN_INC_SUFFIX}.inc
cp $INC_FILE compiler.inc
make
if [ $? -ne 0 ] ; then  echo  ERROR in $PWD; exit 1 ; fi
make libadj.a
export BIOPTIMOD_3STREAM_INCLUDE=$BIOPTIMOD_3STREAM_DIR/include
export BIOPTIMOD_3STREAM_LIBRARY=$BIOPTIMOD_3STREAM_DIR/lib

##########################################


## OASIM SECTION #####
cd $OASIM_DIR
if [ "$OGSTM_COMPILER" == intel ]; then
    COMPILERNAME=intel
else
    COMPILERNAME=gcc
fi


if [ "$DEBUG" == .dbg ] ; then
    VERSION=debug
else
    VERSION=release
fi

BUILDFILE=build_${VERSION}_${COMPILERNAME}${CHAIN_INC_SUFFIX}.sh
OASIM_BUILD=builds/${VERSION}_${COMPILERNAME}
bash $BUILDFILE
cd $OASIM_BUILD
make
if [ $? -ne 0 ] ; then  echo  ERROR in $PWD; exit 1 ; fi
export OASIM_ATM_INCLUDE=$OASIM_DIR/$OASIM_BUILD/modules
export OASIM_ATM_LIBRARY=$OASIM_DIR/$OASIM_BUILD/OASIMlib

##########################




CMAKE=1

cd $OGSTMDIR/..
if [ $CMAKE -eq 1 ] ; then
  # ------------ new OGSTM builder based on cmake -----------------
        if [[ $DEBUG == .dbg ]] ; then
           CMAKE_BUILD_TYPE=Debug
           OGSTM_BLD_DIR=OGSTM_BUILD_DBG
        else
           CMAKE_BUILD_TYPE=Release
           OGSTM_BLD_DIR=OGSTM_BUILD
        fi
	export BFM_INCLUDE=$BFM_INC
	export BFM_LIBRARY=$BFM_LIB


	mkdir -p $OGSTM_BLD_DIR
	cd $OGSTM_BLD_DIR

    if is_chain_compilation ; then
    # Intel oneAPI: ifx and icx, with the Intel MPI wrapper mpiifx
    CMAKE_COMMONS=" -DCMAKE_VERBOSE_MAKEFILE=ON -DMPI_Fortran_COMPILER=mpiifx -DCMAKE_Fortran_COMPILER=ifx -DCMAKE_C_COMPILER=icx -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "
    # The dependencies are searched only among the files of ogstm: the Fortran
    # scanner of cmake does not understand the include guards of the PETSc
    # headers (#if !defined(...)), and it would include them recursively forever
    CMAKE_COMMONS+=" -DCMAKE_DEPENDS_IN_PROJECT_ONLY=ON "
    elif [ "$OGSTM_COMPILER" == intel ] ; then
    CMAKE_COMMONS=" -DCMAKE_VERBOSE_MAKEFILE=ON -DMPI_Fortran_COMPILER=mpiifort -DCMAKE_C_COMPILER=icc -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "
    else
    CMAKE_COMMONS=" -DCMAKE_VERBOSE_MAKEFILE=ON -DMPI_Fortran_COMPILER=mpif90 -DCMAKE_C_COMPILER=gcc -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} "
    fi
    CMAKE_COMMONS+=" -DNETCDF_INCLUDES_C=$NETCDF_INC -DNETCDF_LIBRARIES_C=$NETCDF_LIB/libnetcdf.so -DNETCDFF_INCLUDES_F90=$NETCDFF_INC -DNETCDFF_LIBRARIES_F90=$NETCDFF_LIB/libnetcdff.so"
    CMAKE_COMMONS+=" -D${BFMversion}=ON"

	if [ $OCEANVAR == true ] ; then
	    export DA_INCLUDE=$DA_INC
	    export DA_LIBRARY=$DA_INC
	    export PETSC_LIB=$PETSC_LIB/libpetsc.so

	    cp ../ogstm/DataAssimilation.cmake ../ogstm/CMakeLists.txt
        cmake ../ogstm/ $CMAKE_COMMONS -DPETSC_LIBRARIES=$PETSC_LIB -DPNETCDF_LIBRARIES=$PNETCDF_LIB/libpnetcdf.a

	else
	    cp ../ogstm/GeneralCmake.cmake ../ogstm/CMakeLists.txt
	    echo $CMAKE_COMMONS
	    cmake ../ogstm/ $CMAKE_COMMONS

	fi
    make
else

  # ----------- standard OGSTM builder -----------------

	cd ${OGSTMDIR}/compilers
	INC_FILE=${OGSTM_ARCH}.${OGSTM_OS}.${OGSTM_COMPILER}${DEBUG}.inc
	cp $INC_FILE compiler.inc

	cd ${OGSTMDIR}/build
	./config_OGSTM.sh ${OGSTM_ARCH}
	cd BLD_OGSTM
	make clean
	make -f MakeLib
	rm -f get_mem_mod.o
	gmake

fi

if [ $? -ne 0 ] ; then  echo  ERROR; exit 1 ; fi

# In an OPA chain the executable is used from $OPA_HOME/HOST/$OPA_HOSTNAME/bin,
# through a symbolic link: a new build updates it immediately
if is_chain_compilation ; then
   mkdir -p $OPA_HOME/HOST/$OPA_HOSTNAME/bin
   ln -sfn $OGSTMDIR/../$OGSTM_BLD_DIR/ogstm.xx $OPA_HOME/HOST/$OPA_HOSTNAME/bin/ogstm.xx
fi

### OGSTM NAMELIST GENERATION (also by Frequency Control )

mkdir -p ${OGSTMDIR}/ready_for_model_namelists/

if [ $BFMversion == bfmv5 ] ; then
   cp ${BFMDIR}/build/tmp/OGS_PELAGIC/namelist.passivetrc ${OGSTMDIR}/bfmv5/
   cd ${OGSTMDIR}/bfmv5/
   if is_chain_compilation ; then
      # Python of the conda environment of the chain; its bin directory is added
      # only for this command, since it contains also other tools (mpif90, ...)
      PATH=$OPA_HOME/HOST/$OPA_HOSTNAME/python_env/bin:$PATH ./ogstm_namelist_gen.py #generates namelist.passivetrc_new
   else
      ./ogstm_namelist_gen.py #generates namelist.passivetrc_new
   fi

   cp ${OGSTMDIR}/src/namelists/namelist*    ${OGSTMDIR}/ready_for_model_namelists/
   cp namelist.passivetrc_new                ${OGSTMDIR}/ready_for_model_namelists/namelist.passivetrc #overwriting
   cp ${BFMDIR}/build/tmp/OGS_PELAGIC/*.nml  ${OGSTMDIR}/ready_for_model_namelists/
else
   #V2
   cp ${OGSTMDIR}/src/namelists/namelist*    ${OGSTMDIR}/ready_for_model_namelists/
   cp ${BFMDIR}/src/namelist/*.nml           ${OGSTMDIR}/ready_for_model_namelists/
fi
