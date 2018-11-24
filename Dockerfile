# Build image
FROM swift:4.2 as builder

RUN apt-get -qq update && apt-get -q -y install postgresql postgresql-client postgresql-contrib libpq-dev

WORKDIR /app

COPY . .

RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so /build/lib
RUN swift test
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
  postgresql postgresql-client postgresql-contrib libpq-dev netcat wget \
  && rm -r /var/lib/apt/lists/*


COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/

# set up entrypoint scripts
COPY scripts/wait-for.sh .
COPY scripts/entrypoint.sh .

RUN chmod +x ./wait-for.sh \
    && chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]