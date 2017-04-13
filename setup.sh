#!/usr/bin/env bash

labHome=${HOME}/vagrant/lab
mkdir -p ${labHome}
cd ${labHome}

systemType=$(uname -s)
if [[ "${systemType}" != "Darwin" ]]
then
	echo "${systemType} system detected." 1>&2
	echo "This setup script is for Darwin (macOS / OSX )." 1>&2
	echo "Please ensure you have the following binaries in your execute PATH:" 1>&2
	echo "git" 1>&2
	echo "vagrant" 1>&2
	exit 1
fi



if ! xcode-select --print-path 2>&1 >/dev/null
	then
	if  ! git version 2>/dev/null
	then
		echo "git is required, offering XCode CLI Dev Tools. . ."
	xcode-select --install
	sleep 1
osascript <<EOD
  tell application "System Events"
    tell process "Install Command Line Developer Tools"
  end tell
EOD
	else
		echo "git appears to be installed - but not the version supplied with the XCode CLI Dev Tools "
	fi
fi

echo "Results of checking for Git:"
git version

if ! vagrant version 2>/dev/null
then
	hashiMirror="https://releases.hashicorp.com"
	vagrantURI=$(curl -s ${hashiMirror}"$(curl -s ${hashiMirror}/vagrant/ | grep -E "/vagrant/[0-9]" | sort -n | tail -1 | awk -F '\"' '{print $2}')" | grep -i dmg | awk -F 'href=' '{print $2}' | awk -F '"' '{print $2}')
	echo "vagrant was not found in the execute PATH"
	if curl -skLRO ${hashiMirror}${vagrantURI}
	then
		open $(basename ${vagrantURI})
	else
		echo "This setup routine was not able to run the Vagrant install."
		echo "Vagrant can be downloaded from ${hashiMirror}/vagrant/"
	fi
fi
