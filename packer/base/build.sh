#!/bin/bash


export buildtarget=$1

test -f getartifacts.sh && . ./getartifacts.sh $1

export isoname=$( basename $(find inputArtifacts -type f -iname \*${buildtarget}*iso) )
export isobasename=$( echo "${isoname}" | awk -F '.iso' '{print $1}' )

export datestamp=$(date "+%Y%m%d%H%M%S")
export version="v${datestamp}"



echo "buildtarget is ${buildtarget}"
echo "datestamp is ${datestamp}"
echo "version is ${version}"
echo "isoname is ${isoname}"
echo "isobasename is ${isobasename}"


rm -vrf packer_cache ${isobasename}*box output-vmware-iso *-iso.ova

packer build -force -only vmware-iso ${buildtarget}.json

find outputArtifacts -type f -ls
test -d /openshare/artifacts && cp -r -f -v outputArtifacts/* --target-directory=/openshare/artifacts/
