= How to install the GNS3 network emulator on Ubuntu 
> Need a network emulator that won't break your budget? Install the free, open source GNS3 network emulator on Ubuntu Linux. 

> By Jack Wallen | April 6, 2018, 4:00 AM PST

{{https://tr2.cbsistatic.com/hub/i/r/2018/04/05/0006ed50-0fcb-4522-a256-fe19e903c839/resize/770x/0afe81291cabbae95383cfdbdf2315d8/gns3hero.jpg}}

If you're a network administrator, you know how valuable good tools are. Most everyone knows about tools like traceroute, ping, Wireshark, iPerf, and Nmap—tools that help you sniff out issues on your currently running network. But what about when you are in the design phase of your network? Do you rely on either paper or static network diagramming tools? What happens when you're looking at designing a much more complicated network? Even more important, what about when you need to simulate a specific network, in order to train for an exam? At that point, you cannot rely on paper and pencil or static diagrams. You need real tools to work with. But having access to Cisco routers and the like can be cost prohibitive. And since your company isn't going to allow you to practice your examins on their production network, where do you turn?

You turn to tools like the [[https://gns3.com/|Graphical Network Simulator 3]] (GNS3). This is a free, open source network simulator that can be installed on Windows 7 (64 bit) and later, macOS Mavericks (10.9) and later, and any Linux distribution (Debian/Ubuntu are provided and supported).

I'm going to show you how to install GNS3 on Ubuntu Linux demonstrating on a daily build of 18.04. The installation isn't difficult, but do know that it will install a good deal of dependencies on your system. Your best bet is to install it on its own hardware or spin up a virtual machine, running Ubuntu Linux or a Ubuntu derivative, such as [[https://linuxmint.com/|Linux Mint]], and install from that. Otherwise, you'll be installing all of those dependencies on a production machine. Do note, if you install GNS3 as a virtual machine, you might lose support for those appliance templates that require KVM support.

With that said, let's install.

== Installation 

Open up a terminal window. The first thing you must do is add the necessary repository. From the bash prompt, issue the following command:

<code bash>
sudo add-apt-repository ppa:gns3/ppa
</code>

Once that command completes, update apt with the command:

<code bash>
sudo apt-get update
</code>

Finally, install GNS3 with the command:

<code bash>
sudo apt-get install gns3-gui
</code>

During the installation, you will be greeted by two screens. The first of which asks if you want allow all non-superusers to run GNS3 (**Figure A**). Accept the default (Yes) for this.

=== Figure A 

{{https://tr3.cbsistatic.com/hub/i/2018/04/05/836aad51-862b-4da6-b25e-a34c189843e7/65f996e88b3f1c09a4237ad67ea55ec4/gns3a.jpg|Allowing non-root users to run GNS3.}}

The next screen you will be presented asks if non-superusers should be allowed to capture packets. Since this could be a security risk, accept the default (No).

With those two questions out of the way, the installation will continue and complete.

== Usage 

When the installation finishes, you should find an entry for GNS3 in your desktop menu. Click to run the application. Once it opens, you'll be asked to choose a server to run the simulations (**Figure B**).

=== Figure B 

{{https://tr4.cbsistatic.com/hub/i/2018/04/05/a5933f2e-6c32-4bae-a7da-ef75b9bbe546/134ba599c28aab65c9ebd93deedb9c95/gns3b.jpg|Selecting your GNS3 server.}}

Most likely, you'll want to select Run the topologies on my computer. The next screen (**Figure C**) allows you to configure the necessary options for your GNS3 server.

=== Figure C 

{{https://tr2.cbsistatic.com/hub/i/2018/04/05/b62e82e9-a37d-4a09-a4d1-c50182a65c12/910572d872423dbff362b8bfbe3c1df6/gns3c.jpg|Setting the GNS3 server options.}}

Once you click Next on the above screen, GNS3 will start and present you with a screen informing you of the successful startup. Click Next to see the details of your server (**Figure D**).

=== Figure D 

{{https://tr4.cbsistatic.com/hub/i/2018/04/05/f39836dc-bf7f-43e3-ae94-be27c059f49b/8d45a64cbb66cac1b214e5c2913aaa5a/gns3d.jpg|The details for your GNS3 server.}}

Click Finish to dismiss the details window. You will then be presented with a window asking you which networking template to import (**Figure E**).

=== Figure E 

{{https://tr4.cbsistatic.com/hub/i/2018/04/05/bb2f8e0a-ca3b-4c1e-88c2-b68ac9d5fcc9/db2f0b3eb0a71aee4d1920619627816c/gns3e.jpg|Selecting your template.}}

If the template you need isn't included in the default list, go to [[https://gns3.com/marketplace/appliances|GNS3 Appliance page]], locate the template you want to import, download the template, and click the Import an appliance template file. The files will end in the .gns3a extension. You will be asked to choose a server type. What options are available will depend upon where you're hosting your GNS3 server. If you're hosting it locally, the only option will be to run the appliance on the local computer. Upon successful import, you'll be greeted with a window displaying the details for the template (**Figure F**).

=== Figure F 

{{https://tr3.cbsistatic.com/hub/i/2018/04/05/e94c047a-fb16-4ef0-b10d-618e1460de1b/512371aec4be5f02452499f603b00b3a/gns3f.jpg|Importing a FortiGate appliance into GNS3.}}

Chances are, during the import, you'll be required to download a necessary image for the successful running of the appliance. You'll have to select the version of the appliance you want to import and then, when prompted, click the Download button. Once the image comes up listed as Found (instead of Missing), you can then click the Next button.

Do note: Some images have an associated price. Some are free, but may download as a compressed file. You will have to extract the compressed file, before attempting to import it.

Once the template has been imported, you can begin using GNS3. Each appliance will be listed in the Installed appliances drop-down (**Figure G**). After you've located your appliance, drag it into the center pane to start working.

=== Figure G 

{{https://tr4.cbsistatic.com/hub/i/2018/04/05/52fa36c4-c9a0-41da-a7e5-792b3942ca0f/c222f269c5109c4cf7604f1eda0d8731/gns3g-800x600.jpg|Dragging an installed appliance into the workspace to start using it.}}

== The tip of the iceberg 

This is just the start of using GNS3, the veritable tip of a rather large iceberg. Once you have it up and running and have imported the necessary templates, you can begin working with the appliances as if they are right there. This is an incredibly powerful tool that can make a huge difference in your ability to practice and get familiar with various types of networking hardware.