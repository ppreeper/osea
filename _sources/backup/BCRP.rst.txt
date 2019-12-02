BCRP
====

Business continuity planning (BCP) "identifies an organization's exposure to
internal and external threats and synthesizes hard and soft assets to provide
effective prevention and recovery for the organization, while maintaining
competitive advantage and value system integrity”.[1] It is also called
business continuity and resiliency planning (BCRP). A business continuity
plan is a roadmap for continuing operations under adverse conditions (i.e.
interruption from natural or man-made hazards). BCP is an ongoing state or
methodology governing how business is conducted. In the US, governmental
entities refer to the process as continuity of operations planning (COOP).

BCP is working out how to continue operations, or the delivery of services,
during disruption or interruptions resulting from events such as; fires,
floods, power outages, theft, and vandalism, earthquakes, and pandemics.
In fact, any event that could impact operations should be considered, such
as supply chain interruption, loss of or damage to critical infrastructure
(major machinery or computing/network resource). As such, risk management
must be incorporated as part of BCP.

BCP may be a part of an organizational learning effort that helps reduce
operational risk. Backup plan to run any business event uninterrupted is a
part of business continuity plan. BCP for specified organization is to be
implemented for the organizational level in large scale however backup plan
at individual level is to be implemented at small unit scale. Organizational
management team is accountable for large scale BCP for any particular
firm while respective individual management team is accountable for their
BCP at small unit scale. This process may be integrated with improving
security and corporate reputation risk management practices.

In December 2006, the British Standards Institution (BSI) released a new
independent standard for BCP — BS 25999-1. Prior to the introduction of
BS 25999, BCP professionals relied on BSI information security standard
BS 7799, which only peripherally addressed BCP to improve an organization's
information security compliance. BS 25999's applicability extends to
organizations of all types, sizes, and missions whether governmental or
private, profit or non-profit, large or small, or industry sector.

In 2007, the BSI published the second part, BS 25999-2 "Specification for
Business Continuity Management", that specifies requirements for implementing,
operating and improving a documented business continuity management system
(BCMS).

In 2004, the United Kingdom enacted the Civil Contingencies Act 2004, a statute
that instructs all emergency services and local authorities to actively prepare
and plan for emergencies. Local authorities also have the legal obligation
under this act to actively lead promotion of business continuity practices in
their respective geographical areas.

– Identification of top risks and mitigating strategies. – Considerations for
resource reallocation e.g. skills matrix for larger organizations.

Contents  [hide]
1 Analysis
1.1 Business Impact Analysis (BIA)
1.2 Threat and Risk Analysis (TRA)
1.3 Definition of impact scenarios
1.4 Recovery requirement documentation
2 Solution design
3 Implementation
4 Testing and organizational acceptance
5 Maintenance
5.1 Information update and testing
5.2 Testing and verification of technical solutions
5.3 Testing and verification of organization recovery procedures
5.4 Treatment of test failures
6 See also
7 References
7.1 Notes
7.2 Bibliography
8 Further reading
8.1 International Organization for Standardization
8.2 British Standards Institution
8.3 Others
9 External links
9.1 Standards organizations
9.2 Competency certification ventures

Analysis
---------

The analysis phase is used in the development of a BCP manual consists of an
impact analysis, threat analysis, and impact scenarios with the resulting BCP
plan requirement documentation.

Business Impact Analysis (BIA)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Business Impact Analysis (BIA) results in the differentiation between
critical (urgent) and non-critical (non-urgent) organization
functions/activities. A function may be considered critical if the implications
for stakeholders of damage to the organization resulting are regarded as
unacceptable. Perceptions of the acceptability of disruption may be modified
by the cost of establishing and maintaining appropriate business or technical
recovery solutions. A function may also be considered critical if dictated by
law. For each critical (in scope) function, two values are then assigned:

Recovery Point Objective (RPO) – the acceptable latency of data that will not
be recovered

Recovery Time Objective (RTO)  – the acceptable amount of time to restore the
function

The recovery point objective must ensure that the maximum tolerable data loss
for each activity is not exceeded. The Recovery Time Objective must ensure that
the Maximum Tolerable Period of Disruption (MTPD) for each activity is not
exceeded.

Next, the impact analysis results in the recovery requirements for each
critical function. Recovery requirements consist of the following
information:

The business requirements for recovery of the critical function, and/or
The technical requirements for recovery of the critical function

Threat and Risk Analysis (TRA)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After defining recovery requirements, documenting potential threats is
recommended to detail a specific disaster’s unique recovery steps. Some
common threats include the following:

