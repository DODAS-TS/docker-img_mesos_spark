FROM indigodatacloud/mesos-master:latest

RUN locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

# set default java environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends openssh-server python-pip python-setuptools software-properties-common wget \
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

WORKDIR /opt/

RUN wget http://www-eu.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz  \
    && mkdir /spark \
    && tar -xvzf spark-2.3.1-bin-hadoop2.7.tgz -C /spark --strip-components 1 \
    && rm spark-2.3.1-bin-hadoop2.7.tgz \
    && ln -s /opt/spark/bin/sparkR /usr/local/bin/sparkR \
    && ln -s /opt/spark/bin/spark-submit /usr/local/bin/spark-submit \
    && ln -s /opt/spark/bin/spark-sql /usr/local/bin/spark-sql \
    && ln -s /opt/spark/bin/spark-shell /usr/local/bin/spark-shell \
    && ln -s /opt/spark/bin/spark-class /usr/local/bin/spark-class \
    && ln -s /opt/spark/bin/pyspark /usr/local/bin/pyspark \
    && wget http://tarballs.openstack.org/sahara/dist/hadoop-openstack/master/hadoop-openstack-3.0.1.jar -P /opt/spark/jars/

WORKDIR /

ENV SPARK_HOME /opt/spark/

# Setup ssh keys
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
    && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa \
    && ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa \
    && ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519 \
    && sed -i -e 's/#ClientAliveInterval\ 0/ClientAliveInterval\ 600/g' /etc/ssh/sshd_config \
    # Create admin user
    && adduser admin \
    && echo 'admin:passwd' | chpasswd \
    && usermod -aG wheel admin

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

