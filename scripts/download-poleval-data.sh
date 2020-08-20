#!/usr/bin/bash

if ! command -v wget &> /dev/null; then
	echo "wget missing: (apt install wget)"
	exit
fi

wget http://poleval.pl/task1/ClarinPlTrain.zip http://poleval.pl/task1/ClarinPlTest.zip http://poleval.pl/task1/ClarinPlDev.zip http://poleval.pl/task1/Sejm.zip
# srsly? yep, that's all this does
