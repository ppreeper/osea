How to Monitor Linux Server Performance with Prometheus and Grafana in 5 minutes
================================================================================

https://computingforgeeks.com/how-to-monitor-linux-server-performance-with-prometheus-and-grafana-in-5-minutes/

(Last Updated On: September 21, 2018)

Prometheus is an open source monitoring solution that stores all its data in
a time series database. Prometheus has a multi-dimensional data-model and a
powerful query language that is used to generate reports of the resources
being monitored. This tutorial explains how to monitor a Linux server
performance with Prometheus and Grafana.

Prometheus node exporter exports hardware and OS metrics exposed by \*NIX
kernels for consumption by Prometheus. This exporter is written in Go
with pluggable metric collectors.

Similar Prometheus articles available on this blog are:

* Monitoring Ceph Cluster with Prometheus and Grafana
* How to Monitor BIND DNS server with Prometheus and Grafana
* Monitoring MySQL / MariaDB with Prometheus in five minutes
* How to Monitor Apache Web Server with Prometheus and Grafana in 5 minutes

## Setup Procedure

. Install Prometheus and Grafana
. Install Prometheus Node Exporter on Linux servers to be monitored
. Configure Node Exporter
. Configure Prometheus server with Scrap jobs
. Add Dashboards to Grafana
. Start visualizing system metrics on Grafana

For installation of Prometheus and Grafana use:

Install Prometheus Server on CentOS 7 and Ubuntu 18.04

How to Install Grafana on Ubuntu 18.04 and Debian 9

Install Grafana and InfluxDB on CentOS 7

Step 1: Add Prometheus system user
----------------------------------

..  code::

    sudo groupadd --system prometheus
    sudo useradd -s /sbin/nologin --system -g prometheus prometheus

We added a system user called `prometheus` whose default group
is `prometheus`. This user account will be used to run nod exporter service.
It is safe since it doesn’t have access to the interactive shell and
home directory.

Step 2: Download and Install Prometheus Node Exporter
--------------------------------------------------------------------

..  code::

    export VER=0.16.0
    wget https://github.com/prometheus/node_exporter/releases/download/v${VER}/node_exporter-${VER}.linux-amd64.tar.gz
    tar xvf node_exporter-${VER}.linux-amd64.tar.gz
    sudo mv node_exporter-${VER}.linux-amd64/node_exporter /usr/local/bin/
    rm -f node_exporter-${VER}.linux-amd64.tar.gz
    rm -rf node_exporter-${VER}.linux-amd64

The version installed can be confirmed using the command:

..  code::

    # node_exporter  --version
    node_exporter, version 0.16.0 (branch: HEAD, revision: d42bd70f4363dced6b77d8fc311ea57b63387e4f)
        build user:       root@a67a9bc13a69
        build date:       20180515-15:52:42
        go version:       go1.9.6

Step 3: Configure Prometheus Node Exporter systemd / Init script
--------------------------------------------------------------------

Collectors are enabled by providing a `--collector.<name>` flag.

Collectors that are enabled by default can be disabled by providing
a `--no-collector.<name>` flag.

..  code::

    sudo vim /etc/systemd/system/node_exporter.service

Add below content

..  code::

    Unit
    Description=Prometheus
    Documentation=https://github.com/prometheus/node_exporter
    Wants=network-online.target
    After=network-online.target

    Service
    Type=simple
    User=prometheus
    Group=prometheus
    ExecReload=/bin/kill -HUP $MAINPID
    ExecStart=/usr/local/bin/node_exporter \
        --collector.cpu \
        --collector.diskstats \
        --collector.filesystem \
        --collector.loadavg \
        --collector.meminfo \
        --collector.filefd \
        --collector.netdev \
        --collector.stat \
        --collector.netstat \
        --collector.systemd \
        --collector.uname \
        --collector.vmstat \
        --collector.time \
        --collector.mdadm \
        --collector.zfs \
        --collector.tcpstat \
        --collector.bonding \
        --collector.hwmon \
        --collector.arp \
        --web.listen-address=:9100 \
        --web.telemetry-path="/metrics"

    SyslogIdentifier=node_exporter
    Restart=always

    Install
    WantedBy=multi-user.target

Start the service and enable it to start on boot

..  code::

    sudo systemctl start node_exporter
    sudo systemctl enable node_exporter

Configure firewall
~~~~~~~~~~~~~~~~~~

If you have an active firewall on your server, e.g firewalld, ufw, open
port `9100`

..  code::

    sudo ufw allow 9100

For CentOS 7 system, use `firewalld`

..  code::

    sudo firewall-cmd --add-port=9100/tcp --permanent
    sudo firewall-cmd --reload

For Init Linux system like CentOS 6, you can use `daemonize` to start the
service in the background.

Install daemonize:

..  code::

    sudo yum install daemonize
    sudo apt-get install daemonize

Once installed, create `node_exporter` init script

..  code::

    sudo vim /etc/init.d/node_exporter

Add below script

