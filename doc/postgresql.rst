Postgresql
===========

* postgresql-contrib
* pgbench

https://blog.codeship.com/tuning-postgresql-with-pgbench/

Tuning PostgreSQL with pgbench
-------------------------------

Last updated: 2017-05-08

by Ben Cane | 4 Comments

Reading Time: 10 minutes

When it comes to performance tuning an environment, often the first place to
start is with the database. The reason for this is that most applications
rely very heavily on a database of some sort.

Unfortunately, databases can be one of the most complex areas to tune. The
reason I say that is because tuning a database service properly often involves
tuning more than the database service itself; it often requires making
hardware, OS, or even application modifications.

On top of requiring a diverse skill set, one of the biggest challenges with
tuning a database is creating enough simulated database traffic to stress
the database service. Which is why today’s article will explore `pgbench`,
a benchmarking tool used to measure performance of a PostgreSQL instance.

PostgreSQL is a highly popular open-source relational database. One of the
nice things about PostgreSQL is that there are quite a few tools that have
been created to assist with the management of PostgreSQL; `pgbench` is one
such tool.

While exploring pgbench, we will also use it to measure the performance
gains/loss for a common PostgreSQL tunable.

Setting Up a PostgreSQL Instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before we can use `pgbench` to tune a database service, we must first stand
up that database service. The below steps will outline how to set up a basic
PostgreSQL instance on an Ubuntu 16.04 server.

Installing with `apt-get`
^^^^^^^^^^^^^^^^^^^^^^^^^^

Installing PostgreSQL on an Ubuntu system is fairly easy. The bulk of the
work is accomplished by simply running the `apt-get` command.

.. code::

    apt-get install postgresql postgresql-contrib

The above `apt-get` command installs both the `postgresql` and
`postgresql-contrib` packages. The postgresql package installs the base
PostgreSQL service.

The `postgresql-contrib` package installs additional contributions to
PostgreSQL. These contributions have not yet been added to the official
package but often provide quite a bit of functionality.

With the packages installed, we now have a running PostgreSQL instance.
We can verify this by using the `systemctl` command to check the status
of PostgreSQL.

.. code::

    > systemctl status postgresql
   ● postgresql.service - PostgreSQL RDBMS
      Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
      Active: active (exited) since Mon 2017-01-02 21:14:36 UTC; 7h ago
   Process: 16075 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 16075 (code=exited, status=0/SUCCESS)

   Jan 02 21:14:36 ubuntu-xenial systemd[1]: Starting PostgreSQL RDBMS...
   Jan 02 21:14:36 ubuntu-xenial systemd[1]: Started PostgreSQL RDBMS.

The above indicates our instance started without any issues. We can now move
on to our next step, creating a database.

==== Creating a database

When we installed the `postgresql` package, this package included the creation
of a user named `postgres`. This user is used as the owner of the running
instance. It also serves as the admin user for the PostgreSQL service.

In order to create a database, we will need to login to this user, which is
accomplished by executing the `su` command.

.. code::

    su - postgres

Once switched to the `postgres` user, we can log in to the running instance
by using the PostgreSQL client, `psql`.

.. code::

    $ psql
   psql (9.5.5)
   Type "help" for help.

   postgres=#

After executing the `psql` command, we were dropped into PostgreSQL’s command
line environment. From here, we can issue *SQL* statements or use special
client commands to perform actions.

As an example, we can list the current databases by issuing the `\list`
command.

.. code::

    postgres-# \list
                                    List of databases
      Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
   -----------+----------+----------+-------------+-------------+-----------------------
   postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
   template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
            |          |          |             |             | postgres=CTc/postgres
   template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
            |          |          |             |             | postgres=CTc/postgres
   (3 rows)

After issuing the `\list` command, three databases were returned. These are
default databases that were set up during the initial installation process.

For our testing today, we will be creating a new database. Let’s go ahead and
create that database, naming it example. We can do so by issuing the following
SQL statement:

.. code::

    CREATE DATABASE example;

Once executed, we can validate that the database has been created by issuing
the `\list` command again.

.. code::

    postgres=# \list
                                    List of databases
      Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
   -----------+----------+----------+-------------+-------------+-----------------------
   example   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
   postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
   template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
            |          |          |             |             | postgres=CTc/postgres
   template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
            |          |          |             |             | postgres=CTc/postgres
   (4 rows)

