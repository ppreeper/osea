Postmark Benchmarking
======================

Instructions for running Postmark benchmark:

1) Download benchmark program:

.. code::

    wget http://www.dartmouth.edu/~davidg/postmark-1_5.c

2) Compile benchmark program:

.. code::

    cc -o postmark postmark-1_5.c

The following warning message can be ignored:

.. code::

    postmark-1_5.c: In function `cli_show`:
    postmark-1_5.c:1102: warning: pointer/integer type mismatch in conditional expression


3) Switch to a directory on the filesystem to be tested, then start the
benchmark program. For example, if the storage being tested is mounted
as /test, type:

.. code::

    cd /test
    ~/postmark

4) In response to the “pm>” prompt, enter the following commands.
“set size” determines the file size, “set number” the number of files
to create, and “set transactions” the number of transactions to perform
on those files. “run” begins the test

.. code::

    set size 1000 9000
    set number 50000
    set transactions 100000
    run

5) After the run completes, note down the number of transactions per
second it reports. For example, if the output contains the line:

.. code::

    479 seconds of transactions (125 per second)

“125” is the number to record for this run.

6) Repeat the test 3 more times using the same values for “set size”
and “set transactions”, but increasing “set number” to 100000, 250000,
and 500000

7) Open 4 terminal windows. In each window, create a separate test
directory, cd to it, and start postmark. For example:

.. code::

    mkdir /test/dir1; cd /test/dir1 ~/postmark
    ... etc ...

8) Repeat all the test runs (50000, 100000, 250000, and 500000) in all
4 windows simultaneously. Note down the *total* transactions per second
(sum of all 4 windows).

9) If the runs are taking too long to complete, reduce the
“set transactions” value. The transactions/second value should still
be valid even for a shorter test period.


Next: Compile Benchmarks, Previous: File System Scripts, Up: Scripts


4.2 Postmark

Postmark is a benchmark designed to simulate the behavior of mail
servers. Postmark consists of three phases. In the first phase a pool
of files are created. In the next phase four types of transactions
are executed: files are created, deleted, read, and appended to. In
the last phase, all files in the pool are deleted.
See http://www.netapp.com/tech_library/3022.html for more information
on Postmark.

Postmark is a single threaded benchmark, but Auto-pilot can automatically
run several concurrent processes and analyze the results. Postmark
generates a small workload by default: only 500 files are created and
500 transactions performed. Auto-pilot increases the workload to a
pool of 20,000 files, and performs 200,000 transactions by default.

Several environment variables control how Postmark behaves when running
under Auto-pilot that you can set in local.inc:

..  csv-table:: Variable Descriptions
    :widths: auto
    :header: "Variable","Default","Description"

    "BUFFERING","false","Use C library functions like fopen instead of system calls like open."
    "CREATEBIAS","5","What fraction (out of 1) of create/delete operations are create. -1 turns off creation and deletion."
    "INITFILES","20000","How many files are in the initial pool."
    "MINSIZE","512","The minimum file size."
    "MAXSIZE","10240","The maximum file size."
    "MYINITFILES","$INITFILES/$THREADS","Number of initial files in this process's pool."
    "MYSUBDIRS","$SUBDIRS/$THREADS	Number of subdirectories for this process."
    "MYTRANSACTIONS","$TRANSACTIONS/$THREADS","Number of transactions this process executes."
    "POSTMARKDIR","$TESTDIR/postmark/$APTHREAD","What directory to run in."
    "READBIAS","5","What fraction (out of 10) of read/append operations are read. -1 turns off read and append."
    "READSIZE","4096","The unit (in bytes) that read operations are executed in."
    "SEED","42","The seed for random number generation."
    "THREADS","1","How many concurrent processes to run (this variable is automatically set by the Auto-pilot THREADS directive)."
    "TRANSACTIONS","200000","How many total transactions to execute."
    "WRITESIZE","4096","The unit (in bytes) that write operations are executed in."

The Postmark script generates a configuration based on these variables,
and then decrements the semaphore specified by APIPCKEY. Decrementing this
semaphore using semdec ensures that all threats begin processing and
measuring at approximately the same time. After semdec returns, postmark
is run via ap_measure. Finally, the configuration and any left over files
are removed.
