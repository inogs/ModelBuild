# Installing

You will need the [Anaconda Python distribution](https://www.anaconda.com/products/individual). On many systems that is already installed: try running `conda --version`.
If that fails, you may need to load an anaconda module first: try `module load anaconda` or `module load anaconda3`. If that still does not give you a working `conda` command,
you may want to install [Miniconda](https://docs.conda.io/en/latest/miniconda.html).

Now make sure your conda environment is initialized:

```
conda init bash
```

This needs to be done just once, as it modifies your `.bashrc` that is sourced every time you login.
After this, restart your shell by logging out and back in.

*If `conda init bash` asks you for your password (it tries to do "sudo"), it is likely because the permissions on your `~/.bashrc` file are incorrect.*
In that case, contact your system administrator to have these permissions corrected.
You may in the meantime be able to continue these instructions by executing `eval "$(conda shell.bash hook)"` - but this then needs to be done every time your login.

Now obtain the repository with setups and scripts:

```
conda env create -f environment.yml
conda activate ogstm-fabm
bash ./my_install
```

# Staying up to date

To update this repository *including its submodules (FABM, ERSEM, PISCES, etc.)*, make sure you are in the `seamless-notebooks` directory and execute:

```
conda activate ogstm-fabm
git pull --recurse-submodules
git submodule update --init --recursive
conda env update -f environment.yml
bash ./my_install
```

The last two commands update the conda (Python) environment and GOTM-FABM, respectively.
Depending on the changes in the repository, they may not be needed, but there is no harm in running them just in case - it just takes a little longer.

