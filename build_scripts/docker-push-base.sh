#!/bin/bash
VERSION=`git branch --show-current`

#docker push fidelismachine/galileo_base:${VERSION} 
docker push fidelismachine/galileo_base:latest 
