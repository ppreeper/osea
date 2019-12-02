= How to run a network speed test from a headless Linux server
By Jack Wallen | February 1, 2018, 9:00 AM PST 

Run a networking speed test on your headless Linux servers by installing a simple Python script and following these steps.

Every so often, administrators need to run a speed test to find out how their network is performing. Sometimes we do it just to brag about the speeds we're reaching—it's okay to admit it. Fortunately, running a speed test is quite simple: Open up a browser and point it to the likes of Speedtest by Ookla.

But what do you do if you're on a headless Linux server and you want to troubleshoot, by way of a speed test. Maybe everything is going great on your network, but something is troubling you on that particular server. Luckily, there is a way to run a speed test on that headless server, by way of a single command.

I'm going to walk you through the process of installing and using this command. I'll demonstrate on Ubuntu 16.04, but the process works on nearly all Linux distributions.

== Installation

What we're doing is downloading a Python script—which should inform you of the requirements for this tool. You must have at least Python 2.4-3.4 installed. With that said, here are the installation steps:

Open a terminal window

. Download the necessary file with the command `wget link:https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py[https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py]`
. Give the newly downloaded file the necessary permissions with the command `chmod u+x speedtest.py`
. Move the file with the command `sudo mv speedtest.py /usr/local/bin`
. That's all there is to the installation. We are now ready to run our test.

== Running the test

Go back to your terminal window and issue the command sudo speedtest.py. The command will locate the nearest testing server and have at it. When the command completes, you'll have your results (*Figure A*).

Figure A

image:https://tr3.cbsistatic.com/hub/i/2018/02/01/c969f6b9-84ae-45f0-a19e-5a45442903c2/e3e727bbe5d28bd26ce3465b9372dce5/speedtesta.jpg[The results of my speed test from a headless Ubuntu 16.04 server.]

If you're into it, you can tell the test to generate a .png image so you can share it with your colleagues, or use it for documentation purposes. To do that, issue the command sudo speedtest.py —share. When the command completes, it will produce a link you can copy and paste into a browser. That link will display the image created by your test. You can then save the image and use it later.

== Troubleshooting or bragging

Whether you need to troubleshoot a networking issue, or brag to your fellow IT pros, running a network speed test is a great place to start. If you make use of headless Linux servers, those machines don't have to be left out of the fun.
