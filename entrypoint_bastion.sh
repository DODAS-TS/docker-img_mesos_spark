#!/usr/bin/env bash

echo "==> Configure Spark"
configure_spark
echo "==> Prepare admin keys"
sudo -u admin ssh-keygen -q -t rsa -N '' -f /home/admin/.ssh/id_rsa
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
echo "\n==> Public SPARK proxy host"
dodas_cache zookeeper SPARK_PROXY_TARGET_HOST "$NETWORK_INTERFACE"
echo "\n==> Public JUPYTER proxy host"
dodas_cache zookeeper JUPYTER_PROXY_TARGET_HOST "$NETWORK_INTERFACE"

if [ "$CONTAINER_TARGET" == "SSH" ] ; 
then
    echo "\n==> Start sshd on port $TARGET_SSH_PORT"
    exec /usr/sbin/sshd -E /var/log/sshd.log -g 30 -p $TARGET_SSH_PORT -D
elif [ "$CONTAINER_TARGET" == "JUPYTER" ]
then
    echo "==> Prepare jupyter environment"
    mkdir -p /root/.jupyter
    echo "c.NotebookApp.allow_origin = '*'" >> /root/.jupyter/jupyter_notebook_config.py
    echo "c.NotebookApp.allow_root = True " >> /root/.jupyter/jupyter_notebook_config.py
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py
    JUPYTER_PASSWORD_HASH=`python3 -c 'from notebook.auth import passwd; print(passwd($JUPYTER_PASSWORD))'`
    echo "c.NotebookApp.password = u'$JUPYTER_PASSWORD_HASH'" >> /root/.jupyter/jupyter_notebook_config.py
    export PYSPARK_DRIVER_PYTHON='jupyter'
    export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
    echo "==> Start jupyter"
    exec pyspark --properties-file /opt/spark/conf/spark-defaults.conf
else
    echo "Target $CONTAINER_TARGET is not implemented..."
fi
