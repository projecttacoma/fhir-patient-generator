#!/bin/bash

if [ -z "$1" ]
then
    echo 'Usage: ./release-docker-image.sh <docker-tag-version>';
    exit 1;
fi

# 1 if grep found a match (no ValueSets), 0 otherwise
VSET_SEARCH_MATCH=`curl -s http://localhost:8080/cqf-ruler-r4/fhir/ValueSet | grep -wc "\"total\":\s0"`
if [ $VSET_SEARCH_MATCH -eq 1 ]
then
    docker tag `docker commit cqf-ruler` tacoma/cqf-ruler-preloaded:$1
    echo "Successfully tagged tacoma/cqf-ruler-preloaded:$1"
    docker push tacoma/cqf-ruler-preloaded:$1
    echo "Successfully pushed tacoma/cqf-ruler-preloaded:$1 to Dockerhub"
else
    echo "Cannot push image with ValueSets, please remove them before continuing"
    exit 1
fi