..  code::

    #!/bin/bash
    # Author: Josphat Mutai, kiplangatmtai@gmail.com , https://github.com/jmutai
    # node_exporter     This shell script takes care of starting and stopping Prometheus apache exporter
    #
    # chkconfig: 2345 80 80
    # description: Prometheus apache exporter  start script
    # processname: node_exporter
    # pidfile: /var/run/node_exporter.pid

    # Source function library.
    . /etc/rc.d/init.d/functions

    RETVAL=0
    PROGNAME=node_exporter
    PROG=/usr/local/bin/${PROGNAME}
    RUNAS=prometheus
    LOCKFILE=/var/lock/subsys/${PROGNAME}
    PIDFILE=/var/run/${PROGNAME}.pid
    LOGFILE=/var/log/${PROGNAME}.log
    DAEMON_SYSCONFIG=/etc/sysconfig/${PROGNAME}

    # GO CPU core Limit

    #GOMAXPROCS=$(grep -c ^processor /proc/cpuinfo)
    GOMAXPROCS=1

    # Source config

    . ${DAEMON_SYSCONFIG}

    start() {
        if  -f $PIDFILE  > /dev/null; then
            echo "node_exporter  is already running"
            exit 0
        fi

        echo -n "Starting node_exporter  service…"
        daemonize -u ${USER} -p ${PIDFILE} -l ${LOCKFILE} -a -e ${LOGFILE} -o ${LOGFILE} ${PROG} ${ARGS}
        RETVAL=$?
        echo ""
        return $RETVAL
    }

    stop() {
        if  ! -f "$PIDFILE"  || ! kill -0 $(cat "$PIDFILE"); then
            echo "Service not running"
            return 1
        fi
        echo 'Stopping service…'
        #kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
        killproc -p ${PIDFILE} -d 10 ${PROG}
        RETVAL=$?
        echo
        $RETVAL = 0  && rm -f ${LOCKFILE} ${PIDFILE}
        return $RETVAL
    }

    status() {
        if  -f "$PIDFILE"  || kill -0 $(cat "$PIDFILE"); then
        echo "apache exporter  service running..."
        echo "Service PID: `cat $PIDFILE`"
        else
        echo "Service not running"
        fi
        RETVAL=$?
        return $RETVAL
    }

    # Call function
    case "$1" in
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            stop
            start
            ;;
        status)
            status
            ;;
        *)
            echo "Usage: $0 {start|stop|restart}"
            exit 2
    esac

Create Arguments configuration file

..  code::

    sudo vim /etc/sysconfig/node_exporter

Add

..  code::

    ARGS="--collector.cpu \
    --collector.diskstats \
    --collector.filesystem \
    --collector.loadavg \
    --collector.meminfo \
    --collector.filefd \
    --collector.netdev \
    --collector.stat \
    --collector.netstat \
    --collector.systemd \
    --collector.uname \
    --collector.vmstat \
    --collector.time \
    --collector.mdadm \
    --collector.xfs \
    --collector.zfs \
    --collector.tcpstat \
    --collector.bonding \
    --collector.hwmon \
    --collector.arp \
    --web.listen-address=:9100 \
    --web.telemetry-path="/metrics"

Test the script

..  code::

    # /etc/init.d/node_exporter
    Usage: /etc/init.d/node_exporter {start|stop|restart}

Step 4: Start the Prometheus node exporter service
--------------------------------------------------

For systemd, start using

..  code::

    sudo systemctl start node_exporter
    sudo systemctl enable node_exporter

For Init system use:

..  code::

    sudo /etc/init.d/node_exporter start
    sudo chkconfig node_exporter on

You can verify using

..  code::

    $ sudo /etc/init.d/node_exporter status
    apache exporter  service running...
    Service PID: 1970

    $ sudo chkconfig --list | grep node_exporter
    node_exporter 0:off   1:off   2:on    3:on    4:on    5:on    6:off

    $ sudo ss -tunelp | grep 9100
    tcp    LISTEN     0      128      :::9100                 :::*                   users:(("node_exporter",pid=16105,fd=3)) uid:997 ino:193468 sk:ffff8a0a76f52a80 v6only:0 <->

Step 5: Add exporter job to Prometheus
--------------------------------------

The second last step is to add a job to the Prometheus server for scraping
metrics. Edit `/etc/prometheus/prometheus.yml`

..  code::

    # Linux Servers
    - job_name: apache-linux-server1
        static_configs:
        - targets: '10.1.10.20:9100'
            labels:
            alias: server1

    - job_name: apache-linux-server2
        static_configs:
        - targets: '10.1.10.21:9100'
            labels:
            alias: server2

Restart prometheus service for scraping to start

..  code::

    sudo systemctl restart prometheus

Test access to port `9100` from Prometheus server

..  code::

    $ telnet 10.1.10.20 9100
    Trying 10.1.10.20...
    Connected to 10.1.10.20.
    Escape character is '^'.
    ^

Step 6: Add Dashboard to Grafana
----------------------------------

You can create your own Grafana dashboard or import from a collection of
community shared dashboards. Below is a list of dashboards than has been
created to show classical system metrics of your \*NIX server.

https://grafana.com/dashboards/159
https://grafana.com/dashboards/3662
https://github.com/percona/grafana-dashboards
https://github.com/rfrail3/grafana-dashboards

For demo purposes, we’ll use the first dashboard with ID `159`.

Add Prometheus data source

With Prometheus data source added to Grafana, Import Apache Grafana Dashboard
by navigating to `Dashboard > Import`. Use `159` for Grafana Dashboard ID.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-node-exporter-import-dashboard-min-696x382.png

Give it a descriptive name and select *Prometheus* data source added earlier.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-node-exporter-import-dashboard-02-min-696x259.png

Click “*Import*” button to start using the dashboard. After a few minutes,
the metrics should start showing.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/node-exporter-system-dashboard-min-696x322.png

That’s all. Feel free to customize the dashboard to fit your use case and
share for oothers to benefit as well.
