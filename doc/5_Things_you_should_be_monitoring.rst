5 things you should be monitoring
=================================

https://www.oreilly.com/ideas/5-things-you-should-be-monitoring

By Brian Brazil August 6, 2018

Achieve high-impact systems monitoring by focusing on latency, errors,
throughput, utilization, and blackbox monitoring.

So you've deployed your brand new web application (now with blockchain!),
and your users love it. Traffic is increasing, and you're getting great
press. Then one morning you wake up to find that the site has been slow
all night, and your users are complaining. How do you find the problem?

Whether you're a developer building websites or internal applications,
or an administrator building the infrastructure to back them, your job
doesn't stop once they're up and running. Machine failure, releases
containing bugs, and growth in usage can all lead to problems that need
to be dealt with. To detect them, you need monitoring.

But monitoring can do more than just send you alerts about the things
that are going wrong. It can also help you debug those problems and
prevent them in the future. So what things should you be monitoring?

1. Latency
----------

Faster web pages lead to happier users. The opposite is also true:
increased latency leads to user dissatisfaction and could also be the
first warning sign that your system is strained. Launching resource-intensive
features often means more user requests being served. As servers die,
latency can increase. In fact, latency tends to increase nonlinearly in
response to load due to increased contention. Small latency increases today
could indicate bigger latency increases in the future; early awareness gives
you some time to fix any issues.

Latency is generally measured from two perspectives: your users and your
system. Having instrumentation inside the user's browser can detect issues
such as JavaScript and static assets getter larger slowing the user
experience. This measurement will have a lot of variance due to users'
specific hardware, their network environment, and their internet connection.
Measuring from each of your own backend systems tends to be much less noisy
but can never capture the entire user experience, so it's best to measure
both. Browser latency monitoring will catch frontend issues due to a
release, and backend monitoring will catch most of the rest.

But what do you do with your latency data once you've gathered it? You
could alert every time latency increases by a millisecond, but that's not
really a good reason to drag yourself out of bed at 3:00am. A better option
is to set alert thresholds based on service-level agreements (SLA). If
you don’t have SLAs, choose a threshold that indicates when things are
significantly abnormal. For example, if your latency usually varies
between 50ms and 100ms, 200ms might be a good threshold to start with.

Beyond alerts that require immediate human attention, it is also wise
to review key metrics, such as latency, every week, month, or quarter
depending on your development velocity and how dynamic your system is.
Using a review process to notice trends in advance is better than
burning engineers out with hair-trigger alerts.

2. Errors
---------

While latency can make a system feel sluggish for your users, errors
tend to cause more obvious problems. Error sources may include a bug in
your system, a bad interaction with a new browser release, or a timeout
due to increased load. These can lead to malfunctions or outright failure.

Ordinarily, you want to know about errors at every level of your stack,
from the frontend all the way down to the backend data stores. But that
doesn't mean you need an alert on every single error counter. For
example, if database errors always cause application errors, an alert
on application errors will suffice, because it will cover the database
errors and more. However, you should still show both database and
application errors on your dashboards to help you determine whether
the application errors are due to the database. Conversely, if you have
an optional backend whose errors don't cause upstream systems to hard
fail, it makes sense to alert on the errors of the optional backend,
since the application error alert won't catch them.

When creating dashboards and alerts related to errors, it's best to use
the ratio of number of errors to total requests rather than just the
number of errors. For example, one error per second might be typical
during peak traffic but could be a bad sign during times of lower load.
Knowing that the error ratio is 5% is more useful for comparison and
doesn't require updating the alert threshold as your traffic grows.

Finally, remember that not all errors are equal. Say you have a system
that accepts user uploads, processes them, and then serves them over
HTTP. If the storage backend times out, your system is clearly at fault.
But if a user makes a malformed request, you may choose to ignore the
error unless you see enough malformed requests to prompt you to investigate
a broken frontend. Similarly, you may choose to ignore requests made for
things that don't exist because they could be caused by a number of things,
from user error to lost uploads or uploads that haven't completed processing.
However, as with malformed requests, a high level of these errors is likely
worth alerting on.

3. Throughput
-------------

In order to learn your error ratio, you need to know the number of requests
that you are serving (i.e., throughput). When debugging a performance issue,
knowing your throughput can reveal whether traffic increased around the same
time, which can indicate a capacity problem.

Beyond immediate debugging, monitoring throughput helps you understand how
your traffic has been growing over the past few months or years. This is
important for capacity planning, helping predict what traffic is likely to
be in the future. You don't want to leave yourself short in terms of
resources and finances, but neither do you want to overspend.

There's more to consider than raw request count. It's useful to track what
the requests are for and whether they are cheap or expensive requests to
serve. Expense might be quantified in terms of CPU or even network
bandwidth. You may also want to know where your users are geographically
so that you can plan your data center locations accordingly.

4. Utilization
--------------

Capacity planning should ensure that you have enough resources, but that
isn't always the case. Growth may exceed expectations, feature launches
may entail unforeseen expenses, and you may experience traffic spikes or
a sudden loss of machines. That's where utilization comes in. Utilization
is a measure of how close your service is to maximum capacity. This is
usually determined by CPU, but some systems may be constrained by other
resources, such as network bandwidth, storage space, or RAM.

Determining how utilization of your existing machines correlates with
traffic enables you to use your traffic growth projections to predict
your hardware/resource needs. For example, if serving 100 requests per
second takes one CPU, and you need to serve 200 requests per second in
the future, you know you'll need at least two CPUs to make that happen.
Be aware that as traffic increases, your resource needs will increase
faster than linear, as explained by models such as the Universal
Scalability Law.

5. Blackbox monitoring
----------------------

Is this thing turned on? Monitoring whether your service is working as
seen from the outside is known as blackbox monitoring. Everything might
ook fine at your backend servers from inside your network, but a broken
load balancer or misconfigured internet routing could stop users from
getting that far. Thus, it's wise to have some basic monitoring from
outside your network confirming that traffic can get in. It's also useful
to look for sudden dips in traffic to detect issues with users getting
to your services, although this tends to be difficult to tune for a good
signal-to-noise ratio.

You should also check whether key features, such as user login, are
working. I recommend treating these as smoke tests rather than regression
tests. The main purpose of blackbox monitoring is to tell you if your
system is severely broken. But blackbox monitoring has a tendency to be
flaky, particularly when using heavy, complex tests, and flaky monitoring
will burn out the engineer on the receiving end of any alerts. More subtle
failures, like users being unable to log in if their password is longer
than 32 characters, are best caught in other ways, such as the above
metrics, error logs, and user bug reports.

Use monitoring to cover your bases
----------------------------------

With a combination of latency, errors, throughput, utilization, and blackbox
monitoring, all of your main needs should be covered. Monitoring these
five areas will not catch every possible problem (although you shouldn't
try to catch every problem, as you'll quickly hit diminishing returns).
However, it will offer enough information to give you confidence that
your systems are running smoothly.
