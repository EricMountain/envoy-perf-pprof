# This is for the case where the Envoy image already contains debug symbols, e.g. those images we build ourselves


# build step for perf_to_profile fails on arm64, so the scripts will use the amd64 image to do the conversion
#FROM ubuntu:20.04 AS perf_data_converter
#
#RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y npm g++ git libelf-dev libcap-dev
#RUN npm install -g @bazel/bazelisk
#
##RUN git clone https://github.com/google/perf_data_converter.git /usr/src/perf_data_converter
#RUN git clone https://github.com/EricMountain/perf_data_converter.git -b pin-protobuf /usr/src/perf_data_converter
#WORKDIR /usr/src/perf_data_converter
#
#RUN bazel build src:perf_to_profile
#RUN cp bazel-bin/src/perf_to_profile /usr/bin/.

ARG ENVOY_VERSION
FROM eu.gcr.io/datadog-staging/envoy:$ENVOY_VERSION AS envoy


# Can't use the Envoy image itself because it's ubuntu:18.04, so we can't get perf for the right kernel version
FROM ubuntu:20.04

COPY --from=envoy /usr/local/bin/* /usr/local/bin
#COPY --from=perf_data_converter /usr/bin/perf_to_profile /usr/bin/perf_to_profile

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y graphviz \
      libelf-dev \
      git \
      linux-tools-aws \
      software-properties-common

# We need go 1.18 for pprof
#RUN add-apt-repository ppa:longsleep/golang-backports \
#    && apt update \
#    && apt install -y golang-go
#ENV PATH=${PATH}:/root/go/bin
#RUN go install github.com/google/pprof@latest
#ENTRYPOINT ["pprof", "-http=0.0.0.0:8888", "/usr/local/bin/envoy"]

# Kernel debug symbol linking based on https://github.com/google/perf_data_converter/issues/36#issuecomment-396161294

RUN apt install -y ubuntu-dbgsym-keyring && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list

#RUN apt update && \
#    apt install -y linux-image-5.11.0-1022-aws-dbgsym
#
#RUN mkdir -p /root/pprof/binaries/5097c1d9a7d4e106af27b40509743c7b0ce6df9e
#RUN ln -s /usr/lib/debug/boot/vmlinux-5.11.0-1022-aws /root/pprof/binaries/5097c1d9a7d4e106af27b40509743c7b0ce6df9e/vmlinux

#RUN apt update && \
#    apt install -y linux-image-5.13.0-1017-aws-dbgsym
#
#RUN mkdir -p /root/pprof/binaries/5097c1d9a7d4e106af27b40509743c7b0ce6df9e
#RUN ln -s /usr/lib/debug/boot/vmlinux-5.13.0-1017-aws /root/pprof/binaries/5097c1d9a7d4e106af27b40509743c7b0ce6df9e/vmlinux
#
RUN apt update && apt install -y linux-tools-5.13.0-1017-aws linux-image-5.13.0-1017-aws linux-headers-5.13.0-1017-aws linux-modules-5.13.0-1017-aws
#
## Gets ignored if it's the wrong version?
#RUN apt-get install -y libc6-dbg
