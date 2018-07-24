#!/usr/bin/env python
from __future__ import print_function, unicode_literals
import json
from ast import literal_eval
from os import environ

from kazoo.client import KazooClient


def get_host_list():
    host_list = None
    try:
        with open("/opt/dodas/zookeeper_host_list") as zk_file:
            host_list = zk_file.read()
    except IOError:
        host_list = environ.get('ZOOKEEPER_HOST_LIST')
    if host_list.find(":") == -1 and\
            (host_list.find("[") != -1 and host_list.find("]") != -1):
        host_list = literal_eval(host_list)
    else:
        host_list = host_list.split(",")

    return host_list


def main():
    def idx_in_list(target, list_): return [True if elm.find(
        target) != -1 else False for elm in list_].index(True)

    host_list = get_host_list()
    zookeeper_host_list = ",".join(
        [host + ":2181" if host.find(":") == -
            1 else host for host in host_list]
    )
    zk_client = KazooClient(hosts=zookeeper_host_list)
    zk_client.start()
    mesos_childern = zk_client.get_children("/mesos")
    info_label = mesos_childern[idx_in_list('json.info', mesos_childern)]
    content, _ = zk_client.get("/mesos/{}".format(info_label))
    zk_client.stop()

    # Content example:
    # {
    #   "address": {
    #       "hostname": "10.10.42.149",
    #       "ip": "10.10.42.149",
    #       "port":5050
    #   },
    #   "hostname": "10.10.42.149",
    #   "id": "f48d1424-5be9-437f-8e3a-cc849d5017b1",
    #   "ip":2502560266,
    #   "pid": "master@10.10.42.149:5050",
    #   "port":5050,
    #   "version": "1.1.0"
    # }
    content_obj = json.loads(content)
    print("mesos://{}:{}".format(
        content_obj['address']['ip'],
        content_obj['address']['port']
    ), end='')


if __name__ == '__main__':
    main()
