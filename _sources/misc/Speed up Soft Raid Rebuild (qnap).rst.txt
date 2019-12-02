= Speed up Soft Raid Rebuild (qnap)

== Get current speeds

[source,bash]
----
cat /proc/sys/dev/raid/speed_limit_min ;
cat /proc/sys/dev/raid/speed_limit_max ;
----

== Set current speeds

[source,bash]
----
echo 100000 >/proc/sys/dev/raid/speed_limit_min
echo 500000 >/proc/sys/dev/raid/speed_limit_max
----
