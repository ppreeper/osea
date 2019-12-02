10 elements every production environment must have
==================================================

By Scott Matteson | June 16, 2017, 8:18 AM PST

One company recently experienced disaster when an employee accidentally
destroyed a production database. Here are 10 ways to prevent future scenarios
like that.

A recent story regarding a programmer who was fired the first day on the
job for accidentally destroying a production database was the stuff of
nightmares for technologists.

The sad tale, posted on Reddit by the unfortunate ex-employee, details some
disturbing elements such as the new hire being given administrative access
in production, orientation documents containing inaccurate information which
produced the mistake and — worst of all —the fact no backups of the database
existed, which heightened the impact of the crisis.

Any company or IT professional can learn a lot from this debacle since it
speaks to best practices for production environments. With that in mind,
here are 10 elements every production environment should have to ensure
maximum uptime, stability — and job security for those who maintain it.

1. Redundancy
-------------

Redundancy is probably one of the most important ingredients of a successful
production environment. If a system or service is critical to the organization,
either by producing revenue or preventing the loss of revenue, there should
never be a single instance of it. Use application as well as system redundancy
to ensure you can withstand the loss of an entire server. Power and network
connections should also be redundant. Some organizations even have entire
site redundancies so they can run their operations in an entirely different
location.

Cost is often cited as a factor against implementing robust redundancy,
but keep in mind that investing in redundancy, while potentially painful
at the onset, can reap hefty dividends down the road — even if only for
the peace of mind it provides.

2. Disaster recovery capability
-------------------------------

A "disaster" can have an ambiguous meaning. It refers to any unexpected
misfortune or failure ranging from a crashed application to the loss of
an entire site due to a power outage. Plan for disasters which will
impact your ability to run a production environment and ensure you have
appropriate solutions in place. Some examples:

* Perform nightly backups of all systems and confirm restore functionality
* Ship backup tapes/hard drives off-site (or copy data to the cloud so
  it will be accessible remotely)
* Take snapshots of SAN volumes and virtual machines to be able to roll
  back to a known good state
* Keep spare hard drives, network cards and servers on hand for emergency
  situations
* Install a generator to guard against power outages

3. Secure access
----------------

The incident involving the developer deleting a production database would
never have happened had the company followed one simple guideline: only
provide production access to individuals who actually need it, and configure
permissions to match their job role. Store any system or service account
passwords in a secured, centralized password database.

Unless someone is going to directly work in production from day one, don't
give them the key to do so. If they do need the access, determine whether
"read" permissions are sufficient so they can't actually change the data.

If employees with production access leave the company, make sure to disable
or lock their accounts. If administrators with production access depart,
change all the passwords involved such as root or administrator passwords.

4. Standardized access
----------------------

There are a variety of methods to access production data; via a web
browser, SSH connectivity, remote desktop, a Squirrel database client,
secure FTP or various other methods. Ensure users have a standard method
for production access involving the same client or portal.

A "jump box" or bastion host for them to connect to and then access
production also makes sense. For example, a Windows server users can log
into via remote desktop can then be set up with standard applications
such as Putty, Squirrel, or Firefox for consistency and the ability to
easily support their needs. This also helps better secure the production
environment.

5. Minimalism
-------------
Your production systems should contain only necessary services/applications.
This means there will be less to troubleshoot and patch, and the simplicity
will ensure a more predictable and manageable environment. This strategy
will also reduce a potential attack footprint.

A web server should only run IIS or Apache/Tomcat. An FTP server should only
run the secure FTP service. A file server should only host data. And so
forth. If applications or services are no longer in use, remove them.

6. A patching strategy
----------------------

Speaking of patching, it's a necessary evil. Develop a patching mechanism
to ensure production systems are updated on at least a monthly basis.

Rebooting production systems is never anyone's idea of a fun time, but
suffering a data breach makes it look like a picnic by comparison. Besides,
if you're using redundancy, you should be able to patch and reboot a pair
of clustered systems, for instance, with zero user impact. However, make
sure to let at least a day or two pass before patching all redundant systems,
just in case the patch produces an adverse impact which might obviate the
protection you've implemented via redundancy.

7. Segregated networks
----------------------

Your production systems should never be on the same network as your other
servers, let alone your client workstations. Put them on their own dedicated
subnet and maintain access through a firewall which permits only the desired
systems to connect via only the necessary ports. This will help ensure
security as well as help achieve the minimalism I mentioned above.

It can be tedious trying to determine which ports need to be opened in the
firewall, but consider it an investment in learning more about how your
production environment works - which will pay dividends when it comes to
troubleshooting and supporting it.

8. Change management
--------------------

Change management is the process of documenting proposed changes and their
expected impact then submitting a request for review and approval of said
change. Ideally, the request should list the affected systems, the plan for
change, methods to validate the changes (both from a system administrator
and end user standpoint, and a backout plan.

Other technical individuals should inspect the process for potential pitfalls
(known as a peer review), and the request must then be approved by a manager
before the change can be implemented.

Most large companies, especially financial institutions, follow stringent
change management guidelines, and smaller companies would benefit from it
as well. It can be onerous and provoke impatience or reluctance among busy
IT professionals, but it serves to ensure the least possible negative impact
upon production environments. It can also preserve one's job if a change
leads to an unexpected outage, since it was known about and approved in
advance, and not a rogue act by a careless administrator.

9. Auditing, logging, and alerting
----------------------------------

Many of the above steps become less effective or meaningless if you're not
using auditing, logging and alerting. Every action taken on a production
system should be recorded and, depending on the severity, should trigger
an alert if appropriate. For instance, logging in as root should send a
notification to IT staff and/or the security group so they can assess
what's happening and whether an illegal act is occurring.

The same applies to hardware which might be faulty. There's a saying that
"your users should be the last ones to know when production is down."
Hard drives which are filling up should page responsible staff. The same
applies for excessive bandwidth usage, low available memory, intermittent
connectivity problems or other operational issues.

10. Appropriate documentation
-----------------------------

A Chinese proverb states: "The palest ink is better than the best memory."
Knowledge is a powerful thing, but the ability to properly share it with
others is even more powerful. Staff turnover is a fact of life, and
employees who depart with critical information about the production
environment stored only in their brains represent a significant company
loss.

Documentation of the production environment should be comprehensive and
kept up-to-date. It should include hardware, software, networking details,
vendor information, support information, dependencies upon other systems
or applications, and any other details necessary to maintain order.
Conduct quarterly reviews and ensure all staff responsible for the
production environment are familiar with the documentation — and that
it is safely backed up in the event of a disaster.
