#!/usr/bin/env bash

systemType=$(uname -s)
if [[ "${systemType}" != "Darwin" ]]
then
	echo "${systemType} system detected." 1>&2
	echo "This setup script is for Darwin (macOS / OSX )." 1>&2
	echo "Please ensure you have the following binaries in your execute PATH:" 1>&2
	echo "git and vagrant installed" 1>&2
	exit 1
fi



if ! xcode-select --print-path 
	then
	if [[ ! git version ]]
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

if [[ ! vagrant version ]]
then
	hashiMirror="https://releases.hashicorp.com"
	vagrantURI=$(curl -s ${hashiMirror}"$(curl -s ${hashiMirror}/vagrant/ | grep -E "/vagrant/[0-9]" | sort -n | tail -1 | awk -F '\"' '{print $2}')" | grep -i dmg | awk -F 'href=' '{print $2}' | awk -F '"' '{print $2}')
	echo "vagrant was not found in the PATH. It can be downloaded from ${hashiMirror}${vagrantURI}"
	curl -LRO ${hashiMirror}${vagrantURI} && open disk://$(basename ${vagrantURI})
fi
