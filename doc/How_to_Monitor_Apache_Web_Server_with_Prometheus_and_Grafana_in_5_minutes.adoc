How to Monitor Apache Web Server with Prometheus and Grafana in 5 minutes
=========================================================================

https://computingforgeeks.com/how-to-monitor-apache-web-server-with-prometheus-and-grafana-in-5-minutes/

(Last Updated On: September 20, 2018)

Welcome to our guide on how to Monitor Apache Web Server with Prometheus and
Grafana in less than 5 minutes. This setup should work for any version of
Apache web server running on any flavor of Linux. We have other Prometheus
Monitoring tutorials:

* Monitoring Ceph Cluster with Prometheus and Grafana
* How to Monitor BIND DNS server with Prometheus and Grafana
* Monitoring MySQL / MariaDB with Prometheus in five minutes

If you are following this guide, I expect that you have Prometheus server
installed and running, you can refer to our guide for a fresh installation
of Prometheus server on Ubuntu or CentOS server.

Install Prometheus Server on CentOS 7 and Ubuntu 18.04

Follow these setup steps to have your Apache Web Server metrics stored on
Prometheus and visualized using Grafana.

Step 1: Download and Install Apache Prometheus exporter
-------------------------------------------------------

..  code::

    export VER="0.5.0"
    wget https://github.com/Lusitaniae/apache_exporter/releases/download/v${VER}/apache_exporter-${VER}.linux-amd64.tar.gz

Extract downloaded archive

..  code::

    tar xvf apache_exporter-${VER}.linux-amd64.tar.gz
    sudo cp apache_exporter-${VER}.linux-amd64/apache_exporter /usr/local/bin

`apache_exporter` should be executable from your current SHELL

..  code::

    $ apache_exporter -version
    apache_exporter, version 0.5.0 (branch: HEAD, revision: f6a5b4814ea795ee9eac745c55649cce9e5117a9)
        build user:       root@0fdc4d8924f5
        build date:       20171113-21:19:13
        go version:       go1.9.2

Step 2: Create Apache Prometheus exporter systemd service
---------------------------------------------------------

First, add `prometheus` user which will run the service

..  code::

    sudo groupadd --system prometheus
    sudo useradd -s /sbin/nologin --system -g prometheus prometheus

Then proceed to create a systemd service unit file.

..  code::

    sudo vim /etc/systemd/system/apache_exporter.service

Add below content

..  code::

    [Unit]
    Description=Prometheus
    Documentation=https://github.com/Lusitaniae/apache_exporter
    Wants=network-online.target
    After=network-online.target

    [Service]
    Type=simple
    User=prometheus
    Group=prometheus
    ExecReload=/bin/kill -HUP $MAINPID
    ExecStart=/usr/local/bin/apache_exporter \
    --insecure \
    --scrape_uri=http://localhost/server-status/?auto \
    --telemetry.address=0.0.0.0:9117 \
    --telemetry.endpoint=/metrics

    SyslogIdentifier=apache_exporter
    Restart=always

    [Install]
    WantedBy=multi-user.target

The service will listen on port `9117`, and metrics exposed on `/metrics`
URI. If Apache metrics are not on `http://localhost/server-status/?auto`
you’ll need to change the URL.

For Init system like CentOS 6.x, create an init script under `/etc/init.d/`

..  code::

    sudo vim /etc/init.d/apache_exporter

Add

