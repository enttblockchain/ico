#FROM node:7.4-alpine
FROM node:8.11.1-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apk add -t .gyp --no-cache git python g++ make \
    && npm install -g truffle@4.0.6 \
    && apk del .gyp

ENTRYPOINT ["truffle"]
