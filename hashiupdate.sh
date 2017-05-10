#!/bin/bash

# usage
# hashiupdate.sh vagrant
# example here is vagrant. can be consul, vault, etc. - defaults to packer
localosname=$(uname | awk '{print tolower($1)}')
hashiproduct=${1:-packer}
hashimirror=https://releases.hashicorp.com
hashilatest=$(curl -skRL ${hashimirror}/${hashiproduct}/ | grep ${hashiproduct}_ | awk -F '>' '$0~/href=/{print $2}' | awk -F '<' '{print $1}' | sort -n | grep -v "\-rc" | tail -1 | awk -F '_' '{print $2}')
hashilatesturi=$(curl -skRL ${hashimirror}/${hashiproduct}/${hashilatest}/ | grep -iE "${localosname}" | grep -i 64 | awk -F 'href=' '{print $2}' | awk -F \" '{print $2}')
hashilatesturl=${hashimirror}${hashilatesturi}
echo ${hashilatesturl}
curl -skROL ${hashilatesturl} && filename=$(basename ${hashilatesturi}) && echo downloaded ${filename}
test ${filename: -4} == ".rpm" && yum -y localinstall ${filename} || unzip -o ${filename} -d /usr/local/bin/
test -f ${filename} && rm -vf ${filename}
