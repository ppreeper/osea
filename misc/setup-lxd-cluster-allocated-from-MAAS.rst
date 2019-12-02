On all 3 systems

apt remove --purge lxd lxd-client liblxc1 lxcfs

On all 3 systems
snap install lxd

Consistent storage network

On node1
lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What name should be use to identify this node in the cluster? [default=node1]:
What IP address of DNS name should be use to reach this node? [default=172.17.16.169]:
Are you joining an existing cluster? (yes/no) [default=no]:
Setup password authentication on the cluster? (yes/no) [default=yes]:
Trust password for the new clients:
Again:
Do you want to configure a new local storage pool (yes/no) [default=yes]?
Name of the storage backend to use (btrfs, dir, lvm, zfs) [default=zfs]:


lxc cluster show node1

On node2
lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What name should be use to identify this node in the cluster? [default=node2]:
What IP address of DNS name should be use to reach this node? [default=172.17.16.171]:
Are you joining an existing cluster? (yes/no) [default=no]: yes
IP address or FQDN of an existing cluster node: 172.17.16.169
Cluster certificate fingerprint: nnnnnnnnnnnnnnnnnnnnnnn
ok? (yes/no) [default=no]: yes
Cluster trust password:
All existing data is lost when joining a cluster, continue? (yes/no) [default=no] yes
Choose the local disk or dataset for storage pool "local" (empty for loop disk):
Would you like a YAML "lxd init" preseed to be prinded [default=no]? yes

lxc cluster list
lxc list
lxc storage list

On node3
lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What name should be use to identify this node in the cluster? [default=node3]:
What IP address of DNS name should be use to reach this node? [default=172.17.16.170]:
Are you joining an existing cluster? (yes/no) [default=no]: yes
IP address or FQDN of an existing cluster node: 172.17.16.169
Cluster certificate fingerprint: nnnnnnnnnnnnnnnnnnnnnnn
ok? (yes/no) [default=no]: yes
Cluster trust password:
All existing data is lost when joining a cluster, continue? (yes/no) [default=no] yes
Choose the local disk or dataset for storage pool "local" (empty for loop disk):
Would you like a YAML "lxd init" preseed to be prinded [default=no]? yes

lxc cluster list
lxc list
lxc storage list

lxc launch ubuntu:16.04 d1
lxc list (went on node1)
lxc launch ubuntu:16.04 d2
lxc list (went on node2)
lxc launch ubuntu:16.04 d3 --target node1
lxc list (went on node1)
lxc config device add d2 eth0 nic nictype=bridged parent=br0 ipv4.address=172.17.16.20 name=eth0
lxc config show d1 --expanded

lxc remote add cluster djanet.maas.mtl

lxc list cluster:
lxc remote set-default local
