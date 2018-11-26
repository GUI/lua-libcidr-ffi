FROM openresty/openresty:1.13.6.2-2-centos

# Build dependencies.
RUN yum -y install make

# Dependencies for the release process.
RUN yum -y install git zip

RUN mkdir /app
WORKDIR /app

COPY Makefile /app/Makefile
RUN make install-deps-source-yum
RUN make install-deps-source
RUN make install-test-deps

ENV LD_LIBRARY_PATH=/usr/local/lib

COPY . /app
