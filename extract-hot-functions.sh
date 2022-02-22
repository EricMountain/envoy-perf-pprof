#!/usr/bin/env bash

set -euo pipefail
set -x

ARCH=$1
ENVOY_VERSION=$2
FILE="$(cd "$(dirname "$3")" && pwd -P)/$(basename "$3")"
[ -z "${ARCH}" ] || [ -z "${ENVOY_VERSION}" ] || [ -z "${FILE}" ] && echo "usage: ./envoy-perf-pprof.sh <cpu_arch> <envoy-version> <perf-record-file>" && exit 1

# Assume already built
#docker build --platform "linux/${ARCH}" -t "envoy-perf-pprof-${ARCH}-${ENVOY_VERSION}" --build-arg ENVOY_VERSION="${ENVOY_VERSION}" -f "${ARCH}.Dockerfile" .

docker run --platform "linux/${ARCH}" --rm --entrypoint /bin/bash -v "${FILE}":/root/perf.data:ro "envoy-perf-pprof-${ARCH}-${ENVOY_VERSION}" -c "/lib/linux-tools/5.11.0-1022-aws/perf script --no-demangle -i /root/perf.data" > "${FILE}.functions.txt" #\
#  | gawk '/[/]usr[/]local[/]bin[/]envoy/ {print $7}' | cut -d+ -f1 | sort -u
