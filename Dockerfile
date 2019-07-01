FROM alpine:3.9.4
RUN apk add openssh bash

COPY agent.sh /

ENTRYPOINT [ "/agent.sh" ]