At this point, we now have an empty database named example. From this point, we
will need to return to our `bash` shell to execute `pgbench` commands. We can do
this by issuing the `\q` (quit) command.

.. code::

    postgres-# \q

Once logged out of the PostgreSQL command line environment, we can get started
using `pgbench` to benchmark our database instance’s performance.

=== Using pgbench to Measure Performance

One of the most difficult things in measuring database performance is
generating enough load. A popular option is to simply bombard test instances
of the target application/s with test transactions. While this is a useful
test that provides DB performance in relation to the application, it can be
problematic sometimes as application bottlenecks can limit database testing.

For situations such as this, tools like `pgbench` come in handy. With
`pgbench`, you can either use a sample database provided with `pgbench`
or have `pgbench` run custom queries against an application database.

In this article, we will be using the example database that comes with
`pgbench`.

==== Setting up the pgbench sample database

The set up of the sample database is quite easy and fairly quick. We can start
this process by executing `pgbench` with the `-i` (initialize) option.

.. code::

    $ pgbench -i -s 50 example
   creating tables...
   5000000 of 5000000 tuples (100%) done (elapsed 5.33 s, remaining 0.00 s)
   vacuum...
   set primary keys...
   done.

In the command above, we executed pgbench with the `-i` option and the `-s`
option followed by the database name (`example`).

The `-i` (initialize) option will tell `pgbench` to initialize the database
specified. What this means is that `pgbench` will create the following tables
within the example database.

.. code::

    table                   # of rows
   pgbench_branches        1
   pgbench_tellers         10
   pgbench_accounts        100000
   pgbench_history         0

By default, `pgbench` will create the tables above with the number of rows
shown above. This creates a simple 16MB database.

Since we will be using `pgbench` to measure changes in performance, a small
16MB database will not be enough to stress our instance. This is where the
`-s` (scaling) option comes into play.

The `-s` option is used to multiply the number of rows entered into each table.
In the command above, we entered a “scaling” option of `50`. This told
`pgbench` to create a database with 50 times the default size.

What this means is our `pgbench_accounts` table now has `5,000,000` records.
It also means our database size is now 800MB (50 x 16MB).

To verify that our tables have been created successfully, let’s go ahead
and run the `psql` client again.

.. code::

    $ psql -d example
   psql (9.5.5)
   Type "help" for help.

   example=#

In the command above, we used the `-d` (database) flag to tell `psql` to
not only connect to the PostgreSQL service but to also switch to the
_example_ database.

Since we are currently using the example database, we can issue the `\dt`
command to list the tables available within that database.

.. code::

    example=# \dt
               List of relations
   Schema |       Name       | Type  |  Owner
   --------+------------------+-------+----------
   public | pgbench_accounts | table | postgres
   public | pgbench_branches | table | postgres
   public | pgbench_history  | table | postgres
   public | pgbench_tellers  | table | postgres
   (4 rows)

From the table above, we can see that `pgbench` created the four expected
tables. This means our database is now populated and ready to be used to
measure our database instance’s performance.

==== Establishing a baseline

When doing any sort of performance tuning, it is best to first establish a
baseline performance. This baseline will serve as a measurement as to whether
or not the changes you have performed have increased or decreased performance.

Let’s go ahead and call `pgbench` to establish the baseline for our “out of
the box” PostgreSQL instance.

.. code::

    $ pgbench -c 10 -j 2 -t 10000 example
   starting vacuum...end.
   transaction type: TPC-B (sort of)
   scaling factor: 50
   query mode: simple
   number of clients: 10
   number of threads: 2
   number of transactions per client: 10000
   number of transactions actually processed: 100000/100000
   latency average: 4.176 ms
   tps = 2394.718707 (including connections establishing)
   tps = 2394.874350 (excluding connections establishing)

When calling `pgbench`, we add quite a few options to the command. The
first is `-c` (clients), which is used to define the number of clients to
connect with. For this testing, I used `10` to tell `pgbench` to execute
with 10 clients.

What this means is that when `pgbench` is executing tests, it opens 10
different sessions.

The next option is the `-j` (threads) flag. This flag is used to define
the number of worker processes for `pgbench`. In the above command, I
specified the value of `2`. This will tell `pgbench` to start two worker
processes during the benchmarking.

