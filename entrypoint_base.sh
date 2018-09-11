#!/usr/bin/env bash

echo "==> Save Zookeeper host list"
echo "$ZOOKEEPER_HOST_LIST" > /opt/dodas/zookeeper_host_list
echo "==> Configure spark"
configure_spark