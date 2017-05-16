export buildtarget="${1:-centos-7}"
mkdir -p inputArtifacts
mkdir -p outputArtifacts

export ovaname=$(find inputArtifacts -type f -iname \*${buildtarget}*iso)
if [ -n "${ovaname}" ]
then
	export isoname=$( basename "${isoname}" )
else
	export isoname=$(curl -skRL "${isobaseurl}" | grep -i "${buildtarget}" | grep -i minimal | grep -i .iso | awk -F '\"' '{print $2}')
	if [ -f /tmp/"${isoname}" ]
	then
		cp /tmp/"${isoname}" inputArtifacts/
	else
	 	curl -kLRo inputArtifacts/"${isoname}" "${isobaseurl}/${isoname}"
	fi
fi

test -f /tmp/linux.iso && cp -v /tmp/linux.iso inputArtifacts/
