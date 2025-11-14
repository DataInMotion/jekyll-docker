FROM ruby:3.4.7-alpine3.22
LABEL maintainer="Guido Grune <g.grune@datainmotion.com>"
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
ENV JEKYLL_VERSION=4.4.1
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

ENV VERBOSE=false
ENV FORCE_POLLING=false
ENV DRAFTS=false

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
  openjdk21-jre \
  less \
  git \
  openssh \
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
RUN unset GEM_HOME && unset GEM_BIN && yes | gem install bundler -v 2.7.2

# Install gems that were removed from Ruby 3.x stdlib but are required by Jekyll
RUN gem install csv webrick logger base64 bigdecimal mutex_m

RUN gem install jekyll -v $JEKYLL_VERSION -- \
    --use-system-libraries
#
# Remove dev 
#
#RUN apk --no-cache del \
#  zlib-dev \
#  build-base \
#  libxml2-dev \
#  imagemagick-dev \
#  readline-dev \
#  libxslt-dev \
#  libffi-dev \
#  yaml-dev \
#  vips-dev \
#  vips-tools \
#  sqlite-dev \
#  cmake


RUN addgroup -Sg 1000 jekyll
RUN adduser  -Su 1000 -G jekyll jekyll

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

RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PermitUserEnvironment yes' >> /etc/ssh/sshd_config
RUN echo -n 'root:jekyll' | chpasswd

# Set up environment for SSH sessions
RUN echo 'export BUNDLE_HOME=/usr/local/bundle' >> /root/.profile && \
    echo 'export BUNDLE_APP_CONFIG=/usr/local/bundle' >> /root/.profile && \
    echo 'export BUNDLE_BIN=/usr/local/bundle/bin' >> /root/.profile && \
    echo 'export GEM_BIN=/usr/gem/bin' >> /root/.profile && \
    echo 'export GEM_HOME=/usr/gem' >> /root/.profile && \
    echo 'export JEKYLL_BIN=/usr/jekyll/bin' >> /root/.profile && \
    echo 'export PATH=$JEKYLL_BIN:$BUNDLE_BIN:$GEM_BIN:$PATH' >> /root/.profile && \
    echo 'export JEKYLL_VAR_DIR=/var/jekyll' >> /root/.profile && \
    echo 'export JEKYLL_DATA_DIR=/srv/jekyll' >> /root/.profile && \
    echo 'export JEKYLL_ENV=development' >> /root/.profile

# Also set up .bashrc for interactive shells
RUN cp /root/.profile /root/.bashrc

# Create SSH environment file for non-login shells (Jenkins uses this)
RUN mkdir -p /root/.ssh && \
    echo "PATH=$JEKYLL_BIN:$BUNDLE_BIN:$GEM_BIN:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /root/.ssh/environment && \
    echo "BUNDLE_HOME=$BUNDLE_HOME" >> /root/.ssh/environment && \
    echo "BUNDLE_APP_CONFIG=$BUNDLE_APP_CONFIG" >> /root/.ssh/environment && \
    echo "BUNDLE_BIN=$BUNDLE_BIN" >> /root/.ssh/environment && \
    echo "GEM_BIN=$GEM_BIN" >> /root/.ssh/environment && \
    echo "GEM_HOME=$GEM_HOME" >> /root/.ssh/environment && \
    echo "JEKYLL_BIN=$JEKYLL_BIN" >> /root/.ssh/environment && \
    echo "JEKYLL_VAR_DIR=$JEKYLL_VAR_DIR" >> /root/.ssh/environment && \
    echo "JEKYLL_DATA_DIR=$JEKYLL_DATA_DIR" >> /root/.ssh/environment && \
    echo "JEKYLL_ENV=$JEKYLL_ENV" >> /root/.ssh/environment

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

#USER jekyll
CMD ["/usr/sbin/sshd", "-D"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
WORKDIR /srv/jekyll
VOLUME  /srv/jekyll
EXPOSE 22
EXPOSE 35729
EXPOSE 4000
