FROM alpine AS builder

ENV VERSION 2.8.3

RUN apk update && \
    apk add git make g++ cmake \
        libuv-dev libmicrohttpd-dev openssl-dev --no-cache && \
    rm -rf /var/cache/apk/

RUN git clone https://github.com/xmrig/xmrig.git && \
    cd xmrig && \
    git checkout v$VERSION && \
    sed -i -e 's/constexpr const int kMinimumDonateLevel = 1;/constexpr const int kMinimumDonateLevel = 0;/g' src/donate.h && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

FROM alpine

RUN apk add libuv-dev libmicrohttpd-dev openssl-dev --no-cache && \
    rm -rf /var/cache/apk/

COPY --from=builder /xmrig/build/xmrig /usr/local/bin/xmrig
COPY entrypoint.sh /usr/local/bin/xmrig.sh

ENTRYPOINT ["xmrig.sh"]
