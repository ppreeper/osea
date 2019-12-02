How to Monitor Redis Server with Prometheus and Grafana in 5 minutes
====================================================================

https://computingforgeeks.com/how-to-monitor-redis-server-with-prometheus-and-grafana-in-5-minutes/

(Last Updated On: September 24, 2018)

This guide will focus on monitoring of Redis application on a Linux server.
Redis is an open source in-memory data structure store, used as a database,
cache and message broker. Redis provides a distributed, in-memory key-value
database with optional durability.

Redis supports different kinds of abstract data structures, such as strings,
sets, maps, lists, sorted sets, spatial indexes, and bitmaps.

So far we have covered the following monitoring with Prometheus:

* Monitoring Ceph Cluster with Prometheus and Grafana
* How to Monitor Linux Server Performance with Prometheus and Grafana in 5
  minutes
* How to Monitor BIND DNS server with Prometheus and Grafana
* Monitoring MySQL / MariaDB with Prometheus in five minutes
* How to Monitor Apache Web Server with Prometheus and Grafana in 5 minutes

## What’s exported by Redis exporter?

Most items from the INFO command are exported, see
http://redis.io/commands/info for details. In addition, for every database
there are metrics for total keys, expiring keys and the average TTL for
keys in the database.

You can also export values of keys if they’re in numeric format by using
the -check-keys flag. The exporter will also export the size (or, depending
on the data type, the length) of the key. This can be used to export the
number of elements in (sorted) sets, hashes, lists, etc.

## Setup Pre-requisite

1. Installed Prometheus Server – Install Prometheus Server on CentOS 7 and
   Ubuntu 18.04
2. Installed Grafana Data visualization & Monitoring – Install Prometheus
   Server on CentOS 7 and Ubuntu 18.04

Step 1: Download and Install Redis Prometheus exporter
------------------------------------------------------

This Prometheus exporter for Redis metrics supports Redis 2.x, 3.x, and 4.x

..  code::

    export VER="0.21.2"
    wget https://github.com/oliver006/redis_exporter/releases/download/v${VER}/redis_exporter-v${VER}.linux-amd64.tar.gz

Extract the downloaded archive file

..  code::

    tar xvf redis_exporter-v${VER}.linux-amd64.tar.gz
    sudo mv redis_exporter /usr/local/bin/
    rm -f redis_exporter-v${VER}.linux-amd64.tar.gz

`redis_exporter` should be executable from your current SHELL

..  code::

    $ redis_exporter  -version
    INFO[0000] Redis Metrics Exporter v0.21.2    build date: 2018-09-20-18:15:12    sha1: 8bb0b841e9a70b0348f69483e58fea01d521c47a    Go: go1.10.4

To get a list of all options supported, pass `--help` option

..  code::

    # redis_exporter  --help
    Usage of redis_exporter:
    -check-keys string
            Comma separated list of key-patterns to export value and length/size, searched for with SCAN
    -check-single-keys string
            Comma separated list of single keys to export value and length/size
    -debug
            Output verbose debug information
    -log-format string
            Log format, valid options are txt and json (default "txt")
    -namespace string
            Namespace for metrics (default "redis")
    -redis-only-metrics
            Whether to export go runtime metrics also
    -redis.addr string
            Address of one or more redis nodes, separated by separator
    -redis.alias string
            Redis instance alias for one or more redis nodes, separated by separator
    -redis.file string
            Path to file containing one or more redis nodes, separated by newline. NOTE: mutually exclusive with redis.addr
    -redis.password string
            Password for one or more redis nodes, separated by separator
    -script string
            Path to Lua Redis script for collecting extra metrics
    -separator string
            separator used to split redis.addr, redis.password and redis.alias into several elements. (default ",")
    -use-cf-bindings
            Use Cloud Foundry service bindings
    -version
            Show version information and exit
    -web.listen-address string
            Address to listen on for web interface and telemetry. (default ":9121")
    -web.telemetry-path string
            Path under which to expose metrics. (default "/metrics")

Step 2: Create Prometheus redis exporter systemd service / Init script
----------------------------------------------------------------------

The user `prometheus` will be used to run the service. Add `prometheus` system
user if it doesn’t exist

..  code::

    sudo groupadd --system prometheus
    sudo useradd -s /sbin/nologin --system -g prometheus prometheus

Then proceed to create a systemd service unit file.

..  code::

    sudo vim /etc/systemd/system/redis_exporter.service

Add below content

