#!/usr/bin/bash

if ! command -v fstprint &> /dev/null; then
	echo "fstprint missing (apt install libfst-tools)"
fi
if [ "$#" -ne 2 ];then
	echo "Usage: get_model_syms.sh [fst] [output.txt]"
fi
fstprint --save_osymbols=$2 $1

