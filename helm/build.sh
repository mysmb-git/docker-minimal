#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


BLDER_VERSION="2019-07-25"

declare -a releaseversions=( $(curl https://api.github.com/repos/ansible/ansible/tags | jq -r '.[] | .name') )

for releaseversion in "${releaseversions[@]}";
do
    echo "checking if ksandermann/helm:$releaseversion already exists..."
    release_exists=$(curl https://index.docker.io/v1/repositories/ksandermann/helm/tags/$releaseversion)
    if [[ $release_exists == *"not found"* ]]; then
      #build
      HLM_VERSION=$releaseversion
      docker build \
        --pull \
        --build-arg BUILDER_VERSION=$BLDER_VERSION \
        --build-arg HELM_VERSION=$HLM_VERSION \
        -t ksandermann/helm:$HLM_VERSION \
        .
      docker push ksandermann/helm:$HLM_VERSION
      echo "sleeping 5 sec to ensure dockerhub image tags are sorted properly..."
      sleep 5
    else
      echo "skipping - ksandermann/helm:$releaseversion already exists..."
    fi
done
