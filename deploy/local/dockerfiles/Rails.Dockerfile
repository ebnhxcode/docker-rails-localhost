FROM ruby:2.5.8-alpine

# Local deps
RUN apk update \
  && apk upgrade \
  && apk add --update --no-cache \
  build-base curl-dev git sqlite-dev postgresql-dev postgresql-client \
  yaml-dev zlib-dev tzdata nodejs \
  bash git nano curl htop

WORKDIR /app

COPY ./deploy/local/.env /app/

COPY ./deploy/local/bin/install-rails.sh /usr/local/bin/install-rails
RUN chmod +x /usr/local/bin/install-rails

COPY ./deploy/local/bin/craft-app.sh /usr/local/bin/craft-app
RUN chmod +x /usr/local/bin/craft-app

COPY ./deploy/local/bin/bundle-deps.sh /usr/local/bin/bundle-deps
RUN chmod +x /usr/local/bin/bundle-deps

COPY ./deploy/local/bin/init-app.sh /usr/local/bin/init-app
RUN chmod +x /usr/local/bin/init-app


# RUN ln -sf /proc/1/fd/1 /app/log/development.log
