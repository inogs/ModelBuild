# OGSTM-BFM on GPU, HowTo

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

In the following we will assume default naming of the ModelBuild, OGSTM and BFM repositories. 

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

[1:] OGSTM divide the diagnostic variable in two groups, saved to disk with different frequency.

## GPU porting strategy
