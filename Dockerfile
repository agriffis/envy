FROM gliderlabs/alpine:3.2
RUN apk --update add bash curl go git mercurial

RUN curl -Ls https://github.com/progrium/execd/releases/download/v0.1.0/execd_0.1.0_Linux_x86_64.tgz \
    | tar -zxC /bin \
  && curl -Ls https://github.com/progrium/entrykit/releases/download/v0.2.0/entrykit_0.2.0_Linux_x86_64.tgz \
    | tar -zxC /bin \
  && curl -s https://get.docker.io/builds/Linux/x86_64/docker-1.6.2 > /bin/docker \
  && chmod +x /bin/docker \
  && entrykit --symlink

ADD ./data /tmp/data

ENV GOPATH /go
COPY . /go/src/github.com/progrium/envy
WORKDIR /go/src/github.com/progrium/envy
RUN go get && CGO_ENABLED=0 go build -a -installsuffix cgo -o /bin/envy \
  && ln -s /bin/envy /bin/enter \
  && ln -s /bin/envy /bin/auth \
  && ln -s /bin/envy /bin/serve

VOLUME /envy
EXPOSE 22 80
ENTRYPOINT ["codep", "/bin/execd -e -k /tmp/data/id_host /bin/auth /bin/enter", "/bin/serve"]
