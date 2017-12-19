##############################################################################
# Dockerfile to build Atlassian Bamboo Agent container images
# Based on Debian (https://hub.docker.com/r/_/debian/)
##############################################################################

FROM debian:stretch-slim

MAINTAINER Oliver Wolf <root@streacs.com>

ARG APPLICATION_RELEASE
ARG APPLICATION_SERVER

ENV JAVA_VERSION_MAJOR=8
ENV JAVA_VERSION_MINOR=152
ENV JAVA_VERSION_BUILD=16
ENV JAVA_VERSION_PATH=aa0333dd3019491ca4f6ddbe78cdb6d0

ENV JAVA_HOME=/opt/jdk

ENV APPLICATION_INST /opt/atlassian/bamboo
ENV APPLICATION_HOME /var/opt/atlassian/application-data/bamboo

ENV SYSTEM_USER bamboo
ENV SYSTEM_GROUP bamboo

ENV DEBIAN_FRONTEND noninteractive

RUN set -x \
  && apt-get update \
  && apt-get -y --no-install-recommends install wget

RUN set -x \
  && wget -q --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_VERSION_PATH}/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  && mkdir -p ${JAVA_HOME} \
  && tar xfz /tmp/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz --strip-components=1 -C ${JAVA_HOME} \
  && update-alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
  && rm /tmp/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz

RUN set -x \
  && addgroup --system ${SYSTEM_GROUP} \
  && adduser --system --ingroup ${SYSTEM_GROUP} ${SYSTEM_USER}

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