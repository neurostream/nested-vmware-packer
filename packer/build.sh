#!/bin/bash

target=${1}

packer build ${1}/packer-template.json
