# openshift-nfs

OpenShift NFS server with dynamic provisioner. This is not HA - single NFS server pod only.

## Build NFS Server Image

Uses latest fedora image.

Build and push the image.

```bash
make podman-push
```

## Deploy NFS Server

Create a project for NFS Server.

```bash
oc new-project nfs
oc create sa nfs-server
oc adm policy add-scc-to-user privileged -z nfs-server
oc import-image nfs-server --from=quay.io/eformat/nfs-fedora:latest --confirm
```

Provision using a default RWO storage class e.g. `thin-csi` in vpshere. Set `SIZE`.

```bash
DOCKERIMAGEREFERENCE="$(oc -n nfs get istag/nfs-server:latest -o jsonpath='{.image.dockerImageReference}')"
echo "nfs-server image reference is $DOCKERIMAGEREFERENCE"
STORAGECLASS=thin-csi
DOCKERIMAGEREFERENCE=$DOCKERIMAGEREFERENCE STORAGECLASS=$STORAGECLASS SIZE=100Gi envsubst < deploy/nfs-server.yml | oc -n nfs apply -f -
```

Get the NFS Server Cluster IP Address.

```bash
NFSSERVERIP=$(oc -n nfs get svc/nfs-server -o jsonpath='{.spec.clusterIP}')
echo "NFS server IP address is ${NFSSERVERIP}"
```

## Create NFSv3,4 Provisioners

Create SCC.

```bash
oc apply -f deploy/scc.yaml
```

NFSv3

```bash
oc new-project nfs3
oc adm policy add-scc-to-user nfs-admin -z nfs-client-provisioner-3
PROJ=nfs3 PROVISIONERNAME=nfs-client-provisioner-3 envsubst < deploy/rbac.yaml | oc apply -f -
PROJ=nfs3 PROVISIONERNAME=nfs-client-provisioner-3 K8SPROV=nfs-subdir-external-provisioner-3 NFSSERVERIP=$NFSSERVERIP NFSPATH=/exports envsubst < deploy/deployment.yaml | oc apply -f -
K8SPROV=nfs-subdir-external-provisioner-3 envsubst < deploy/class-3.yaml | oc apply -f -
```

NFSv4

```bash
oc new-project nfs4
oc adm policy add-scc-to-user nfs-admin -z nfs-client-provisioner-4
PROJ=nfs4 PROVISIONERNAME=nfs-client-provisioner-4 envsubst < deploy/rbac.yaml | oc apply -f -
PROJ=nfs4 PROVISIONERNAME=nfs-client-provisioner-4 K8SPROV=nfs-subdir-external-provisioner-4 NFSSERVERIP=$NFSSERVERIP NFSPATH=/ envsubst < deploy/deployment.yaml | oc apply -f -
K8SPROV=nfs-subdir-external-provisioner-4 envsubst < deploy/class-4.yaml | oc apply -f -
```

## Troubleshoot

If the client doesn't work, use the deployment in `deploy/troubleshoot.yml` to troubleshoot.
