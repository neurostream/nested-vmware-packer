#!/bin/bash

datestamp=$(date "+%Y%m%d%H%M%S")

rm -vrf packer_cache CentOS-7-x86_64-Minimal-1611*box output-vmware-iso *-iso.ova

time VERSION=v${datestamp} ISOBASENAME=CentOS-7-x86_64-Minimal-1611 packer build -force -only vmware-iso CentOS_7.json

unalias cp
cp -f -v CentOS*vmware* /openshare/artifacts/
