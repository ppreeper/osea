= Five+ tips to ensure PCI DSS compliance

* Date: December 6th, 2010
* Author: Michael Kassner
* Category: Five Tips, IT security
* Tags: Consultant, Network, Compliance, PCI DSS, PCI Security Standards Council, Cardholder Data, PCI, Storage, Hardware, Jody Gilbert

On occasion, I help a friend who owns several businesses. His latest venture is required to comply with the Payment Card Industry Data Security Standard (PCI DSS). My friend is computer savvy. So between the two of us, I assumed the network was up to snuff. Then went through a compliance audit.

The audit was eye opening. We embarked on a crash course in PCI DSS compliance with the help of a consultant. My friend thought the consultant could help prepare for the mandatory adoption of PCI DSS 2.0 by January 1, 2011.

The PCI Security Standards Council defines PCI DSS this way:

“The goal of the PCI Data Security Standard is to protect cardholder data that is processed, stored, or transmitted by merchants. The security controls and processes required by PCI DSS are vital for protecting cardholder account data, including the PAN — the primary account number printed on the front of a payment card.”

The consultant’s first step was to get familiar with the network. He eventually proclaimed it to be in decent shape, security-wise. Yet the look on his face told us there was more. Sure enough, he went on to explain that more attention must be paid to protecting cardholder data.

== Back to school

The consultant pointed out that PCI DSS consists of 12 requirements. These requirements are organized into six guides. Although the requirements are for PCI DSS compliance, I dare say the guides are a good primer for any business network, regardless of whether PCI DSS is a factor. With that in mind, I’ve used the guides as the basis for these tips.

== 1: Build and maintain a secure network

Guide 1 states the obvious, and books have been written on how to secure a network. Thankfully, our consultant gave us some focus by mentioning that PCI DSS places a great deal of emphasis on the following:

Well-maintained firewalls are required, specifically to protect cardholder data. Any and all default security settings must be changed, specially usernames and passwords.

Our consultant then asked whether my friend had offsite workers who connected to the business’s network. I immediately knew where he was going. PCI DSS applies to them as well — something we had not considered but needed to.

== 2: Protect cardholder data

Cardholder data refers to any information that is available on the payment card. PCI DSS recommends that no data be stored unless absolutely necessary. The slide in Figure A (courtesy of PCI Security Standards Council) provides guidelines for cardholder-data retention.

Figure A

One thing the consultant stressed: After a business transaction has been completed, any data gleaned from the magnetic strip must be deleted.

PCI DSS also stresses that cardholder data sent over open or public networks needs to be encrypted. The minimum required encryption is SSL/TLS or IPSEC. Something else to remember: WEP has been disallowed since July 2010. I mention this as some hardware, like legacy PoS scanners, can use only WEP. If that is your situation, move the scanners to a network segment that is not carrying sensitive traffic.

== 3: Maintain a vulnerability management program

It’s not obvious, but this PCI DSS guide subtly suggests that all computers have antivirus software and a traceable update procedure. The consultant advised making sure the antivirus application has audit logging and that it is turned on.

PCI DSS mandates that all system components and software have the latest vendor patches installed within 30 days of their release. It also requires the company to have a service or software application that will alert the appropriate people when new security vulnerabilities are found.

== 4: Implement strong access control measures

PCI DSS breaks access control into three distinct criteria: digital access, physical access, and identification of each user:

* **Digital access**: Only employees whose work requires it are allowed access to systems containing cardholder data.
* **Physical access**: Procedures should be developed to prevent any possibility of unauthorized people obtaining cardholder data.
* **Unique ID**: All users will be required to have an identifiable user name. Strong password practices should be used, preferably two-factor.

== 5: Regularly monitor and test networks

The guide requires logging all events related to cardholder data. This is where unique ID comes into play. The log entry should consist of the following:

* User ID
* Type of event, date, and time
* Computer and identity of the accessed data

The consultant passed along some advice about the second requirement. When it comes to checking the network for vulnerabilities, perform pen tests and scan the network for rogue devices, such as unauthorized Wi-Fi equipment. It is well worth the money to have an independent source do the work. Doing so removes any bias from company personnel.

== 6: Maintain an information security policy

The auditor stressed that this guide is essential. With a policy in place, all employees know what’s expected of them when it comes to protecting cardholder data. The consultant agreed with the auditor and added the following specifics:

Create an incident response plan, since figuring out what to do after the fact is wrong in so many ways.

If cardholder data is shared with contractors and other businesses, require third parties to agree to the information security policy.

Make sure the policy reflects how to take care of end-of-life equipment, specifically hard drives.

== Final thoughts

There is a wealth of information on the PCI Security Standards Council’s Web site. But if you are new to PCI DSS, or the least bit concerned about upgrading to 2.0, I would recommend working with a consultant.