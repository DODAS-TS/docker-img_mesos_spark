FROM dodasts/mesos-spark:base

RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends openssh-server python-kazoo python-requests python-paramiko python-pip python-psutil\
    && apt-get autoremove \
    && apt-get clean \
    && pip install j2cli

# Cache script and healthcheck
RUN mkdir -p /opt/dodas \
    && mkdir -p /opt/dodas/spark
COPY cache.py /opt/dodas/
COPY entrypoint.sh /opt/dodas/spark/

RUN ln -s /opt/dodas/cache.py /usr/local/sbin/dodas_cache \
    && ln -s /opt/dodas/spark/entrypoint.sh /usr/local/sbin/dodas_spark_bastion_entrypoint

# Setup ssh
RUN sed -i -e 's/#ClientAliveInterval\ 0/ClientAliveInterval\ 600/g' /etc/ssh/sshd_config \
    # Create admin user \
    && echo "export SPARK_HOME=/opt/spark/" >> /etc/skel/.bash_profile \
    && adduser admin \
    && echo 'admin:passwd' | chpasswd \
    && usermod -aG sudo admin \
    # Fix ssh on old ubuntu and debian \
    # https://github.com/ansible/ansible-container/issues/141 \
    && mkdir -p /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ENV TARGET_SSH_PORT=31042

ENTRYPOINT [ "/usr/local/sbin/dodas_spark_bastion_entrypoint" ]
