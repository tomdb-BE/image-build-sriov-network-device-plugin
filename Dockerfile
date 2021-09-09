ARG TAG="v3.3.2"
ARG UBI_IMAGE
ARG GO_IMAGE

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin
WORKDIR sriov-network-device-plugin
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
RUN make clean && make build

# Create the sriov-network-device-plugin image
FROM ${UBI_IMAGE}
WORKDIR /
RUN yum update -y          && \
    yum install -y hwdata  && \
    rm -rf /var/cache/yum
COPY --from=builder /go/sriov-network-device-plugin/build/sriovdp /usr/bin/
COPY --from=builder /go/sriov-network-device-plugin/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