The third option used is `-t` (transactions), which is used to specify
the number of transactions to execute. In the command above, I provided
the value of `10,000`. However this doesn’t mean that only 10,000
transactions will be executed against our database service. What it means
is that each client session will execute 10,000 transactions.

To summarize, the baseline test run was two `pgbench` worker processes
simulating `10,000` transactions from `10` clients for a total of
`100,000` transactions.

With that understanding, let’s take a look at the results of this first
test.

.. code::

    $ pgbench -c 10 -j 2 -t 10000 example
   starting vacuum...end.
   transaction type: TPC-B (sort of)
   scaling factor: 50
   query mode: simple
   number of clients: 10
   number of threads: 2
   number of transactions per client: 10000
   number of transactions actually processed: 100000/100000
   latency average: 4.176 ms
   tps = 2394.718707 (including connections establishing)
   tps = 2394.874350 (excluding connections establishing)

The output of `pgbench` has quite a bit of information. Most of it describes
the test scenarios being executed. The part that we are most interested in is
the following:

.. code::

    tps = 2394.718707 (including connections establishing)
   tps = 2394.874350 (excluding connections establishing)

From these results, it seems our baseline is `2,394` database transactions
per second. Let’s go ahead and see if we can increase this number by modifying
a simple configuration parameter within PostgreSQL.

=== Adding More Cache

One of the go-to parameters for anyone tuning PostgreSQL is the
`shared_buffers` parameter. This parameter is used to specify the amount
of memory the PostgreSQL service can utilize for caching. This caching
mechanism is used to store the
contents of tables and indexes in memory.

To show how we can use `pgbench` for performance tuning, we will be adjusting
this value to test performance gains/losses.

By default, the `shared_buffers` value is set to `128MB`, a fairly low value
considering the amount of available memory on most servers today. We can see
this setting for ourselves by looking at the contents of the
`/etc/postgresql/9.5/main/postgresql.conf` file. Within this file, we should
see the following.

.. code::

    # - Memory -

   shared_buffers = 128MB                 # min 128kB
                                          # (change requires restart)

Let’s go ahead and switch this value to `256MB`, effectively doubling our
available cache space.

.. code::

   # - Memory -

   shared_buffers = 256MB                  # min 128kB
                                           # (change requires restart)

Once completed, we will need to restart the PostgreSQL service. We can do
so by executing the `systemctl` command with the restart option.

.. code::

    systemctl restart postgresql

Once the service is fully up and running, we can once again use `pgbench`
to measure our performance.

.. code::

   $ pgbench -c 10 -j 2 -t 10000 example
   starting vacuum...end.
   transaction type: TPC-B (sort of)
   scaling factor: 50
   query mode: simple
   number of clients: 10
   number of threads: 2
   number of transactions per client: 10000
   number of transactions actually processed: 100000/100000
   latency average: 3.921 ms
   tps = 2550.313477 (including connections establishing)
   tps = 2550.480149 (excluding connections establishing)

In our earlier baseline test, we were able to hit a rate of `2,394`
transactions per second. In this last run, after updating the `shared_buffers`
parameter, we were able to achieve `2,550` transactions per second, an increase
of `156`. While this is not a bad start, we can still go further.

While the `shared_buffers` parameter might start off at `128MB`, the
recommended value for this parameter is one-fourth the system memory. Our test
system has `2GB` of system memory, a value we can verify with the `free` command.

.. code::

   $ free -m
                 total        used        free      shared  buff/cache   available
   Mem:           2000          54         109         548        1836        1223
   Swap:             0           0           0

In the output above, we can see that the `total` column shows a value of
`2000MB` on the row for memory. This column shows the total physical memory
`available` to the system. We can also see in the available column that `1223MB`
is showing available. This means we have up to `1.2` GB of free memory we can
use for our tuning purposes.

If we change our `shared_buffers` parameter to the recommended value of
one-fourth system memory, we would need to change it to `512MB`. Let’s go ahead
and make this change and rerun our `pgbench` test.

.. code::

   # - Memory -

      shared_buffers = 512MB                  # min 128kB
                                             # (change requires restart)

With the shared_buffers value updated in the
`/etc/postgresql/9.5/main/postgresql.conf`, we can go ahead and restart the
PostgreSQL service.

.. code::

   systemctl restart postgresql

After restarting, let’s rerun our test.

