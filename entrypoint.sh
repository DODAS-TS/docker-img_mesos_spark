#!/usr/bin/env bash

echo "==> Prepare admin keys"
ssh-keygen -q -t rsa -N '' -f /home/admin/.ssh/id_rsa
echo "==> Public admin key"
dodas_cache zookeeper TARGET_PUB_KEY "$(< /home/admin/.ssh/id_rsa.pub)"
dodas_cache zookeeper TARGET_PRIV_KEY "$(< /home/admin/.ssh/id_rsa)"
echo "==> Add authorized key"
cat /home/admin/.ssh/id_rsa.pub > /home/admin/.ssh/authorized_keys
chmod go-rw /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
export NETWORK_INTERFACE=$(hostname -i)
echo "==> Public target host"
dodas_cache zookeeper TARGET_HOST "$NETWORK_INTERFACE"
echo "==> Start sshd on port $TARGET_SSH_PORT"
exec /usr/sbin/sshd -E /var/log/sshd.log -g 30 -p $TARGET_SSH_PORT -D