* Disease
* Earthquake
* Fire
* Flood
* Cyber attack
* Sabotage (insider or external threat)
* Hurricane or other major storm
* Utility outage
* Terrorism
* Theft (insider or external threat, vital information or material)
* Random failure of mission-critical systems

All threats in the examples above share a common impact: the potential of
damage to organizational infrastructure – except one (disease). The impact of
diseases can be regarded as purely human, and may be alleviated with technical
and business solutions. However, if the humans behind these recovery plans are
also affected by the disease, then the process can fall down. During the
2002–2003 SARS outbreak, some organizations grouped staff into separate teams,
and rotated the teams between the primary and secondary work sites, with a
rotation frequency equal to the incubation period of the disease. The
organizations also banned face-to-face contact between opposing team members
during business and non-business hours. With such a split, organizations
increased their resiliency against the threat of government-ordered quarantine
measures if one person in a team contracted or was exposed to the disease.
Damage from flooding also has a unique characteristic. If an office environment
is flooded with non-salinated and contamination-free water (e.g., in the event
of a pipe burst), equipment can be thoroughly dried and may still be
functional.

Definition of impact scenarios
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After defining potential threats, documenting the impact scenarios that form
the basis of the business recovery plan is recommended. In general, planning
for the most wide-reaching disaster or disturbance is preferable to planning
for a smaller scale problem, as almost all smaller scale problems are partial
elements of larger disasters. A typical impact scenario like 'building loss'
will most likely encompass all critical business functions, and the worst
potential outcome from any potential threat. A business continuity plan may
also document additional impact scenarios if an organization has more than
one building. Other more specific impact scenarios – for example a scenario
for the temporary or permanent loss of a specific floor in a building – may
also be documented. Organizations sometimes underestimate the space necessary
to make a move from one venue to another. It is imperative that organizations
consider this in the planning phase so they do not have a problem when making
the move.

Recovery requirement documentation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After the completion of the analysis phase, the business and technical plan
requirements are documented in order to commence the Solutions design phase.
A good asset management program can be of great assistance here and allow for
quick identification of available and re-allocatable resources. For an
office-based, IT intensive business, the plan requirements may cover the
following elements which may be classed as ICE (In Case of Emergency) Data:

* The numbers and types of desks, whether dedicated or shared, required outside
  of the primary business location in the secondary location
* The individuals involved in the recovery effort along with their contact and
  technical details
* The applications and application data required from the secondary location
  desks for critical business functions
* The manual workaround solutions
* The maximum outage allowed for the applications
* The peripheral requirements like printers, copier, fax machine, calculators,
  paper, pens etc.
* Other business environments, such as production, distribution, warehousing
  etc. will need to cover these elements, but are likely to have additional
  issues to manage following a disruptive event.

Solution design
----------------

The goal of the solution design phase is to identify the most cost effective
disaster recovery solution that meets two main requirements from the impact
analysis stage. For IT applications, this is commonly expressed as:

* The minimum application and application data requirements
* The time frame in which the minimum application and application data must
  be available

Disaster recovery plans may also be required outside the IT applications
domain, for example in preservation of information in hard copy format, loss
of skill staff management, or restoration of embedded technology in process
plant. This BCP phase overlaps with disaster recovery planning methodology.
The solution phase determines:

* the crisis management command structure
* the location of a secondary work site (where necessary)
* telecommunication architecture between primary and secondary work sites
* data replication methodology between primary and secondary work sites
* the application and software required at the secondary work site, and
* the type of physical data requirements at the secondary work site.

Implementation
---------------

The implementation phase, quite simply, is the execution of the design
elements identified in the solution design phase. Work package testing may
take place during the implementation of the solution, however; work package
testing does not take the place of organizational testing.

Testing and organizational acceptance
--------------------------------------

The purpose of testing is to achieve organizational acceptance that the
business continuity solution satisfies the organization's recovery
requirements. Plans may fail to meet expectations due to insufficient
or inaccurate recovery requirements, solution design flaws, or solution
implementation errors. Testing may include:

* Crisis command team call-out testing
* Technical swing test from primary to secondary work locations
* Technical swing test from secondary to primary work locations
* Application test
* Business process test

At minimum, testing is generally conducted on a biannual or annual schedule.
Problems identified in the initial testing phase may be rolled up into the
maintenance phase and retested during the next test cycle.

In the 2008 book Exercising for Excellence, published by The British Standards
Institution the authors, Crisis Solutions, identified three types of exercise
that can be employed when testing business continuity plans.