.. code::

   $ pgbench -c 10 -j 2 -t 10000 example
   starting vacuum...end.
   transaction type: TPC-B (sort of)
   scaling factor: 50
   query mode: simple
   number of clients: 10
   number of threads: 2
   number of transactions per client: 10000
   number of transactions actually processed: 100000/100000
   latency average: 3.756 ms
   tps = 2662.750932 (including connections establishing)
   tps = 2663.066421 (excluding connections establishing)

This time, our system was able to reach `2,662` transactions per second, an
additional increase of `112` transactions per second. Since our transactions
per second increased by at least `100` both times, let’s go a step further
and see what happens when changing this value to `1GB`.


.. code::

   = - Memory -

   shared_buffers = 1024MB                 # min 128kB
                                           # (change requires restart)

After updating the value, we will need to once again restart the PostgreSQL
service.

.. code::

   = systemctl restart postgresql

With the service restarted, we can now rerun our test.

.. code::

   $ pgbench -c 10 -j 2 -t 10000 example
   starting vacuum...end.
   transaction type: TPC-B (sort of)
   scaling factor: 50
   query mode: simple
   number of clients: 10
   number of threads: 2
   number of transactions per client: 10000
   number of transactions actually processed: 100000/100000
   latency average: 3.744 ms
   tps = 2670.791865 (including connections establishing)
   tps = 2671.079076 (excluding connections establishing)

This time, our transactions per second went from `2,662` to `2,671` and
increase of `9` transactions per second. This is a situation where we are
hitting diminishing returns.

While it is feasible for many environments to increase the `shared_buffers`
value beyond the one-fourth guideline, doing so does not return the same
results for this test database.

=== Summary

Based on the results of our testing, we can see that changing the value of
the `shared_buffers` from `128MB` to `512MB` on our test system resulted in
a `268` transactions per second increase in performance. Based on our
baseline results, that is a *10 percent* increase in performance.

We did this all on a base PostgreSQL instance using `pgbench`‘s sample
database. Meaning, we did not have to load our application to get a baseline
metric on how well PostgreSQL performs.

While we were able to increase our throughput by modifying the `shared_buffers`
parameter within PostgreSQL, there are many more tuning parameters available.
For anyone looking to tune a PostgreSQL instance, I would highly recommend
checking out PostgreSQL’s wiki.

link:https://severalnines.com/blog/benchmarking-postgresql-performance[

How to Benchmark PostgreSQL Performance
----------------------------------------

The purpose of benchmarking a database is not only to check capability of
database, but also the behavior of a particular database against your
application. Different hardwares provide different results based on the
benchmarking plan that you set. It is very important to isolate the server
(the actual one being benchmarked) from other elements like the servers
driving the load, or the servers used to collect and store performance
metrics. As part of the benchmarking exercise, you must get the application
characteristics like a) Is the application is read or write intensive? or
b) what is the read/write split (e.g. 80:20)? or c) How large is the
dataset?, is the data and structure representative of the actual production
database, etc.

PostgreSQL is world's most advanced open source database. If any enterprise
RDBMS customer wants to migrate their database to opensource, then
PostgreSQL would be the first option to evaluate.

This post covers the following:

* How to benchmark PostgreSQL
* What are the key performance factors in PostgreSQL
* * What are levers you can pull to increase performance
* What are performance pitfalls to avoid
* What are common mistakes people make?
* How do you know if your system is performing? What tools can you use?

How to benchmark PostgreSQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The standard tool to benchmark PostgreSQL is pgbench. By default, pgbench
tests are based on TPC-B. It involves 5 SELECT, INSERT, and UPDATE commands
per transaction. However, depending on your application behavior, you can
write your own script files. Let us look into the default and some script
oriented test results. We are going to use the latest version of PostgreSQL
for these tests, which is PostgreSQL 10 at the time of writing. You can
install it using ClusterControl, or using the instructions
here: https://www.openscg.com/bigsql/package-manager/.

Specs of machine

.. code::

   Version: RHEL 6 - 64 bit
   Memory : 4GB
   Processors: 4
   Storage: 50G
   PostgreSQL version: 10.0
   Database Size: 15G

Before you run benchmarking with pgbench tool, you would need to initialize
it below command:

