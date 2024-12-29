#!/bin/bash

docker image prune -f
docker build --no-cache -t fidelismachine/galileo_base -f Dockerfile .

