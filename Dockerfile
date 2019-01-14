FROM indigodatacloud/mesos-master:1.7.0

# Spark 2.3.1 with BigDL 0.7.0 on Python 3
ARG SPARK_URI=http://www-eu.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz

ENV DEBIAN_FRONTEND noninteractive

# set default java environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends language-pack-en \
        python3-kazoo \
        python3-pip \
        python3-numpy \
        python3-six \
        python3-setuptools \
        software-properties-common \
        sudo \
        wget \
        unzip \
    && add-apt-repository ppa:openjdk-r/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-8-jre-headless \
    # workaround for bug on ubuntu 14.04 with openjdk-8-jre-headless
    # re-install ca-certificates-java
    && dpkg --purge --force-depends ca-certificates-java \ 
    && apt-get install -y --no-install-recommends ca-certificates-java \
    && apt-get -y autoremove \
    && apt-get clean \
    && mkdir -p /opt/dodas \
    && mkdir -p /opt/dodas/spark \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install bigdl

COPY entrypoint_base.sh /opt/dodas/spark/
COPY configure_spark.sh /opt/dodas/spark/
COPY mesos_master4spark.py /opt/dodas/spark/

RUN ln -s /opt/dodas/spark/configure_spark.sh /usr/local/sbin/configure_spark \
    && ln -s /opt/dodas/spark/mesos_master4spark.py /usr/local/sbin/mesos_master4spark \
    && ln -s /opt/dodas/spark/entrypoint_base.sh /usr/local/sbin/dodas_spark_base_entrypoint

RUN locale-gen en_US.UTF-8 \
    && wget https://security.fi.infn.it/CA/mgt/INFN-CA-2015.pem \
    && keytool -importcert -storepass changeit  -noprompt -trustcacerts -alias infn -file INFN-CA-2015.pem -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts

WORKDIR /opt/

RUN wget $SPARK_URI  \
    && mkdir spark \
    && tar -xvzf spark-2.3.1-bin-hadoop2.7.tgz -C spark --strip-components 1 \
    && ln --force -s /opt/spark/bin/sparkR /usr/local/bin/sparkR \
    && ln --force -s /opt/spark/bin/spark-submit /usr/local/bin/spark-submit \
    && ln --force -s /opt/spark/bin/spark-sql /usr/local/bin/spark-sql \
    && ln --force -s /opt/spark/bin/spark-shell /usr/local/bin/spark-shell \
    && ln --force -s /opt/spark/bin/spark-class /usr/local/bin/spark-class \
    && ln --force -s /opt/spark/bin/pyspark /usr/local/bin/pyspark \
    && rm spark-2.3.1-bin-hadoop2.7.tgz \
    && rm -R bin conf lib

WORKDIR /

ENV SPARK_HOME=/opt/spark
ENV PYSPARK_PYTHON=python3
ENV MESOS_NATIVE_JAVA_LIBRARY=/usr/local/lib/libmesos.so
ENV SPARK_EXECUTOR_URI=$SPARK_URI

ENTRYPOINT [ "/usr/local/sbin/dodas_spark_base_entrypoint" ]
