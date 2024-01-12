# HowTo: OGSTM-BFM on GPU

## Where to find the code

OGSTM-BFM is a transport-reaction coupled model, the code for the transport model (OGSTM) is located at

https://github.com/inogs/ogstm

the reaction model (BFM) can be found at

https://github.com/BFM-Community/BiogeochemicalFluxModel

Both these pieces of software are opensource. However, the access to the BFM repository is restricted and you have to be added as collaborator. Otherwise, you can obtain a copy by sending a request, via the homepage of the BFM consortium

https://bfm-community.github.io/www.bfm-community.eu/

## How to download and build the code

The code can be downloaded and built via the bash script provided in this repository. To build the GPU version, you have to checkout the `dev_gpu`.

```
git clone -b dev_gpu git@github.com:inogs/ModelBuild.git
cd ModelBuild
./build.sh [--download] [--debug]
```

The script will clone by default the `dev_gpu` branch of both OGSTM and BFM, then build the project. The script has several options, which can be accessed using `./build.sh --help`

    NAME
        This script download and compile the coupled OGSTM-BFM model (by default, for Leonardo with GPU support enabled).

    SYNOPSIS
        usage: ./build.sh --help
        usage: ./build.sh [options]

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
            --build-path        BUILD_PATH          Where to build OGSTM-BFM (relative to the location of ./build.sh, default OGSTM_BUILD)
            --ogstm-path        OGSTM_PATH          Where to look for the OGSTM source (relative to the location of ./build.sh, default ogstm)
            --bfm-path          BFM_PATH            Where to look for the BFM source (relative to the location of ./build.sh, default bfm)
        Other options
            --help                                  Shows this help

The `--download` option is needed just the first time. You can increase the verbosity using `--verbose`, which is useful for debug purpose and might helpful for understanding the building process. You can specify the path of the code containing OGSTM and BFM code with `--ogstm-path` and `--bfm-path` respectively. You can build OGSTM-BFM at different paths using the `--build-path` option, this is useful, for example, to have several coexisting versions for debugging, testing and benchmarking purposes. Debug flags can be enabled using `--debug`.

Finally, notice that by default the build script will throw all the cache files and build the project from scratch. OGSTM-BFM can be easily customized, using configuration files, and to do so it leverage the build system and some Perl scripts, which generate Fortran code starting from template files. This is one of the reasons why the build script throws away all cached files by default. If you don't touch the template files in you development version, you can greatly speedup the compilation by using the `--fast` option. Clearly, the `--fast` flag **cannot** be used the first time the project is built.

At the moment, the only way to setup the compilation flags for the project is to manually edit few files. These are `${OGSTM_PATH}/GeneralCmake.cmake` file for OGSTM and `${BFM_PATH}/compilers/${ARCH}.${OS}.${FC}${DEBUG_SUFFIX}.inc` for BFM, where `${OGSTM_PATH}` and `${BFM_PATH}` are the paths of the OGSTM and BFM repositories respectively, and `${ARCH}`, `${OS}`, `$FC`, and `${DEBUG_SUFFIX}` are the architecture, OS name, Fortran compiler name and debug suffix for a particular build.

Hence, for example, to enforce floating-point operations in strict conformance with the IEEE 754 standard in a debug version, using the PGI compiler on a Linux x86_64 machine, in a directory tree with default folder names, you have to add the `--Kieee` flag in relevant lines within `ogstm/GeneralCmake.cmake` and `bfm/compilers/x86_64.LINUX.pgf90.dbg.inc`.

An `environment.yml` file is provided with OGSTM, and a Conda environment with the listed packages installed should be created before the building process. The default name of the environment is `ogstm-bfm`.

## Structure of the code

In the following we will assume default naming of the ModelBuild, OGSTM and BFM repositories. Hence the directory tree should look like the following

    ModelBuild
    ├── bfm
    │   ├── bin
    │   ├── build
    │   ├── compilers
    │   ├── doc
    │   ├── include
    │   ├── lib
    │   ├── logs
    │   ├── run
    │   ├── src
    │   └── tools
    └── ogstm
        ├── application
        ├── bfmv5
        ├── bin
        ├── cmake
        ├── compilers
        ├── logs
        ├── preproc
        ├── ready_for_model_namelists
        ├── src
        └── testcase

