FROM dodasts/mesos-spark:base

# Setup ssh
RUN sed -i -e 's/#ClientAliveInterval\ 0/ClientAliveInterval\ 600/g' /etc/ssh/sshd_config \
    # Create admin user \
    && echo "export SPARK_HOME=/opt/spark/" \
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

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
