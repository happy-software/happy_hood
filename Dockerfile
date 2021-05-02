# Use an official Ruby runtime as a parent image
FROM ruby:2.5.1
LABEL maintainer="Hebron George <hebrontgeorge@gmail.com>"

ENV APP_DIR="/app/"
RUN mkdir $APP_DIR
WORKDIR $APP_DIR

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y libpq-dev nodejs jq

# Try doing the bundle stuff first
COPY Gemfile Gemfile.lock $APP_DIR

# Note: this is a manual step
# unset bundler because old docker image sets bundler version
ENV BUNDLER_VERSION="2.2.16"
RUN gem install bundler -v 2.2.16 && \
  bundle install

# Copy the current directory contents into the container at /app
COPY . $APP_DIR