The relevant source code for OGSTM is under `ModelBuild/ogstm/src`

    ogstm/src
    ├── BC
    ├── BIO
    ├── DA
    ├── General
    ├── IO
    ├── MPI
    ├── namelists
    └── PHYS

While for 
BFM, the most important pieces of code are under `ModelBuild/bfm/src/BFM`

    bfm/src/BFM
    ├── BenBio
    ├── CO2
    ├── Forcing
    ├── General
    ├── include
    ├── Light
    ├── Pel
    ├── PelBen
    └── Seaice

In particular, the main routines are defined in `General`, `PHYS`, and `BIO`. The first contains `ogstm.f90` and `step.f90`, which implements the program logic (initialization, stepping and finalization) and the time stepping routine respectively. `PHYS` contains, among the others, the sources for advection (`trcadv.f90`), horizontal diffusion (`trhdf.f90`), and vertical diffusion (`trzdf.f90`). `BIO` contains the wrapper around BFM. The interface between the two pieces of software is defined in `ogstm/src/BIO/trcbio.f90` and in `bfm/src/ogstm`, within the latter the relevant files are `BFM1D_Input_Ecology.F90` and `BFM1D_Output_Ecology.F90`. In particular, `BFM1D_Output_Ecology.F90` is generated via Perl, starting from the template `bfm/scripts/proto/BFM1D_Output_Ecology.proto`.




Excluding minor complications and details, the logic of the whole OGSTM-BFM is the following

```
initialize OGSTM
while simulation time is less than stopping time {
    if simulation time is a restart time {
        write restart files
    }
    if simulation time is a diagnostic dump time {
        dump diagnostics on files 
    } 
    compute advection trend
    compute newtonian damping trend
    compute horizontal diffusion trend
    compute surface processes trend
    compute biogeochemical reactor trend {
        compute optical model trend
        compute ecology dynamics trend {
            copy inputs to BFM
            compute sea ice dynamics
            compute plagic system dynamics {
                compute oxygen saturation and air-sea flux
                compute phytoplankton dynamics
                compute bacteria dynamics
                compute meso-zooplankton dynamics
                compute micro-zooplankton dynamics
                compute pelagic chemistry dynamics {
                    compute carbonate system dynamics
                }
            }
            compute benthic dynamics
            copy back the results to OGSTM
        }
        compute sedimentation model trend
    }
    compute vertical diffusion trend implicitly
    compensate water mass balance
    apply boundary conditions
    compute new state from trend
    exchange ghost cells
    compute averages
}
finalize OGSTM
```

At the moment of writing, the routines that have been ported to GPU are the advection routine (contained in `ogstm/src/PHYS/trcadv.f90`), the ghost cell exchange routine (in `ogstm/src/MPI/ogstm_mpi.f90`), the meso-zooplankton routine (in `bfm/src/BFM/Pel/MesoZoo.F90`), the micro-zooplankton routine (in `bfm/src/BFM/Pel/MicroZoo.F90`), and the pelagic chemistry routine (in `bfm/src/BFM/Pel/PelChem.F90`), with the exclusion of the carbonate system dynamics routine (in `bfm/src/BFM/CO2/CarbonateSystem.F90`), which will require a full re-write, since it is **not** written as element-wise, array operations. The phytoplankton routine (in `bfm/src/BFM/Pel/Phyto.F90`) has been partially offloaded on GPU.

Let's focus on the BFM section of the time stepping loop. 

The main two objects in memory on which BFM operates are the `D3STATE` and the `D3SOURCE`, which are multidimensional arrays having two indices, one for the point of the domain and one for the biogeochemical variable under consideration. `D3STATE` represent the current state of the system, while `D3SOURCE` the trend due to biogeochemical processes. For the whole BFM, `D3STATE` serves as input and `D3SOURCE` as output. There are also variables holding diagnostics (`D2DIAGNOS` and `D3DIAGNOS`) and fluxes (like `D3FLUX_MATRIX`). All these objects are defined within `bfm/src/General/ModuleMem.F90`. Since many (but not all) biogeochemical variables are conserved, most of the time one is subtracting a certain quantity (_flux_) from one column and adding the same quantity to another column of `D3STATE`. This operation is so common that a few special functions are defined in `bfm/src/BFM/General/FluxFunctions.h90`, these are `flux_vector` and `quota_flux`. Most code paths of both have been ported to GPU.

