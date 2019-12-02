= How to add a repository on your Linux machine
By Jack Wallen | January 31, 2018, 5:00 AM PST 

If you've ever been told to add a repository to a Linux machine and had no idea what that meant, you're in luck. Jack Wallen explains this necessary Linux tool.

At some point, in your Linux experience, you're going to come across the term Repository. The official definition of the word is simple: a place, building, or receptacle where things are or may be stored. But when applied to Linux, the word holds a bit more meaning. If you've read any number of TechRepublic articles about Linux, you've probably seen the phrase "standard repository." What is all of this? Let me explain.

For Linux, a repository is a collection of software for a particular distribution that is hosted on a remote server. The Standard Repository is one that is already configured on your machine. All software found on the Standard Repository can be installed out of the box. Of course, the internet is full of repositories that are not part of the Standard Repository. If your Linux machine is made aware of these non-standard repositories, you can easily install any applications found on those hosts. If your machine isn't made aware of a particular remote repository, you cannot install the software found within. In order to be able to install the software contained within a repository, the repository must be added to your machine. How this is done, depends upon the distribution. For example, with a Ubuntu-based distribution, the addition of a repository is as simple as running the `command sudo apt-add-repository`. Let me demonstrate by adding the necessary repository for installing the Simple Screen Recorder tool.

Open up your terminal window and type `sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder`. Type your sudo password. When prompted, hit Enter on your keyboard to accept the addition of the repository. Once the repository is added, update the apt sources with the command sudo apt update. When that completes, you can then install the Simple Screen Recorder app with the command `sudo apt install simplescreenrecorder`.

Without adding that repository to your machine, you wouldn't be able to install the Simple Screen Recorder software, at least not by way of the built-in package manager.

Repositories make installing software on Linux significantly easier. Now, when instructed to add a repository on your Linux machine, you'll know exactly what that means.
