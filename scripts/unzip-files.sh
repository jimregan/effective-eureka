#!/usr/bin/bash

for i in Clarin*.zip;do 
	b=$(basename $i '.zip')
	mkdir $b
	pushd $b
	unzip ../$b.zip
	popd
done
unzip Sejm.zip
