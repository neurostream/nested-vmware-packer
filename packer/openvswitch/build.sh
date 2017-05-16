#!/bin/bash


export buildtarget=$1

test -f getartifacts.sh && . ./getartifacts.sh $1

export ovaname=$( basename $(find inputArtifacts -type f -iname \*${buildtarget}*ova) )
export ovabasename=$( echo "${ovaname}" | awk -F '.ova' '{print $1}' )
ovftool --targetType=VMX inputArtifacts/${ovabasename}.ova inputArtifacts/${ovabasename}.vmx


packer build -force -only vmware-vmx ${buildtarget}.json

find outputArtifacts -type f -ls
test -d /openshare/artifacts && cp -r -f -v outputArtifacts/* --target-directory=/openshare/artifacts/
