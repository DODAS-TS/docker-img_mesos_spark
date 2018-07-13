FROM indigodatacloud/mesos-master:latest

RUN locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

# set default java environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends python-pip python-setuptools software-properties-common wget \
    && add-apt-repository ppa:openjdk-r/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-8-jre-headless \
    # workaround for bug on ubuntu 14.04 with openjdk-8-jre-headless
    # re-install ca-certificates-java
    && dpkg --purge --force-depends ca-certificates-java \ 
    && apt-get install -y --no-install-recommends ca-certificates-java \
    && apt-get autoremove \
    && apt-get clean



RUN wget https://security.fi.infn.it/CA/mgt/INFN-CA-2015.pem \
    && keytool -importcert -storepass changeit  -noprompt -trustcacerts -alias infn -file INFN-CA-2015.pem -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts

RUN wget https://www.apache.org/dyn/closer.lua/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz \
    && mkdir /spark \
    && tar xfz spark-2.3.1-bin-hadoop2.7.tgz -C /spark --strip-components 1 \
    && rm spark-2.3.1-bin-hadoop2.7.tgz

RUN wget http://tarballs.openstack.org/sahara/dist/hadoop-openstack/master/hadoop-openstack-3.0.1.jar -P /spark/jars/

RUN pip install j2cli

ENV SPARK_HOME /spark

COPY core-site.xml.j2 /spark/core-site.xml.j2
COPY spark-defaults.conf.j2 /spark/spark-defaults.conf.j2

COPY entrypoint.sh /spark/entrypoint.sh

RUN chmod 755 /spark/entrypoint.sh

WORKDIR /spark

ENTRYPOINT ["/spark/entrypoint.sh"]

