#!/bin/bash

docker image prune -f
docker build -t gnat_base -f Dockerfile .

