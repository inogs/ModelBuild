#! /bin/bash

#      chain_utils.sh

#      Functions shared by downloader_ogstm_bfm.sh and builder_ogstm_bfm.sh,
#      to be loaded with:
#         source "$(dirname "${BASH_SOURCE[0]}")/chain_utils.sh"


# Absolute paths of the directory of this file and of the directory of the
# running script (the last element of BASH_SOURCE), computed once when this
# file is sourced: BASH_SOURCE may hold paths relative to the working directory
# at launch time, that are no longer valid after a cd.
_CHAIN_UTILS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
_CHAIN_SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[-1]}")" && pwd -P)


is_chain_compilation() {
# Returns 0 (true) if the build is part of an OPA chain installation, that is
# if OPA_HOME and OPA_HOSTNAME are defined and the running script lies inside
# $OPA_HOME/HOST/$OPA_HOSTNAME; returns 1 (false) otherwise.
# The paths are compared after resolving the symbolic links.
local host_dir
if [ -z "$OPA_HOME" ] || [ -z "$OPA_HOSTNAME" ] ; then
   return 1
fi
host_dir=$(cd "$OPA_HOME/HOST/$OPA_HOSTNAME" 2>/dev/null && pwd -P) || return 1
[[ "$_CHAIN_SCRIPT_DIR" == "$host_dir" || "$_CHAIN_SCRIPT_DIR" == "$host_dir"/* ]]
}


modelbuild_dir() {
# Prints the absolute path of the ModelBuild directory, that is the directory
# that contains this file (and the builder, the downloader and their
# configuration files), whatever the current working directory is.
# The path is printed as given (symbolic links are not resolved).
echo "$_CHAIN_UTILS_DIR"
}
