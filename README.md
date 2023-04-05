# How to download and build OGSTM-BFM

```
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
```
