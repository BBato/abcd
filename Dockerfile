# Use the full Node image to perform package install
FROM node:12-alpine AS builder
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH

ARG ARG_PORT=124
ENV PORT2 2512
ENV PORT3 $PORT2

# Copy files required for package install
COPY package.json  .
COPY yarn.lock .
RUN yarn install

# Copy the remaining assets and build the application
COPY . /usr/src/app 
RUN yarn build

# Copy files from the build stage to the smaller base image
FROM nginx:mainline-alpine
WORKDIR /usr/src/app
RUN apk --no-cache add curl 
COPY ./nginx.config /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/src/app/public /usr/share/nginx/html
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

FROM redis:latest
EXPOSE 8008/tcp
EXPOSE 25/udP 9826 
EXPOSE $PORT3
EXPOSE $ARGPORT
EXPOSE 1915
