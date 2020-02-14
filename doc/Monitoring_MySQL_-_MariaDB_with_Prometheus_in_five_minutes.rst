Monitoring MySQL / MariaDB with Prometheus in five minutes
==========================================================

https://computingforgeeks.com/monitoring-mysql-mariadb-with-prometheus-in-five-minutes/

(Last Updated On: September 10, 2018)

Prometheus is a leading time series database and monitoring solution that is
open source. Prometheus collects metrics from configured targets at given
intervals, evaluates rule expressions, displays the results, and can trigger
alerts if some condition is observed to be true.

Here we will look at how to configure Prometheus MySQL exporters on database
servers, both MySQL MariaDB and visualizing data with Grafana. This will
enable you to have a good view of database performance and know where to
check whenever you have issues.  The configuration of alerting rules is
beyond the scope of this guide, but I’ll try to cover it in the next guides.

This guide will have three main steps

1. Installation and configuration of Prometheus server
2. Installation and configuration of MySQL Prometheus exporter on database
   servers
3. Creating / Importing MySQL Grafana dashboards – We will use readily
   baked dashboards by Percona.

Step 1: Install and Configure Prometheus server
-----------------------------------------------

I had written a comprehensive guide on how to install and configure Prometheus
server. The guide was titled for Ubuntu and CentOS 7 but it should work for
any other systemd server.

How to Install Prometheus Server on CentOS / Ubuntu

Follow the guide and you should have a working Prometheus server at the end.

Step 2: Install and Configure Prometheus MySQL Exporter on Linux
----------------------------------------------------------------

Once you have installed Prometheus server, you need to install Prometheus
exporter for MySQL server metrics. Note that the supported MySQL
versions is 5.5 and up.

Add Prometheus system user and group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  code::bash

    sudo groupadd --system prometheus
    sudo useradd -s /sbin/nologin --system -g prometheus prometheus

This user will manage the exporter service.

Download and install Prometheus MySQL Exporter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This should be done on MySQL / MariaDB servers, both slaves and master
servers. You may need to check https://github.com/prometheus/mysqld_exporter/releases
Prometheus MySQL exporter releases page for the latest release, then export
the latest version to `VER` variable as shown below:

..  code::bash

    export VER=0.11.0
    wget https://github.com/prometheus/mysqld_exporter/releases/download/v${VER}/mysqld_exporter-${VER}.linux-amd64.tar.gz
    tar xvf mysqld_exporter-${VER}.linux-amd64.tar.gz
    sudo mv  mysqld_exporter-${VER}.linux-amd64/mysqld_exporter /usr/local/bin/
    sudo chmod +x /usr/local/bin/mysqld_exporter

Clean installation by removing the tarball and extraction directory.

..  code::bash

    rm -rf mysqld_exporter-${VER}.linux-amd64
    rm mysqld_exporter-${VER}.linux-amd64.tar.gz

Create Prometheus exporter database user
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The user should have `PROCESS`, `SELECT`, `REPLICATION CLIENT` grants

..  code::sql

    CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'StrongPassword' WITH MAX_USER_CONNECTIONS 2;
    GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';
    FLUSH PRIVILEGES;
    EXIT

If you have a Master-Slave database architecture, create user on the
master servers only.

`WITH MAX_USER_CONNECTIONS 2` is used to set a max connection limit for
the user to avoid overloading the server with monitoring scrapes under
heavy load.

Configure database credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create database credentials file

..  code::bash

    sudo vim /etc/.mysqld_exporter.cnf

Add correct username and password for user create

..  code::bash

    [client]
    user=mysqld_exporter
    password=StrongPassword

Set ownership permissions:

..  code::bash

    sudo chown root:prometheus /etc/.mysqld_exporter.cnf

Create systemd unit file (For Systemd systems)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is for systemd servers, for SysV init system, use
https://computingforgeeks.com/prometheus-mysql-exporter-init-script-for-sysv-init-system/
Prometheus MySQL exporter init script for SysV init system

Create a new service file:

..  code::bash

    sudo vim /etc/systemd/system/mysql_exporter.service

Add the following content