..  code::bash

    #!/bin/bash
    # Author: Josphat Mutai, kiplangatmtai@gmail.com , https://github.com/jmutai
    # apache_exporter     This shell script takes care of starting and stopping Prometheus apache exporter
    #
    # chkconfig: 2345 80 80
    # description: Prometheus apache exporter  start script
    # processname: apache_exporter
    # pidfile: /var/run/apache_exporter.pid

    # Source function library.
    . /etc/rc.d/init.d/functions

    RETVAL=0
    PROGNAME=apache_exporter
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
        if [[ -f $PIDFILE ]] > /dev/null; then
            echo "apache_exporter  is already running"
            exit 0
        fi

        echo -n "Starting apache_exporter  service…"
        daemonize -u ${USER} -p ${PIDFILE} -l ${LOCKFILE} -a -e ${LOGFILE} -o ${LOGFILE} ${PROG} ${ARGS}
        RETVAL=$?
        echo ""
        return $RETVAL
    }

    stop() {
        if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
            echo "Service not running"
            return 1
        fi
        echo 'Stopping service…'
        #kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
        killproc -p ${PIDFILE} -d 10 ${PROG}
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f ${LOCKFILE} ${PIDFILE}
        return $RETVAL
    }

    status() {
        if [ -f "$PIDFILE" ] || kill -0 $(cat "$PIDFILE"); then
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

Install `daemonize` package.

..  code::

    sudo yum -y install daemonize

Create Arguments configuration file

..  code::

    sudo vim /etc/sysconfig/apache_exporter

Add

..  code::

    ARGS="--insecure --scrape_uri=http://localhost/server-status/?auto --telemetry.address=0.0.0.0:9117 --telemetry.endpoint=/metrics"

Test the script

..  code::

    # /etc/init.d/apache_exporter
    Usage: /etc/init.d/apache_exporter {start|stop|restart}

Step 3: Start Apache Prometheus exporter and enable service to start on boot
----------------------------------------------------------------------------

..  code::

    sudo /etc/init.d/apache_exporter start
    sudo chkconfig apache_exporter on

You can verify using

..  code::

    $ sudo /etc/init.d/apache_exporter status
    apache exporter  service running...
    Service PID: 1970

    $ sudo chkconfig --list | grep apache_exporter
    apache_exporter 0:off   1:off   2:on    3:on    4:on    5:on    6:off

    $ sudo ss -tunelp | grep 9117
    tcp    LISTEN     0      128                   :::9117                 :::*      users:(("apache_exporter",1970,6)) ino:1823474168 sk:ffff880341cd7800

Step 4: Add exporter job to Prometheus
--------------------------------------

Add a job to the Prometheus server for scraping metrics. Edit
`/etc/prometheus/prometheus.yml`

..  code::

    # Apache Servers
    - job_name: apache1
        static_configs:
        - targets: ['10.1.10.15:9117']
            labels:
            alias: server1-apache

    - job_name: apache2
        static_configs:
        - targets: ['10.1.10.16:9117']
            labels:
            alias: server2-apache

Restart `prometheus` service for scraping to start

..  code::

    sudo systemctl restart prometheus

Test access to port `9117` from Prometheus server

..  code::

    $ telnet 10.1.10.15 9117
    Trying 10.1.10.15...
    Connected to 10.1.10.15.
    Escape character is '^]'.
    ^]

Step 5: Add Dashboard to Grafana
--------------------------------

The final step is to create your own Dashboard for visualizing Apache metrics.
For this demo, we’ll use https://github.com/rfrail3/grafana-dashboards
Grafana Dashboards by Ricardo F. The dashboard ID is `3894`. You should have
Prometheus Data source already added to Grafana, or use the link
https://prometheus.io/docs/visualization/grafana/ Add Prometheus data source
to add one.

Once the data source has been added, Import Apache Grafana Dashboard by
navigating to `Dashboard > Import`. Use `3894` for Grafana Dashboard ID.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/import-apache-prometheus-dashboard-min-696x326.png[]

Give it a descriptive name and select *Prometheus* data source added earlier.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/import-apache-prometheus-dashboard-02-min-696x270.png[]

Click “*Import*” button to start using the dashboard. After a few minutes,
the metrics should start showing.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/apache-prometheus-metrics-grafana-min-696x294.png[]

Select a different host to show metrics for using the drop-down menu at the
top of the metrics dashboard. In my next Apache monitoring guide, I’ll cover
the use of InfluxDB and Grafana to monitor Apache Web server.