.. code::

   -bash-4.1$ ./pgbench -i -p 5432 -d postgres
   NOTICE:  table "pgbench_history" does not exist, skipping
   NOTICE:  table "pgbench_tellers" does not exist, skipping
   NOTICE:  table "pgbench_accounts" does not exist, skipping
   NOTICE:  table "pgbench_branches" does not exist, skipping
   creating tables…
   100000 of 100000 tuples (100%) done (elapsed 0.18 s, remaining 0.00 s)
   Vacuum…
   set primary keys…
   done.

As shown in the NOTICE messages, it creates pgbench_history, pgbench_tellers,
pgbench_accounts, and pgbench_branches tables to run the transactions for
benchmarking.

Here is a simple test with 10 clients:

.. code::

   -bash-4.1$ ./pgbench -c 10
   starting vacuum...end.
   transaction type: <builtin: TPC-B (sort of)>
   scaling factor: 1
   query mode: simple
   number of clients: 10
   number of threads: 1
   number of transactions per client: 10
   number of transactions actually processed: 100/100
   latency average = 13.516 ms
   tps = 739.865020 (including connections establishing)
   tps = 760.775629 (excluding connections establishing)

As you see, it ran with 10 clients and 10 transaction per client. It gave you
739 transactions/sec.It gave you 739 transactions/sec. If you want to run it
for specific amount of time, you can use "-T" option. In general, a 15 mins
or 30 mins run is sufficient.

As of now, we talked about how to run pgbench, however not about what should
be options. Before you start the benchmarking, you should get proper details
from application team on:

* What type of workload?
* How many concurrent sessions?
* What is the average result set of queries?
* What are the expected tps(transaction per sec)?

Here is an example for read-only work loads. You can use "-S" option to use
only SELECTs which falls under read-only. Note that -n is to skip vacuuming
on tables.

.. code::

   -bash-4.1$ ./pgbench -c 100 -T 300 -S -n
   transaction type: <builtin: select only>
   scaling factor: 1000
   query mode: simple
   number of clients: 100
   number of threads: 1
   duration: 300 s
   number of transactions actually processed: 15741
   latency average = 1916.650 ms
   tps = 52.174363 (including connections establishing)
   tps = 52.174913 (excluding connections establishing)
   -bash-4.1$

Latency here is the average elapsed transaction time of each statement executed
by every client. It gives 52 tps with the hardware given. As this benchmark is
for a read-only environment, let us try tweaking shared_buffers and
effective_cache_size parameters in postgresql.conf file and check the tps
count. They are at default values in the above test, try increasing the values,
and check the results.

.. code::

   -bash-4.1$ ./pgbench -c 100 -T 300 -S -n
   transaction type: <builtin: select only>
   scaling factor: 1000
   query mode: simple
   number of clients: 100
   number of threads: 1
   duration: 300 s
   number of transactions actually processed: 15215
   latency average = 1984.255 ms
   tps = 68.396758 (including connections establishing)
   tps = 68.397322 (excluding connections establishing)

Changing the parameters improved performance by 30%.

pgbench typically runs transactions on its own tables. If you have a workload
of 50% reads and 50% writes (or a 60:40 environment), you can create a script
file with a set of statements to achieve the expected workload.

.. code::

   -bash-4.1$ cat /tmp/bench.sql
   INSERT INTO test_bench VALUES(1,'test');
   INSERT INTO test_bench VALUES(1,'test');
   SELECT * FROM test_bench WHERE id=1;
   SELECT * FROM test_bench WHERE id=2;
   -bash-4.1$ ./pgbench -c 100 -T 300 -S -n -f /tmp/bench.sql
   transaction type: multiple scripts
   scaling factor: 1000
   query mode: simple
   number of clients: 100
   number of threads: 1
   duration: 300 s
   number of transactions actually processed: 25436
   latency average = 1183.093 ms
   tps = 84.524217 (including connections establishing)
   tps = 84.525206 (excluding connections establishing)
   SQL script 1: <builtin: select only>
   - weight: 1 (targets 50.0% of total)
   - 12707 transactions (50.0% of total, tps = 42.225555)
   - latency average = 914.240 ms
   - latency stddev = 558.013 ms
   SQL script 2: /tmp/bench.sql
   - weight: 1 (targets 50.0% of total)
   - 12729 transactions (50.0% of total, tps = 42.298662)
   - latency average = 1446.721 ms
   - latency stddev = 765.933 ms

What are the key performance factors in PostgreSQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


