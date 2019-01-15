FROM indigodatacloudapps/mesos-spark:base

ENV SPARK_URI=http://www-eu.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends openssh-server python3-requests python3-paramiko python3-psutil\
    && apt-get autoremove \
    && apt-get clean \
    && pip3 install j2cli

# Cache script and healthcheck
COPY cache.py /opt/dodas/
COPY entrypoint_bastion.sh /opt/dodas/spark/
COPY spark-run.sh /opt/dodas/spark/

RUN ln -s /opt/dodas/cache.py /usr/local/sbin/dodas_cache \
    && ln -s /opt/dodas/spark/entrypoint_bastion.sh /usr/local/sbin/dodas_spark_bastion_entrypoint \
    && ln -s /opt/dodas/spark/spark-run.sh /usr/local/sbin/spark-run

# Setup ssh
RUN sed -i -e 's/#ClientAliveInterval\ 0/ClientAliveInterval\ 600/g' /etc/ssh/sshd_config \
    # Create admin user
    && adduser admin \
    && echo 'admin:passwd' | chpasswd \
    && usermod -aG sudo admin \
    && echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/admin \
    # Fix ssh on old ubuntu and debian \
    # https://github.com/ansible/ansible-container/issues/141 \
    && mkdir -p /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ENV TARGET_SSH_PORT=31042

ENTRYPOINT [ "/usr/local/sbin/dodas_spark_bastion_entrypoint" ]
