#!/usr/bin/env bash

set -euo pipefail
set -x

ARCH=$1
ENVOY_VERSION=$2
FILE="$(cd "$(dirname "$3")" && pwd -P)/$(basename "$3")"
PORT=${4:-8888}
[ -z "$ARCH" ] || [ -z "$ENVOY_VERSION" ] || [ -z "$FILE" ] && echo "usage: ./envoy-perf-pprof.sh <cpu_arch> <envoy-version> <perf-record-file> [port]" && exit 1

# We will need this image regardless as we will use it to convert the perf file to pprof format in the non-amd64 case
# Assume already built
#docker build --platform linux/amd64 -t envoy-perf-pprof-amd64-${ENVOY_VERSION} --build-arg ENVOY_VERSION=$ENVOY_VERSION -f amd64.Dockerfile .

if [[ ${ARCH} != "amd64" ]] ; then
  docker build --platform linux/${ARCH} -t envoy-perf-pprof-${ARCH}-${ENVOY_VERSION} --build-arg ENVOY_VERSION=$ENVOY_VERSION -f ${ARCH}.Dockerfile .

  # Prepare output file for mounting into container
  touch "${FILE}.pprof"

  docker run --platform linux/amd64 --rm --entrypoint /usr/bin/perf_to_profile -v $FILE:/root/envoy.perf:ro -v $FILE.pprof:/root/envoy.pprof envoy-perf-pprof-amd64-${ENVOY_VERSION} \
    -i /root/envoy.perf \
    -o /root/envoy.pprof \
    -f

  docker run --platform linux/${ARCH} --rm -p ${PORT}:8888 -v $FILE.pprof:/root/envoy.pprof:ro envoy-perf-pprof-${ARCH}-${ENVOY_VERSION} /root/envoy.pprof
else
  docker run --platform linux/${ARCH} --rm -p ${PORT}:8888 -v $FILE:/root/envoy.perf:ro envoy-perf-pprof-${ARCH}-${ENVOY_VERSION} /root/envoy.perf
fi
