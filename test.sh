#! /usr/bin/env bash

DEBUG=false
OCEANVAR=false
ARGS=$(getopt --options 'dv' --longoptions 'debug,oceanvar' -- "${@}")

if [ $? -ne 0 ]; then
        echo 'Usage: ./builder_ogstm_bfm.sh [-d|--debug] [-v|--oceanvar] modulefile'
        exit 1
fi
eval "set -- ${ARGS}"

while true; do
    case "${1}" in
        (-d | --debug)
            DEBUG=true
            shift
        ;;
        (-v | --oceanvar)
	    OCEANVAR=true
            shift
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

remaining_args=("${@}")

echo "DEBUG=$DEBUG"
echo "OCEANVAR=$OCEANVAR"
echo "POS=${remaining_args[@]}"

