# syntax=docker/dockerfile:1

# Build the checklist binary for the target platform.
FROM --platform=$BUILDPLATFORM golang:1.27-bookworm AS build
ARG TARGETOS
ARG TARGETARCH
ARG VERSION=dev
WORKDIR /src/checklist
COPY checklist/go.mod checklist/go.sum ./
RUN go mod download
COPY checklist/ ./
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/checklist .

# Runtime: bash and GNU tools for the scripts, the catalog, and the binary.
# Intended for the dashboard and for offline network configuration audits;
# host checks inspect the machine they run on, so run them on the host itself.
FROM debian:bookworm-slim
ARG VERSION=dev
LABEL org.opencontainers.image.title="secbaseline" \
      org.opencontainers.image.description="Security hardening checks, compliance reports and drift detection" \
      org.opencontainers.image.source="https://github.com/Khanh1916/secbaseline" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}"

RUN useradd --system --uid 10001 --no-create-home --home-dir /opt/secbaseline secbaseline \
    && mkdir -p /data && chown secbaseline /data

WORKDIR /opt/secbaseline
COPY controls.yaml README.md LICENSE ./
COPY ubuntu ubuntu
COPY debian debian
COPY redhat redhat
COPY rocky rocky
COPY centos centos
COPY suse suse
COPY oraclelinux oraclelinux
COPY windows windows
COPY iosxe iosxe
COPY junos junos
COPY iosxr iosxr
COPY nxos nxos
COPY policies policies
COPY --from=build /out/checklist checklist/checklist

USER secbaseline
VOLUME /data
EXPOSE 8080
ENTRYPOINT ["/opt/secbaseline/checklist/checklist"]
CMD ["--help"]
