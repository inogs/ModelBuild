#      builder_config.inc

#      Edit sections 1,2,3,4 in order to configure compilation and linking.

###################################################################
#  Section 1. Choose the *.inc file, with the definition of compiler flags, to be included in Makefile
#
#             This is a machine dependent operation, flags for
#             most popular compilers (gnu, intel, xl) are provided.
#             In the following example user will select the file x86_64.LINUX.intel.dbg.inc
#             both in bfm/compilers/ and ogstm/compilers

OGSTM_ARCH=x86_64
OGSTM_OS=LINUX
OGSTM_COMPILER=intel
DEBUG=       # this is the choice for production flags
#DEBUG=.dbg   # this is the one for debug flags


###################################################################
#  Section 2. Use of OpenMP threads, to improve the parallelization of ogstm.
# Just comment one of thes lines:
export OPENMP_FLAG=-fopenmp  # OpenMP activated
export OPENMP_FLAG=          # OpenMP deactivated


###################################################################
# Section 3.  Module loads (and set of environment variables)

# This is a machine dependent operation. Modules are usually used on clusters.
# User can write his module file, in the directory below there are some examples.
# Warning : this choice must be consistent with Section 1.

# Just comment the two following lines you are not using modules.
export MODULEFILE=$PWD/ogstm/compilers/machine_modules/g100.intel
source $MODULEFILE


###################################################################
# Section 4.  Oceanvar inclusion in model
# Set OCEANVAR=true         to include oceanvar.
#     DEBUG_OCEANVAR=.dbg   to use debug flags

OCEANVAR=true
DEBUG_OCEANVAR=
###################################################################
