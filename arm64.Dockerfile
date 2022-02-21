ARG ENVOY_VERSION
FROM envoyproxy/envoy-debug:$ENVOY_VERSION AS envoy

# build step for perf_to_profile fails on arm64
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

#FROM golang:latest
FROM ubuntu:20.04

#ENV GOROOT=/usr/lib/go-1.16
#ENV PATH=${PATH}:/usr/lib/go-1.16/bin

#COPY --from=perf_data_converter /usr/bin/perf_to_profile /usr/bin/perf_to_profile
COPY --from=envoy /usr/local/bin/envoy /usr/local/bin/envoy

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y graphviz \
      libelf-dev \
#      golang-1.16 \
      golang \
      git \
      linux-tools-aws linux-tools-5.8.0-1041-aws linux-image-5.8.0-1041-aws linux-headers-5.8.0-1041-aws linux-modules-5.8.0-1041-aws
RUN go get -u github.com/google/pprof

ENV PATH=${PATH}:/root/go/bin

ENTRYPOINT ["pprof", "-http=0.0.0.0:8888", "/usr/local/bin/envoy"]

RUN apt install -y ubuntu-dbgsym-keyring
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list && \
    echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" >> /etc/apt/sources.list.d/ddebs.list

RUN apt update && \
    apt install -y linux-image-5.8.0-1041-aws-dbgsym linux-image-5.11.0-1021-aws-dbgsym

# Based on https://github.com/google/perf_data_converter/issues/36#issuecomment-396161294
RUN mkdir -p /root/pprof/binaries/ab97acb15aa4ad010bb4a0b66eac96ffb4742f09
RUN ln -s /usr/lib/debug/boot/vmlinux-5.8.0-1041-aws /root/pprof/binaries/ab97acb15aa4ad010bb4a0b66eac96ffb4742f09/vmlinux

RUN mkdir -p /root/pprof/binaries/4fc029208eb7c09905d7d821909b1ab6a9a25342
RUN ln -s /usr/lib/debug/boot/vmlinux-5.11.0-1021-aws /root/pprof/binaries/4fc029208eb7c09905d7d821909b1ab6a9a25342/vmlinux

#RUN apt-get install -y libc6-dbg=2.27-3ubuntu1.4

# 2022-02-21 - Add syms for kernel 5.11.0-1022
RUN apt install -y linux-image-5.11.0-1022-aws-dbgsym
