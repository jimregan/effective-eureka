#!/usr/bin/bash

pip3 install -q git+https://github.com/awslabs/mlm-scoring
pip3 install -q mxnet-cu101

wget http://poleval.pl/task1/Poleval2020Task1Eval.tar.xz
tar xvf Poleval2020Task1Eval.tar.xz

