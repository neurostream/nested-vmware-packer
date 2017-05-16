#!/bin/bash


export buildtarget=$1

test -f getartifacts.sh && . ./getartifacts.sh $1

packer build -force -only vmware-vmx ${buildtarget}.json

ls -lartd CentOS*vmware* rpm/*rpm 
test -d /openshare/artifacts && cp -r -f -v outputArtifacts/* --target-directory=/openshare/artifacts/