If we consider a real production environment, it is consolidated with
different components at application level, hardware like CPU and memory,
and the underlying operating system. We install PostgreSQL on top of
the operating system to communicate with other components of the
production environment. Every environment is different and overall
performance will be degraded if it is not properly configured. In
PostgreSQL, some queries run faster and some slow, however it depends
on configuration that has been set. The goal of database performance
optimization is to maximize the database throughput and minimize
connections to achieve the largest possible throughput. Below are
few key performance factors that affect the database:

* Workload
* Resource
* Optimization
* Contention

Workload consists of batch jobs, dynamic queries for online
transactions, data analytics queries which are used for generating
reports. Workload may be different during the period of the day,
week or month, and depends on applications. Optimization of every
database is unique. It can be database level configuration or query
level optimization. We will be covering more about optimization in
further sections of the post. Contention is the condition where two
or more components of the workload are attempting to use a single
resource in a conflicting way. As contention increases, throughput
decreases.

What are tips and best practices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here are few tips and best practices that you can follow to avoid
performance issues:

* You can consider running maintenance activities like VACUUM and ANALYZE
  after a large modification in your database. This helps the planner to
  come up with the best plan to execute queries.
* Look for any need to index tables. It makes queries run much faster,
  rather than having to do full table scans.
* To make an index traversal much faster, you can use CREATE TABLE AS or
  CLUSTER commands to cluster rows with similar key values.
* When you see a performance problem, use the EXPLAIN command to look at
  the plan on how the optimizer has decided to execute your query.
* You can try changing the plans by influencing the optimizer by modifying
  query operators. For example, if you see a sequential scan for your query,
  you can disable seq scan using "SET ENABLE_SEQSCAN TO OFF". There is no
  guarantee that the optimizer would not choose that operator if you disable
  it. The optimizer just considers the operator to be much more expensive.
  More details are
  here: https://www.postgresql.org/docs/current/static/runtime-config-query.html
* You can also try changing the costs parameters like CPU_OPERATOR_COST,
  CPU_INDEX_TUPLE_COST, CPU_TUPLE_COST, RANDOM_PAGE_COST, and
  EFFECTIVE_CACHE_SIZE to influence the optimizer. More details are
  here: https://www.postgresql.org/docs/current/static/runtime-config-query.html#RUNTIME-CONFIG-QUERY-CONSTANTS
* Always filter data on the server rather than in client application. It
  will minimize the network traffic and gives better performance.
* To perform common operations, it is always recommended to use server-side
  procedures (triggers and functions). Server-side triggers or functions are
  parsed, planned, and optimized the first time they are used, not every time.

What are common mistakes people make
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

One of the common mistakes that people do is running the database server
and database with default parameters. The PostgreSQL default configuration
is tested in few environments, however not every application would find
those values optimal. So you need to understand your application behavior
and based on it, set your configuration parameters. You can use the pgTune
tool to get values for your parameters based on the hardware that you are
using. You can have a look at: http://pgtune.leopard.in.ua/. However, keep
in mind that you will have to test your application with changes that you
make, to see if there are any performance degradation with the changes.

Another thing to consider would be indexing the database. Indexes help to
fetch the data faster, however more indexes create issues with loading the
data. So always check if any unused indexes are there in the database, and
get rid of those to reduce the maintenance of those indexes and improve
loading of data.

== link:https://wiki.postgresql.org/wiki/Pgbenchtesting[

Pgbenchtesting
---------------

Testing for Performance Regression with pgBench 9.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This page will eventually be merged into Regression Testing with pgbench

* pgBench 9.0 Docs

In order to test for performance regressions (or improvements) it's necessary
to install two versions of PostgreSQL on the same machine. Otherwise, you
have no comparable statistics. For example, you might install 8.4.3 and
9.0alpha5, or you might install 9.0alpha4 and 9.0alpha5. You also might
run against the same test version in two modes: with HS/SR and without,
for example.

Since pgbench is such a simple test, you'll need to run several different
runs to see different aspects of performance. It's also a good idea to run
each at least 3 times, since pgbench has some randomness to it.

Always run the same version of pgBench against both databases, probably the
newer version.

Some factors:

* *Where to run pgBench*: Ideally, you want to run it from a separate
  machine from the one holding the database. That way, you don't have
  pgBench taking CPU away from the database.
