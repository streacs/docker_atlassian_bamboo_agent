##############################################################################
# Dockerfile to build Atlassian Bamboo Agent container images
# Based on Debian (https://hub.docker.com/r/_/debian/)
##############################################################################

FROM debian:stretch-slim

MAINTAINER Oliver Wolf <root@streacs.com>

ARG APPLICATION_RELEASE
ARG APPLICATION_SERVER

ENV APPLICATION_INST /opt/atlassian/bamboo
ENV APPLICATION_HOME /var/opt/atlassian/application-data/bamboo

ENV SYSTEM_USER bamboo
ENV SYSTEM_GROUP bamboo
ENV SYSTEM_HOME /home/bamboo

ENV DEBIAN_FRONTEND noninteractive

RUN set -x \
  && mkdir /usr/share/man/man1
  
RUN set -x \
  && apt-get update \
  && apt-get -y --no-install-recommends install wget procps ca-certificates git ruby-rspec ssh apt-transport-https gnupg2 \
  && gem install serverspec

RUN set -x \
  && wget -qO - https://packages.chef.io/chef.asc | apt-key add - \
  && echo "deb https://packages.chef.io/repos/apt/stable jessie main" > /etc/apt/sources.list.d/chef-stable.list \
  && apt-get update \
  && apt-get -y --no-install-recommends install chefdk

RUN set -x \
  && wget -qO - https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLI_RELEASE}-ce.tgz  -O /tmp/docker-${DOCKER_CLI_RELEASE}-ce.tgz \
  && tar xfz /tmp/docker-${DOCKER_CLI_RELEASE}-ce.tgz --strip-components=1 -C /usr/bin/ \
  && rm /tmp/docker-${DOCKER_CLI_RELEASE}-ce.tgz

RUN set -x \
  && addgroup --system ${SYSTEM_GROUP} \
  && adduser --system --home ${SYSTEM_HOME} --ingroup ${SYSTEM_GROUP} ${SYSTEM_USER}

RUN set -x \
  && mkdir -p ${APPLICATION_INST} \
  && mkdir -p ${APPLICATION_HOME} \
  && wget --no-check-certificate -nv -O /tmp/atlassian-bamboo-agent-installer.jar ${APPLICATION_SERVER}/agentServer/agentInstaller/atlassian-bamboo-agent-installer.jar \
  && java -Dbamboo.home=${APPLICATION_INST} -jar /tmp/atlassian-bamboo-agent-installer.jar ${APPLICATION_SERVER}/agentServer install \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${APPLICATION_INST} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${APPLICATION_HOME} \
  && rm /tmp/atlassian-bamboo-agent-installer.jar

RUN set -x \
  && apt-get clean \
  && rm -rf /var/cache/* \
  && rm -rf /tmp/*

RUN set -x \
  && touch -d "@0" "${APPLICATION_INST}/conf/wrapper.conf"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint
ADD files/healthcheck /usr/local/bin/healthcheck
ADD files/bamboo-capabilities.properties ${APPLICATION_INST}/bin/bamboo-capabilities.properties
ADD rspec-specs ${SYSTEM_HOME}/

VOLUME ${APPLICATION_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${SYSTEM_USER}

RUN set -x \
  && /usr/bin/chef gem install kitchen-docker

WORKDIR ${SYSTEM_HOME}

HEALTHCHECK --interval=5s --timeout=3s CMD /usr/local/bin/healthcheck

CMD ["/usr/local/bin/service"]
