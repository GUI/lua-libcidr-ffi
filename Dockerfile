FROM openresty/openresty:1.13.6.2-2-centos

RUN yum -y install gcc make

RUN mkdir /app
WORKDIR /app

COPY Makefile /app/Makefile
RUN make install-test-deps

COPY . /app
