export buildtarget="${1:-centos-7}"
mkdir -p inputArtifacts
mkdir -p outputArtifacts

export ovaname=$(find inputArtifacts -type f -iname \*${buildtarget}*ova)
