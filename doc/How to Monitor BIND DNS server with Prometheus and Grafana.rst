How to Monitor BIND DNS server with Prometheus and Grafana
==========================================================

https://computingforgeeks.com/how-to-monitor-bind-dns-server-with-prometheus-and-grafana/

(Last Updated On: September 18, 2018)

In this blog post, we will cover the steps to set up monitoring for BIND DNS
server using Prometheus Server and Grafana to visualize Bind metrics. BIND
which stands for “Berkeley Internet Name Domain” is an open-source Domain
Name server that allows you to publish your DNS information on the Internet
and allow network users to do DNS queries.

The number of tools that can be used to monitor BIND DNS server is limited,
and personally, I like Prometheus Bind exporter with Grafana. LibreNMS has
https://docs.librenms.org/#Extensions/Applications/#bind9-aka-named
BIND application monitoring that I was planning to give it a try.

## Setup Pre-requisites

1. Installed and configured BIND DNS server
2. BIND need to have been build with libxml2 support. This can be confirmed
   using

..  code::

    # named -V | grep libxml2.
    using libxml2 version: 2.9.1

3. Installed Prometheus Server

## Step 1: Install Bind Prometheus Exporter

Install git

..  code::

    sudo yum install git

For Ubuntu run:

..  code::

    sudo apt install wget

### Install Go

You need to have Go installed on your server to build bind_exporter

How to Install latest Go on CentOS 7 / Ubuntu 18.04

Once you have git and Go installed, download `bind_exporter`

..  code::

    go get github.com/digitalocean/bind_exporter
    cd $GOPATH/src/github.com/digitalocean/bind_exporter

Generate binary file using.make

..  code::

    # make
    >> formatting code
    >> building binaries
    >   bind_exporter
    >> running tests
    ok  	github.com/digitalocean/bind_exporter	0.099s
    ?   	github.com/digitalocean/bind_exporter/bind	[no test files]
    ?   	github.com/digitalocean/bind_exporter/bind/auto	[no test files]
    ?   	github.com/digitalocean/bind_exporter/bind/v2	[no test files]
    ?   	github.com/digitalocean/bind_exporter/bind/v3	[no test files]

`bind_exporter` binary will be generated. Copy the binary file to
`/usr/local/bin`

..  code::

    chmod  +x bind_exporter
    sudo mv bind_exporter  /usr/local/bin/
    [source,bash]

You can print command options using `bind_exporter --help`

..  code::

    # ./bind_exporter --help
    Usage of ./bind_exporter:
    -bind.pid-file string
            Path to Bind's pid file to export process information.
    -bind.stats-groups value
            Comma-separated list of statistics to collect. Available: [server, view, tasks] (default "server,view")
    -bind.stats-url string
            HTTP XML API address of an Bind server. (default "http://localhost:8053/")
    -bind.stats-version string
            BIND statistics version. Can be detected automatically. Available: [xml.v2, xml.v3, auto] (default "auto")
    -bind.timeout duration
            Timeout for trying to get stats from Bind. (default 10s)
    -log.format value
            Set the log target and format. Example: "logger:syslog?appname=bob&local=7" or "logger:stdout?json=true" (default "logger:stderr")
    -log.level value
            Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal] (default "info")
    -version
            Print version information.
    -web.listen-address string
            Address to listen on for web interface and telemetry. (default ":9119")
    -web.telemetry-path string
            Path under which to expose metrics. (default "/metrics")

## Step 2: Configure BIND DNS server

You need to configure BIND to open a statistics channel. Since the exporter
and BIND are on the same host, the port is opened locally.

For CentOS ISC BIND DNS server, edit the file `/etc/named.conf` to add.

..  code::

    statistics-channels {
      inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
    };

For Ubuntu / Debian ISC BIND DNS server, edit the file
`/etc/bind/named.conf.options`

..  code::

    statistics-channels {
        inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
    };

Restart bind for the changes to be effected

..  code::

    sudo systemctl restart named

## Step 3: Create Bind Exporter systemd service

The next part is to create systemd service used to start the collector with
access to the bind(named) pid file and enable the view stats group:

Add Prometheus system user account

..  code::

    sudo groupadd --system prometheus
    sudo useradd -s /sbin/nologin --system -g prometheus prometheus

This user will manage the exporter service.

Once the user account has been added, create a systemd service unit file

..  code::

    sudo vim /etc/systemd/system/bind_exporter.service

Add below content:

..  code::

    [Unit]
    Description=Prometheus
    Documentation=https://github.com/digitalocean/bind_exporter
    Wants=network-online.target
    After=network-online.target

    [Service]
    Type=simple
    User=prometheus
    Group=prometheus
    ExecReload=/bin/kill -HUP $MAINPID
    ExecStart=/usr/local/bin/bind_exporter \
    --bind.pid-file=/var/run/named/named.pid \
    --bind.timeout=20s \
    --web.listen-address=0.0.0.0:9153 \
    --web.telemetry-path=/metrics \
    --bind.stats-url=http://localhost:8053/ \
    --bind.stats-groups=server,view,tasks

    SyslogIdentifier=prometheus
    Restart=always

    [Install]
    WantedBy=multi-user.target

Reload `systemd` and start `bind_exporter` service

..  code::

    sudo systemctl daemon-reload
    sudo systemctl restart bind_exporter.service

Enable the service to start on boot

..  code::

    $ sudo systemctl enable bind_exporter.service
    Created symlink from /etc/systemd/system/multi-user.target.wants/bind_exporter.service to /etc/systemd/system/bind_exporter.service.

Confirm that the service is listening on port `9153` as configured

..  code::

    # ss -tunelp | grep 9153
    tcp    LISTEN     0      128      :::9153                 :::*                   users:(("bind_exporter",pid=23266,fd=3)) uid:997 ino:113951 sk:ffff8d17fab19980 v6only:0 <->

Open the port on the firewall if you have `firewalld` running

..  code::

    sudo firewall-cmd --add-port=9153/tcp --permanent
    sudo firewall-cmd --reload

## Step 4: Configure Prometheus Server

If you don’t have a running Prometheus server, refer to our previous guide on
how to Install Prometheus Server on CentOS 7 and Ubuntu 18.04. Below is a
definition of my two jobs

..  code::

    - job_name: dns-master
        static_configs:
        - targets: ['10.1.5.3:9153']
            labels:
            alias: dns-master

    - job_name: dns-slave1
        static_configs:
        - targets: ['10.1.5.4:9153']
            labels:
            alias: dns-slave

Restart `prometheus` server

..  code::

    sudo systemctl restart prometheus

## Step 5: Add Grafana Dashboard

We’re going to use already created Grafana dashboard by
https://grafana.com/orgs/cristicalin Cristian Calin . Dashboard ID is `1666`.
Login to Grafana and https://prometheus.io/docs/visualization/grafana/
Add Prometheus data source if you haven’t.

When Prometheus data source has been added, import Bind Grafana Dashboard by
navigating to *Dashboard > Import*. Use *1666* for Grafana Dashboard ID.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/grafana-add-prometheus-dns-dashboard-min-696x385.png[]

Give it a descriptive name and choose Prometheus data source added
earlier.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/grafana-add-prometheus-dns-dashboard-02-min-696x243.png[]

Click “*Import*” button to start using the dashboard. After a few minutes,
the metrics should start showing.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/grafana-dashboards-min-696x203.png[]

Stay tuned for more monitoring guides with Prometheus and Grafana.