Simple exercises A simple exercise is often called a ‘desktop’, ‘workshop’, or
‘tabletop’ exercise. It typically involves a small number of people, perhaps
5–20, and concentrates on a specific aspect of a business continuity plan or a
specific subject area. (For example, Human Resources, Information Technology or
Media) However, the beauty of a Simple exercise is that it can easily
accommodate complete teams from various areas of a business. The numbers may
increase and with it the logistics but the objectives will remain the same.
Alternatively it could involve a single representative from several teams
rather than needing the whole team to attend. It will seldom involve the
provision of a Virtual World environment or the need for other than everyday
resources. Typically, participants will be given a simple scenario and then be
invited to discuss specific aspects of a company’s BCP. For example, a fire is
discovered out of working hours – what are the current call out procedures –
how is the incident management team activated – where does it meet – do the
current documented procedures cover all eventualities? It will probably last
no more than three hours and is often split into two or three sessions, each
concentrating on a different theme. In this case either two or three different
scenarios can be used or one scenario can be progressively developed to
introduce themes that need to be addressed. Real time pressure is not usually
an element of Simple exercises. Questions will need to be crafted ahead of
time so that facilitators ensure discussions are productive and germane to
the objectives of the event.

Medium exercises A medium exercise will invariably be conducted within a
Virtual World and will usually bring together several departments, teams or
disciplines. It will typically concentrate on more than one aspect of the BCP
prompting interaction between teams. The scope of a medium exercise can range
from a small number of teams from one organisation being co-located in one
building to multiple teams operating from dispersed locations. Attempts should
be made to create as realistic an environment as practicable and the numbers
of participants should reflect a realistic situation. Depending on the degree
of realism required it may be necessary to produce simulated news broadcasts,
together with simulated websites. A medium exercise will normally last between
two and three hours, though they can take place over several days. They
typically involve a Scenario Cell who feed in pre-scripted injects throughout
the exercise to give information and prompt actions.

Complex exercises A Complex exercise is perhaps the hardest to define as it
aims to have as few boundaries as possible. It will probably incorporate all
the aspects of a medium exercise and many more. Elements of the exercise will
inevitably have to remain within a virtual world, but every attempt should be
made to achieve realism. This might include a no-notice activation, actual
evacuation and actual invocation of a disaster recovery site. While a start
and cut off time will have to be agreed, the actual duration of the exercise
might be unknown if events are allowed to run their course in real time. If
it takes two hours to get to the DR site instead of the expected forty-five
minutes, the exercise must be flexible enough to cater for this. If a key
player is unavailable a deputy must be prepared to step in.

Definitions These definitions provide broad guidance as to the types of
available exercise but it should be recognised that there can be considerable
‘blurring of the edges’. It is possible to conduct a Simple exercise at a
Recovery Site thereby adding a different dimension but this would not
necessarily make it a Medium exercise. Regardless of the category, the
importance of an exercise is that it achieves its defined objectives.

Maintenance
------------

Maintenance of a BCP manual is broken down into three periodic activities. The
first activity is the confirmation of information in the manual, roll out to
ALL staff for awareness and specific training for individuals whose roles are
identified as critical in response and recovery. The second activity is the
testing and verification of technical solutions established for recovery
operations. The third activity is the testing and verification of documented
organization recovery procedures. A biannual or annual maintenance cycle is
typical.

Information update and testing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All organizations change over time, therefore a BCP manual must change to stay
relevant to the organization. Once data accuracy is verified, normally a call
tree test is conducted to evaluate the notification plan's efficiency as well
as the accuracy of the contact data. Some types of changes that should be
identified and updated in the manual include:

* Staffing changes
* Staffing personal
* Changes to important clients and their contact details
* Changes to important vendors/suppliers and their contact details
* Departmental changes like new, closed or fundamentally changed departments.
* Changes in company investment portfolio and mission statement
* Changes in upstream/downstream supplier routes

Testing and verification of technical solutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As a part of ongoing maintenance, any specialized technical deployments must
be checked for functionality. Some checks include:

* Virus definition distribution
* Application security and service patch distribution
* Hardware operability check
* Application operability check
* Data verification
* Data application

Testing and verification of organization recovery procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As work processes change over time, the previously documented organizational
recovery procedures may no longer be suitable. Some checks include:

* Are all work processes for critical functions documented?
* Have the systems used in the execution of critical functions changed?
* Are the documented work checklists meaningful and accurate for staff?

Do the documented work process recovery tasks and supporting disaster recovery
infrastructure allow staff to recover within the predetermined recovery time
objective.

Treatment of test failures
~~~~~~~~~~~~~~~~~~~~~~~~~~~

As suggested by the diagram included in this article, there is a direct
relationship between the test and maintenance phases and the impact phase.
When establishing a BCP manual and recovery infrastructure from scratch,
issues found during the testing phase often must be reintroduced to the
analysis phase.
