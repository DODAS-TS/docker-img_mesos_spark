#!/usr/bin/env bash

echo "==> Save Zookeeper host list"
echo "$ZOOKEEPER_HOST_LIST" > /opt/dodas/zookeeper_host_list
echo "==> Prepare Spark conf"
cp /opt/spark/conf/spark-defaults.conf.template /opt/spark/conf/spark-defaults.conf
echo -e "\n" >> /opt/spark/conf/spark-defaults.conf
MESOS_MASTER=$(mesos_master4spark)
echo "==> Add Mesos master [$MESOS_MASTER] in Spark conf"
echo -e "spark.master\t$MESOS_MASTER" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.dynamicAllocation.enabled\ttrue" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.shuffle.service.enabled\ttrue" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.executor.memory\t512m" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.executor.cores\t1" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.executor.cores.max\t1" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.cores.max\t1" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.mesos.executor.docker.image\tindigodatacloudapps/mesos-spark:base" >> /opt/spark/conf/spark-defaults.conf
ecgi -e "spark.mesos.executor.docker.forcePullImage\ttrue" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.shuffle.reduceLocality.enabled\tfalse" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.shuffle.blockTransferService\tnio" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.scheduler.minRegisteredResourcesRatio\t1.0" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.speculation\tfalse" >> /opt/spark/conf/spark-defaults.conf
echo -e "spark.serializer\torg.apache.spark.serializer.JavaSerializer" >> /opt/spark/conf/spark-defaults.conf
