#!/usr/bin/env bash

systemType=$(uname -a)
if [[ "${systemType}" != "Darwin" ]]
then
	echo "${systemType} system detected." 1>&2
	echo "This setup script is for Darwin (macOS / OSX )." 1>&2
	echo "Please ensure you have the following binaries in your execute PATH:" 1>&2
	echo "git and vagrant installed" 1>&2
	exit 1
fi

xcode-select --install
sleep 1
osascript <<EOD
  tell application "System Events"
    tell process "Install Command Line Developer Tools"
      keystroke return
      click button "Agree" of window "License Agreement"
    end tell
  end tell
EOD
