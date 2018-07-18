#!/usr/bin/env sh

sudo -u root SPARK_HOME=/opt/spark spark-submit --master $(mesos_master4spark) $@ --verbose --deploy-mode cluster