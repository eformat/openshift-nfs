#!/bin/bash

exportfs -a
rpcbind
rpc.statd
rpc.nfsd

rpc.mountd
#exec rpc.mountd --foreground

sleep infinity
