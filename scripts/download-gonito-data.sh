#!/usr/bin/bash

if ! command -v wget &> /dev/null; then
	echo "wget missing: (apt install wget)"
	exit
fi

wget https://gonito.net/gitlist/asr-corrections.git/zipball/master -O asr-corrections.zip
# srsly? yep, that's all this does
