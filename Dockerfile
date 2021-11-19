ARG ENVOY_VERSION
FROM envoyproxy/envoy-debug:$ENVOY_VERSION AS envoy

FROM ubuntu:20.04 AS perf_data_converter

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y npm g++ git libelf-dev libcap-dev
RUN npm install -g @bazel/bazelisk

#RUN git clone https://github.com/google/perf_data_converter.git /usr/src/perf_data_converter
RUN git clone https://github.com/EricMountain/perf_data_converter.git -b pin-protobuf /usr/src/perf_data_converter
WORKDIR /usr/src/perf_data_converter

RUN bazel build src:perf_to_profile
RUN cp bazel-bin/src/perf_to_profile /usr/bin/.

#FROM golang:latest
FROM ubuntu:20.04

#ENV GOROOT=/usr/lib/go-1.16
#ENV PATH=${PATH}:/usr/lib/go-1.16/bin

COPY --from=perf_data_converter /usr/bin/perf_to_profile /usr/bin/perf_to_profile
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
