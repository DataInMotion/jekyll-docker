FROM ruby:3.1.1-alpine3.15
LABEL maintainer "Guido Grune <g.grune@datainmotion.com>"
# based on "Jordon Bedwell <jordon@envygeeks.io>" Dockerfile in envygeeks/jekyll-docker
COPY copy /

#
# EnvVars
# Ruby
#

ENV BUNDLE_HOME=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle
ENV BUNDLE_DISABLE_PLATFORM_WARNINGS=true
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_BIN=/usr/gem/bin
ENV GEM_HOME=/usr/gem
ENV RUBYOPT=-W0

#
# EnvVars
# Image
#

ENV JEKYLL_VAR_DIR=/var/jekyll
ENV JEKYLL_DOCKER_TAG=latest
ENV JEKYLL_VERSION=4.2.2
ENV JEKYLL_DOCKER_NAME=jekyll
ENV JEKYLL_DATA_DIR=/srv/jekyll
ENV JEKYLL_BIN=/usr/jekyll/bin
ENV JEKYLL_ENV=development

#
# EnvVars
# System
#

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=America/Chicago
ENV PATH="$JEKYLL_BIN:$PATH"
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US

#
# EnvVars
# Main
#

env VERBOSE=false
env FORCE_POLLING=false
env DRAFTS=false

#
# Packages
# Dev
#

RUN apk --no-cache add \
  zlib-dev \
  build-base \
  libxml2-dev \
  imagemagick-dev \
  readline-dev \
  libxslt-dev \
  libffi-dev \
  yaml-dev \
  vips-dev \
  vips-tools \
  sqlite-dev \
  cmake

RUN apk --no-cache add \
  openjdk11-jre \
  less \
  git \
  zlib \
  libxml2 \
  readline \
  libxslt \
  libffi \
  tzdata \
  shadow \
  bash \
  su-exec \
  libressl \
  yarn

#
# Gems
# Update
#

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN unset GEM_HOME && unset GEM_BIN && \
  yes | gem update --system

#
# Gems
# Main
#

RUN unset GEM_HOME && unset GEM_BIN && yes | gem install --force bundler
RUN gem install jekyll -v $JEKYLL_VERSION -- \
    --use-system-libraries
#
# Remove dev 
#
RUN apk --no-cache del \
  zlib-dev \
  build-base \
  libxml2-dev \
  imagemagick-dev \
  readline-dev \
  libxslt-dev \
  libffi-dev \
  yaml-dev \
  vips-dev \
  vips-tools \
  sqlite-dev \
  cmake


RUN addgroup -Sg 1000 jekyll
RUN adduser  -Su 1000 -G \
  jekyll jekyll

RUN mkdir -p $JEKYLL_VAR_DIR
RUN mkdir -p $JEKYLL_DATA_DIR
RUN chown -R jekyll:jekyll $JEKYLL_DATA_DIR
RUN chown -R jekyll:jekyll $JEKYLL_VAR_DIR
RUN chown -R jekyll:jekyll $BUNDLE_HOME
RUN rm -rf /home/jekyll/.gem
RUN rm -rf $BUNDLE_HOME/cache
RUN rm -rf $GEM_HOME/cache
RUN rm -rf /root/.gem

# Work around rubygems/rubygems#3572
RUN mkdir -p /usr/gem/cache/bundle
RUN chown -R jekyll:jekyll \
  /usr/gem/cache/bundle

CMD ["jekyll", "--help"]
ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
WORKDIR /srv/jekyll
VOLUME  /srv/jekyll
EXPOSE 35729
EXPOSE 4000