Other Almost all the execution time is spent within the pelagic system dynamic routine (`bfm/src/BFM/Pel/PelagicSystem.F90`).  

The order of the routines called within the latter does not matter, with the exclusion of the pelagic chemistry dynamics, which must be the last one to be executed. Indeed, the latter will read some values from the trend and diagnostic variables to compute its own trend term.

The immediate objective of the GPU migration is to fully port every routine called within the pelagic system routine to GPU, such that only one synchronization of `D3STATE` and `D3SOURCE` are needed respectively at the beginning and at the end of the pelagic system routine.

```
compute plagic system dynamics {
    # update device
    compute oxygen saturation and air-sea flux
    compute phytoplankton dynamics
    compute bacteria dynamics
    compute meso-zooplankton dynamics
    compute micro-zooplankton dynamics
    compute pelagic chemistry dynamics {
        compute carbonate system dynamics
    }
    # update host
}
```

## How to generate and run a test

OGSTM is shipped with some Python scripts to generate user defined, self contained testcases. The scripts, the configuration file and the required data are all under `ogstm/testcase`. The main configuration file, within this directory, is `TEST_LIST.dat`. Each line of the file represent a test. A `TEST_LIST.dat_template` file is provided as an example. 

The first three columns (`Nx`, `Ny`, and `Nz`) specify the size of the whole simulated domain. This will be decomposed horizontally and processed by the number of MPI processes specified in the fourth and fifth column (`nprocx` and `nprocy`). The next four columns are used to specify the size and location of the simulated domain (`lon0`, `lat0`, `dx`, and `dy`), while the next two (`Start` and `End`) are the date and time of the simulated time interval. By default, the timestep is 30 minutes. The last two columns (`Directory` and `Code`) contains respectively the path of the testcase directory (if it does not exist, it will be created), and the path to the parent of `ogstm` (`ModelBuild`, in this case). 

The tests are created invoking the Python script `Main_create_TEST.py` from the `ogstm/testcase` directory, i.e. `conda run -n ogstm-bfm Main_create_TEST.py`. The testcase directory will contain a few Fortran namelist files, containing parameters and switches. For example, from `namelist.init` one can set the timestep in seconds, `rdt`, turn on and off certain routines (i.e. the advection, with `ladv`, or bfm, with `lbfm`), or set after how many timesteps to print to stdout execution time statistics, with `nwritetrc`. The configuration files `1.aveTimes` and `2.aveTimes` contain the list of simulation times in which diagnostic variables are outputted[^1].

The same directory contains also the restarts, forcings and boundary conditions. Finally, it contains a symbolic link to `ogstm.xx`, the executable of the model. Notice that, if you built the project in a different directory than default `ModelBuild/OGSTM_BUILD`, than the link will be broken.

Now, it is possible to run the test. You'll need to load a few modules, a system specific list of modules is provided for several machines and these files are located at `ogstm/compilers/machine_modules`. For Leonardo, running a testcase named `TEST` using `N` processes

```
# From ModelBuild
source ogstm/compilers/machine_modules/leonardo.nvhpc
export RANKS_PER_NODE=N
cd ogstm/testcase/TEST || exit
mpirun -np $RANKS_PER_NODE ./ogstm.xx
```

The variable `RANKS_PER_NODE` has to be defined, and must be equal to the number of MPI processes declared in the `TEST_LIST.dat` file (`nprocx` times `nprocy`) and stored within the `domdec.txt` file, included in the testcase directory. If the two are different, the process will exit with an error.

You can compare that your results match between a GPU accelerated and non-accelerated version of your code, comparing to the bit level the outputs in `AVE_FREQ_1` and `AVE_FREQ_2` directories. To do so, you'll need two different OGSTM-BFM binaries and run the tests in separate folders (with the same settings).

A simple Python script is provided to compare the files included in these directories, `ogstm/testcase/scripts/comparedatasets.py`. 

[^1]: OGSTM divide the diagnostic variable in two groups, saved to disk with different frequency.
