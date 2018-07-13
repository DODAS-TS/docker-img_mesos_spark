#!/usr/bin/env bash


j2 core-site.xml.j2 > /spark/conf/core-site.xml 
j2 spark-defaults.conf.j2 > /spark/conf/spark-defaults.conf

# Hand off to the CMD
exec "$@"