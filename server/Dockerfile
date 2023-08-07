FROM fedora

# podman build -t nfs .
# podman run -it --name nfs --privileged --ipc=host --net=host --pid=host -e NAME=nfs -e IMAGE=nfs -d nfs

RUN dnf update -y && \
    dnf install -y nfs-utils rpcbind && dnf clean all

RUN mkdir -p /exports && \
    chmod -R 777 /exports && \
    chown -R nobody:nobody /exports

RUN echo "/exports *(rw,fsid=0,insecure,no_root_squash,no_wdelay,no_all_squash)" >> /etc/exports

EXPOSE 111 2049

COPY run.sh /usr/local/bin/run_nfs.sh
RUN chmod 775 /usr/local/bin/run_nfs.sh