* *Number of Threads and Clients to Use*: This depends on the number of
  cores on the machine(s) you're testing. For each core available to the
  database, I suggest 1 thread and 2 clients. Note: do not use multi-threaded
  pgBench on non-threadsafe systems; you will get unreliable results.
* *PostgreSQL Configuration*: use what you'd consider a normal performance
  configuration for the machine being tested. Use (as much as possible)
  the same configuration for both.
* *Time vs. Transactions*: results which run pgbench for a specific
  amount of time are easier to compare. You also know how long they'll
  take you.
* *Initializing Databases*: if you are going to use the same database
  for several test runs in a row, it's important that you "prime" it by
  running pgbench against it for at least 20 minutes first, or the first
  couple of tests will be misleadingly fast. Alternately, you can initialize
  a new database for each test run.
* *Time to Run* Ideally, you'd do each pgbench run for at least an hour
  for useful results. However, this interferes with running a lot of
  different tests for people who don't do this full-time or have a dedicated
  testing server. Make sure to run it for at least 10 minutes, though, to
  get results you can even measure. Possibly run the most interesting
  results in a 1-hour test. All tests below run for 10 minutes.

What follows are some examples of tests. The command line given would
be appropriate for a machine with 2 cores available to the database and
thread-safe.

Memory vs. Disk Performance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You want to test pgbench at the 3 levels of performance related to disk:
in buffer, mostly in cache, and all on disk. You manipulate this by
changing the scale factor, following these two formulas, assuming a
dedicated database server.

scale / 75 = 1GB database

* In Buffer Test: 0.1 X RAM
* Mostly Cached: 0.9 X RAM
* Mostly on Disk: 4.0 X RAM

Note that the mostly-on-disk test may require you to have a considerable
amount of disk space available for your database.

Examples: the following assume a 2-core machine with 2GB of RAM, running
for 10 minutes:

Buffer test:

.. code::

   pgbench -i -s 15 bench1
   pgbench -c 4 -j 2 -T 600 bench1

Mostly Cache Test:

.. code::

   pgbench -i -s 70 bench2
   pgbench -c 4 -j 2 -T 600 bench2

On-Disk Test:

.. code::

   pgbench -i -s 600 bench3
   pgbench -c 4 -j 2 -T 600 bench3

Measuring the amount of time required to initialize the three databases
will also provide interesting results.

Read vs. Write Performance
~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is also interesting to test relative speed of different write patterns.
For this set of tests, use either the Mostly Cache or On-Disk size
database, or something in-between.

The tests below assume the same machine above. All start with:

.. code::

   pgbench -i -s 70 bench2

Read-Write Test

.. code::

   pgbench -c 4 -j 2 -T 600 bench2

Read-Only Test

.. code::

   pgbench -c 4 -j 2 -T 600 -S bench2

Simple Write Test

.. code::

   pgbench -c 4 -j 2 -T 600 -N bench2

Connections and Contention
~~~~~~~~~~~~~~~~~~~~~~~~~~~

For this series of tests, we want to test how PostgreSQL behaves with
different levels of connection activity. In this case, it's very
relative to how many cores you have. Again, we're assuming the same
2-core, 2GB machine.

Unfortunately, you can only do this test effectively from another
machine which has at least as many cores as the database server.

All tests start with:

.. code::

   pgbench -i -s 30 bench

Single-Threaded

.. code::

   pgbench -c 1 -T 600 bench

Normal Load

.. code::

   pgbench -c 8 -j 2 -T 600 bench

Heavy Contention

.. code::

   pgbench -c 64 -j 4 -T 600 bench

Heavy Connections without Contention

.. code::

   pgbench -c 64 -j 4 -T 600 -N bench

Heavy Re-connection (simulates no connection pooling)

.. code::

   pgbench -c 8 -j 2 -T 600 -C bench

Prepared vs. Ah-hoc Queries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pgBench 9.0 also allows you to test the effect of prepared queries on
performance. Assumes the same database server as above.

Initialize with:

.. code::

   pgbench -i -s 70 bench

Unprepared, Read-Write:

.. code::

   pgbench -c 4 -j 2 -T 600 bench

Prepared, Read-Write:

.. code::

   pgbench -c 4 -j 2 -T 600 -M prepared bench

Unprepared, Read-Only:

.. code::

   pgbench -c 4 -j 2 -T 600 -S bench

Prepared, Read-Only:

.. code::

   pgbench -c 4 -j 2 -T 600 -M prepared -S bench
