#!/usr/bin/env bash

echo "==> Configure spark"
configure_spark
echo "==> Exec CMD"
exec $@