#!/usr/bin/env bash

echo "==> Save Zookeeper host list"
echo "$ZOOKEEPER_HOST_LIST" > /opt/dodas/zookeeper_host_list
echo "==> Prepare Spark conf"
cp /opt/spark/conf/spark-defaults.conf.template /opt/spark/conf/spark-defaults.conf
echo -e "\n" >> /opt/spark/conf/spark-defaults.conf
MESOS_MASTER=$(mesos_master4spark)
echo "==> Add Mesos master [$MESOS_MASTER] in Spark conf"
echo -e "spark.master\t$MESOS_MASTER\n" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.shuffle.service.enabled\ttrue\n" >> /opt/spark/conf/spark-defaults.conf