..  code::

    [Unit]
    Description=Prometheus
    Documentation=https://github.com/oliver006/redis_exporter
    Wants=network-online.target
    After=network-online.target

    [Service]
    Type=simple
    User=prometheus
    Group=prometheus
    ExecReload=/bin/kill -HUP $MAINPID
    ExecStart=/usr/local/bin/redis_exporter \
    --log-format=txt \
    --namespace=redis \
    --web.listen-address=:9121 \
    --web.telemetry-path=/metrics

    SyslogIdentifier=redis_exporter
    Restart=always

    [Install]
    WantedBy=multi-user.target

For Init system
~~~~~~~~~~~~~~~

Install `daemonize` ( CentOS / Ubuntu )

..  code::

    sudo yum -y install daemonize
    sudo apt-get install daemonize

Create init script

..  code::

    sudo vim /etc/init.d/redis_exporter

Add

..  code::

    #!/bin/bash
    # Author: Josphat Mutai, kiplangatmtai@gmail.com , https://github.com/jmutai
    # redis_exporter     This shell script takes care of starting and stopping Prometheus redis exporter
    #
    # chkconfig: 2345 80 80
    # description: Prometheus redis exporter  start script
    # processname: redis_exporter
    # pidfile: /var/run/redis_exporter.pid

    # Source function library.
    . /etc/rc.d/init.d/functions

    RETVAL=0
    PROGNAME=redis_exporter
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
            echo "redis_exporter  is already running"
            exit 0
        fi

        echo -n "Starting redis_exporter  service…"
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
        echo "redis exporter  service running..."
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

    sudo vim /etc/sysconfig/redis_exporter

Define used command Arguments

..  code::

    ARGS="--log-format=txt \
    --namespace=redis \
    --web.listen-address=:9121 \
    --web.telemetry-path=/metrics"

Test the script

..  code::

    # /etc/init.d/redis_exporter
    Usage: /etc/init.d/redis_exporter {start|stop|restart}

Step 3: Start Redis Prometheus exporter and enable service to start on boot
---------------------------------------------------------------------------

For a Systemd server, use `systemctl` command

..  code::

    sudo systemctl enable redis_exporter
    sudo systemctl start redis_exporter

For SysV Init system, use

..  code::

    sudo /etc/init.d/redis_exporter start
    sudo chkconfig redis_exporter on

You can verify that the service is running using

..  code::

    $ sudo /etc/init.d/redis_exporter status
    redis exporter  service running...
    Service PID: 27106

    $ sudo chkconfig --list | grep redis_exporter
    redis_exporter 0:off   1:off   2:on    3:on    4:on    5:on    6:off

    $ sudo ss -tunelp | grep 9121
    tcp    LISTEN     0      128                   :::9121                 :::*      users:(("redis_exporter",1970,6)) ino:1823474168 sk:ffff880341cd7800

Step 4: Add exporter job to Prometheus
--------------------------------------

The last step is to add a job to the Prometheus server for scraping metrics.
Edit `/etc/prometheus/prometheus.yml`

..  code::

    # Redis Servers
    - job_name: 10.10.10.3-redis
        static_configs:
        - targets: ['10.10.10.3:9121']
            labels:
            alias: 10.10.10.3

    - job_name: 10.10.10.4-redis
        static_configs:
        - targets: ['10.10.10.4:9121']
            labels:
            alias: 10.10.10.4

Restart prometheus service for scraping of data metrics to begin

..  code::

    sudo systemctl restart prometheus

Test access to port `9121` from Prometheus server, it should be able to
connect.

..  code::

    $ telnet 10.1.10.15 9121
    Trying 10.1.10.15...
    Connected to 10.1.10.15.
    Escape character is '^]'.
    ^]

If it can’t connect, check your Service port and firewall.

Step 5: Add Dashboard to Grafana
--------------------------------

Add Prometheus data source to Grafana and import or create a grafana
dashboard for Redis.

Grafana dashboard is available on https://grafana.net/dashboards/763
grafana.net and/or https://github.com/oliver006/redis_exporter/blob/master/contrib/grafana_prometheus_redis_dashboard.json
github.com . My Job configuration uses an *alias*, I’ll use Grafana dashboard
with *host & alias* selector is available on https://github.com/oliver006/redis_exporter/blob/master/contrib/grafana_prometheus_redis_dashboard_alias.json
github.com.

Download the dashboard `json` file

..  code::

    wget https://raw.githubusercontent.com/oliver006/redis_exporter/master/contrib/grafana_prometheus_redis_dashboard_alias.json

On Grafana UI, go to `Create > Import Dashboard > Upload .json` File. Select
downloaded json file and click “*Import*“.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-redis-import-dashboard-min-696x324.png[]

Wait for data to start appearing on your Grafana Dashboard, below is a
sample view

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-redis-dashboard-min-696x299.png[]

Enjoy using Grafana to monitor your Redis server(s).
