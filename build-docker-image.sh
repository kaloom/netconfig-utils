#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

. base-version.sh

tmpfile=$(mktemp -p .)

# cleanup on exit
trap "rm -rf ${tmpfile}" EXIT

sed -e "s/@@BASE_VERSION@@/$base_version/" Dockerfile >$tmpfile

docker build -f $tmpfile . -t kaloom/alpine:${base_version}
docker tag kaloom/alpine:${base_version} kaloom/alpine:latest
