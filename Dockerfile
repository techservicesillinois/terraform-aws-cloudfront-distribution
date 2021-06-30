FROM hashicorp/terraform:0.12.31

RUN apk add make

WORKDIR /tmp
COPY . /tmp

ENTRYPOINT [ "/usr/bin/make", "tfc" ]
