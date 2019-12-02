Monitoring Ceph Cluster with Prometheus and Grafana
===================================================

https://computingforgeeks.com/monitoring-ceph-cluster-with-prometheus-and-grafana/

This article is part of Smart Infrastructure monitoring series, we’ve already
covered how to Install Prometheus Server on CentOS 7 and how to Install
Grafana and InfluxDB on CentOS 7. We have a Ceph cluster on production that
we have been trying to find good tools for monitoring it, lucky enough, we
came across Prometheus and Grafana.

Ceph Cluster monitoring with Prometheus requires Prometheus exporter that
scrapes meta information about a ceph cluster. In this guide, we’ll use
https://github.com/digitalocean/ceph_exporter DigitalOcean Ceph exporter.

Prerequisites:

1. Installed Prometheus Server.
2. Installed Grafana Server.
3. Docker installed on a Server to run Prometheus Ceph exporter. It should
   be able to talk to ceph cluster.
4. Working Ceph Cluster
5. Access to Ceph cluster to copy `ceph.conf` configuration file and the
   `ceph.<user>.keyring` in order to authenticate to your cluster.

Follow below steps for a complete guide on how to set this up.

Step 1: Install Prometheus Server and Grafana
---------------------------------------------

Use these links for how to install Prometheus and Grafana.

https://computingforgeeks.com/install-prometheus-server-on-centos-7/
Install Prometheus Server on CentOS 7  and https://computingforgeeks.com/install-grafana-and-influxdb-on-centos-7/
Install Grafana and InfluxDB on CentOS 7.

Step 2: Install Docker on Prometheus Ceph exporter client
---------------------------------------------------------

Please note that Prometheus Ceph exporter client should have access to Ceph
cluster network for it to pull Cluster metrics. Install Docker on this
server using our official Docker installation guide:

https://computingforgeeks.com/installing-docker-ce-ubuntu-debian-fedora-arch-centos/
How to install Docker CE on Ubuntu / Debian / Fedora / Arch / CentOS

Also, install docker-compose. Since you added docker repository before
installing Docker Engine, you should be able to install docker-compose from
yum or apt-get.

..  code::

    # yum -y install docker-compose

For Ubuntu:

..  code::

    # apt-get install docker-compose

Step 3: Build Ceph Exporter Docker image
----------------------------------------

Once you have Docker Engine installed and service running. You should be ready
to build docker image from DigitalOcean Ceph exporter project. Consider
installing Git if you don’t have it already.

..  code::

    # yum -y install git

If you’re using Ubuntu, run:

..  code::

    # apt-get install git

Then clone the project from Github:

..  code::

    # git clone https://github.com/digitalocean/ceph_exporter.git

Switch to the __ceph_exporter__ directory and build docker image:

..  code::

    # docker build -t ceph_exporter

This will build an image named __ceph_exporter__. It may take a while
depending on your internet and disk write speeds.

Step 4: Start Prometheus ceph exporter client container
-------------------------------------------------------

Copy `ceph.conf` configuration file and the `ceph.<user>.keyring` to
`/etc/ceph` directory and start docker container host’s network stack. You
can use vanilla docker commands, docker-compose or systemd to manage the
container. For docker command line tool, run below commands.

..  code::

    # docker run -v /etc/ceph:/etc/ceph --net=host -p=9128:9128 -it digitalocean/ceph_exporter

For docker-compose, create the following file:

..  code::

    # cat docker-compose.yml
    # Example usage of exporter in use
    version: '2'
    services:
    ceph-exporter:
        image: ceph_exporter
        restart: always
        network_mode: "host"
        volumes:
            - /etc/ceph:/etc/ceph
        ports:
            - '9128:9128'

Then start docker container using:

..  code::

    # docker-compose up -d

For systemd, create service unit file like below:

..  code::

    # cat /etc/systemd/system/ceph_exporter.service

    [Service]
    Restart=always
    TimeoutStartSec=0
    ExecStartPre=-/usr/bin/docker kill ceph_exporter
    ExecStartPre=-/usr/bin/docker rm ceph_exporter

    ExecStart=/usr/bin/docker run \
    --name ceph_exporter \
    -v /etc/ceph:/etc/ceph \
    --net=host \
    -p=9128:9128 \
    ceph_exporter

    ExecStop=-/usr/bin/docker kill ceph_exporter
    ExecStop=-/usr/bin/docker rm ceph_exporter

Check container status:

..  code::

    # systemctl status ceph_exporter

You should get output like below if all went fine.

image:https://computingforgeeks.com/wp-content/uploads/2018/05/ceph_exporter_systemd_status-696x327.png[]

Step 5: Open 9128 on the firewall
---------------------------------

I use firewalld since this is a CentOS 7 server, allow access to port
9128 from your trusted network.

..  code::

    # firewall-cmd --permanent --add-rich-rule 'rule family="ipv4" \
    source address="192.168.10.0/24" port protocol="tcp" port="9128" accept'
    # firewall-cmd --reload

Test access with nc or telnet command.

..  code::

    # telnet 127.0.0.1 9128
    Trying 127.0.0.1...
    Connected to 127.0.0.1.
    Escape character is '^]'.

    # nc -v 127.0.0.1 9128
    Ncat: Version 6.40 ( http://nmap.org/ncat )
    Ncat: Connected to 127.0.0.1:9128.

or with `IP-ADDRESS 9128`

Step 6: Configure Prometheus scrape target with Ceph exporter
-------------------------------------------------------------

We need to define Prometheus `static_configs` line for created ceph exporter
container.  Edit the file `/etc/prometheus/prometheus.yml` on your Prometheus
server to look like below.

..  code::

    scrape_configs:
    - job_name: prometheus
      static_configs:
          - targets: ['localhost:9090']
    - job_name: 'ceph-exporter'
      static_configs:
        - targets: ['localhost:9128']
          labels:
            alias: ceph-exporter

Replace `localhost` with your ceph exporter host IP address. Remember to
restart Prometheus service after making the changes:

..  code::

    # systemctl restart prometheus

Step 7: Add Prometheus Data Source to Grafana
---------------------------------------------

Login to your Grafana Dashboard and add Prometheus data source. You’ll need
to provide the following information:

* *Name*: Name given to this data source
* *Type*: The type of data source, in our case this is Prometheus
* *URL*: IP address and port number of Prometheus server you’re adding.
* *Access*: Specify if access through *proxy* or direct. Proxy means access
  through Grafana server, direct means access from the web.

image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana_add_data_source.png[]

Save the settings by clicking save & Test button.

Step 8: Import Ceph Cluster Grafana Dashboards
----------------------------------------------

The last step is to import Ceph Cluster Grafana Dashboards. From my research,
I found the following Dashboards by Cristian Calin.

* Ceph Cluster Overview: https://grafana.com/dashboards/917
* Ceph Pools Overview: https://grafana.com/dashboards/926
* Ceph OSD Overview: https://grafana.com/dashboards/923

We will use dashboard IDs 917, 926 and 923 when importing dashboards
on Grafana.

Click the **plus sign (+)> Import** to import dashboard. Enter the number that
matches the dashboard you wish to import above.

image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana-ceph-cluster-696x301.png[]
image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana-ceph-osd-696x341.png[]
image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana-ceph-pools-696x318.png[]

To View imported dashboards, go to Dashboards and select the name of the
dashboard you want to view.

image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana-ceph-cluster-dashboard-696x373.png[]
image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana-ceph-osd-dashboard-696x350.png[]
image:https://computingforgeeks.com/wp-content/uploads/2018/05/grafana-ceph-pools-dashboard-696x351.png[]

For OSD and Pools dashboard, you need to select the pool name / OSD number
to view its usage and status. SUSE guys have similar dashboards available
on https://github.com/SUSE/grafana-dashboards-ceph
