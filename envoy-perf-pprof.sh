#!/usr/bin/env bash

set -euo pipefail

ARCH=$1
ENVOY_VERSION=$2
FILE="$(cd "$(dirname "$3")" && pwd -P)/$(basename "$3")"
[ -z "$ARCH" ] || [ -z "$ENVOY_VERSION" ] || [ -z "$FILE" ] && echo "usage: ./envoy-perf-pprof.sh <cpu_arch> <envoy-version> <perf-record-file>" && exit 1

docker build --platform linux/${ARCH} -t envoy-perf-pprof-${ARCH}-${ENVOY_VERSION} --build-arg ENVOY_VERSION=$ENVOY_VERSION .
docker run --platform linux/${ARCH} --rm -p 8888:8888 -v $FILE:/root/envoy.perf envoy-perf-pprof-${ARCH}-${ENVOY_VERSION} /root/envoy.perf