..  code::bash

    [Unit]
    Description=Prometheus MySQL Exporter
    After=network.target
    User=prometheus
    Group=prometheus

    [Service]
    Type=simple
    Restart=always
    ExecStart=/usr/local/bin/mysqld_exporter \
    --config.my-cnf /etc/.mysqld_exporter.cnf \
    --collect.global_status \
    --collect.info_schema.innodb_metrics \
    --collect.auto_increment.columns \
    --collect.info_schema.processlist \
    --collect.binlog_size \
    --collect.info_schema.tablestats \
    --collect.global_variables \
    --collect.info_schema.query_response_time \
    --collect.info_schema.userstats \
    --collect.info_schema.tables \
    --collect.perf_schema.tablelocks \
    --collect.perf_schema.file_events \
    --collect.perf_schema.eventswaits \
    --collect.perf_schema.indexiowaits \
    --collect.perf_schema.tableiowaits \
    --collect.slave_status \
    --web.listen-address=0.0.0.0:9104

    [Install]
    WantedBy=multi-user.target

If your server has a public and private network, you may need to
replace `0.0.0.0:9104` with private IP, e.g. `192.168.4.5:9104`

When done, reload systemd and start `mysql_exporter` service.

..  code::bash

    sudo systemctl daemon-reload
    sudo systemctl enable mysql_exporter
    sudo systemctl start mysql_exporter

Configure MySQL endpoint to be scraped by Prometheus Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Login to your Prometheus server and Configure endpoint to scrape.
Below is an example for two MySQL database servers.

..  code::yaml

    scrape_configs:
    - job_name: server1_db
        static_configs:
        - targets: ['10.10.1.10:9104']
            labels:
            alias: db1

    - job_name: server2_db
        static_configs:
        - targets: ['10.10.1.11:9104']
            labels:
            alias: db2

The first server has the IP address `10.10.1.10` and the second one
is `10.10.1.11`. Add other targets using the similar format.
*Job names* should be *unique* for each target.

.. note::
    Prometheus Server should be able to reach the targets over the
    network. Ensure you have correct network/firewall configurations.

Step 3: Creating / Importing MySQL Grafana dashboards
-----------------------------------------------------

Now that we have the targets configured and agents to be monitored, we should
be good to add Prometheus data source to Grafana so that we can do metrics
visualization. If you don’t have a ready Grafana server, use any of the
guides below to install Grafana:

Install Grafana and InfluxDB on CentOS 7

How to Install Grafana on Ubuntu and Debian

When installed, login to admin dashboard and add Datasource by navigating
to `Configuration > Data Sources`.

..  code::bash

    Name: Prometheus
    Type: Prometheus
    URL: http://localhost:9090

If Prometheus server is not on the same host as Grafana, provide IP address
of the server.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-add-data-source-min-696x450.png[]

## Create / Import Grafana Dashboard for MySQL Prometheus exporter

If you don’t have all the golden time to create your own dashboards, you
can use one created by link:https://github.com/percona/grafana-dashboards
Percona, they are Open source.

Let’s download `MySQL_Overview` dashboard which has a good overview of database
performance.

..  code::bash

    $ mkdir ~/grafana-dashboards
    $ cd ~/grafana-dashboards
    $ wget https://raw.githubusercontent.com/percona/grafana-dashboards/master/dashboards/MySQL_Overview.json

### Upload Prometheus MySQL dashboard(s) to grafana

Go to `Dashboards > Import > Upload .json file`

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-import-dashboard-min-696x181.png[]

Locate the directory with dashboard file and import.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-import-dashboard-02-min.png[]

Metrics collected should start showing.

image:https://computingforgeeks.com/wp-content/uploads/2018/09/prometheus-grafana-metrics-min.png[]

If you wish to import all Percona dashboards for Prometheus, install them
on Grafana server.

..  code::bash

    git clone https://github.com/percona/grafana-dashboards.git
    cp -r grafana-dashboards/dashboards /var/lib/grafana/

You need to restart Grafana server to import these dashboards.

..  code::bash

    sudo systemctl restart grafana-server
    sudo service grafana-server restart

You can then start using the dashboards on Grafana. I’ll do a guide for how
to Monitor Linux server with Prometheus, for OS metrics, before then, check
similar guides below:
