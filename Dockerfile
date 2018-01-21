FROM centos:7
USER root

MAINTAINER vichoudh@redhat.com

RUN yum install -y epel-release
RUN yum install -y jq-devel.x86_64

RUN yum install -y net-tools make which rsync lshw docker-client openssh-clients libcurl.i686
RUN \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1
# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

# Define working directory.
WORKDIR /gopath/src/sfc-dev-plugin

COPY . .
RUN go build -o sfc-nic-plugin
RUN cp sfc-nic-plugin /usr/bin/sfc-nic-plugin \
&& cp *.sh /usr/bin

ENTRYPOINT ["/usr/sbin/init"]
