#!/usr/bin/env sh

sudo SPARK_HOME=/opt/spark spark-submit $@ --verbose --deploy-mode cluster