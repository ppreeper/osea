#How to install Hyperledger Fabric on Ubuntu

This how-to walks you through the process of installing the blockchain framework, Hyperledger Fabric, on Ubuntu 16.04.

By Jack Wallen | May 8, 2018, 7:49 AM PST

Hyperledger Fabric is a blockchain framework implementation that you can use as a foundation for developing applications or solutions with a modular architecture. It's quite a challenge to install, but once you have it up and running (and have started developing applications that make use of the blockchain framework) it will be well worth your time. The good news is that it's all open source and runs on open source platforms, so there is no software cost investment. There is of course a time investment. But this will be time worth spent.

I want to walk you through the process of installing Hyperledger Fabric v 1.0 on Ubuntu Server 16.04. This is handled completely through the command line. I will assume you already have your Ubuntu Server 16.04 up and running. You will also need an account with sudo rights.

With that said, let's install.

##Installing the Go language

Hyperledger Fabric depends upon the Go language. The minimum required version is 1.7. Although version 1.10.2 is available, it will not compile and install with this method, so we'll be going with 1.7. Here are the necessary steps:

 - Change into your home directory with the command cd ~/
 - Download the tar file with the command wget https://storage.googleapis.com/golang/go1.7.1.lin...
 - Unpack the file with the command tar xvzf go1*.tar.gz
 
Now we need to set GOPATH and GOROOT with the following commands:

<code bash>
mkdir $HOME/gopath
export GOPATH=$HOME/gopath
export GOROOT=$HOME/go
export PATH=$PATH:$GOROOT/bin
</code>

Check to make sure golang is working by issuing the command go version. You should see the version of go you just installed (in our case, 1.10.2).

##Install dependencies

Next we have a few dependencies to install. The first is libltdl-dev. This can be done with the single command:

<code bash>
sudo apt install libltdl-dev
</code>

Docker is our next dependencies. We'll install Docker from a downloadable .deb file, with the commands:

<code bash>
wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_18.03.1~ce-0~ubuntu_amd64.deb 
sudo dpkg -i docker*.deb
sudo apt install -f
</code>

Add our user to the docker group with the command:

<code bash>
sudo usermod -aG docker USERNAME
</code>

Where USERNAME is the actual name of the user.

Log out and log back in. Verify that Docker is working with the command:

<code bash>
docker run hello-world
</code>

If you see "Hello from Docker!" you're good to continue on.

Next we must install Pip. Do this with the following command:

<code bash>
sudo apt install python-pip
</code>

Verify pip has been installed with the command pip —version.

Now we need to add Docker Compose. We will install this, by way of Pip, with the command:

<code bash>
sudo pip install docker-compose
</code>

Verify Docker Compose was installed with the command docker-compose —version.

Now we install git and curl with the command:

<code bash>
sudo apt install git curl
</code>

##Installing Hyperledger Fabric

Now we install Hyperledger Fabric. Create a new directory with the command:

<code bash>
mkdir -p $GOPATH/src/github.com/hyperledger/
</code>

Change into that newly created directory with the command:

<code bash>
cd $GOPATH/src/github.com/hyperledger/
</code>

Download fabric with the command:

<code bash>
git clone https://github.com/hyperledger/fabric.git
</code>

Change into the fabric directory with the command cd fabric and reset the fabric commit level with the command:

<code bash>
git reset --hard c257bb31867b14029c3a6afe1db35b131757d2bf
</code>

Make and install fabric with the command make. This will take some time to complete. When the installation completes, issue the following commands (so our test network will succeed):

<code bash>
git checkout fa3d88cde177750804c7175ae000e0923199735c
sh examples/e2e_cli/download-dockerimages.sh
</code>

You can now run a fabric example by changing into the examples directory with the command cd examples/e2e_cli/ and then first issuing the command to create a test channel:

<code bash>
./generateArtifacts.sh TESTCHANNEL
</code>

Where TESTCHANNEL is the name of a channel (such as testchannel). Next, issue the command:

<code bash>
./network_setup.sh up TESTCHANNEL 10000 couchdb
</code>

Where TESTCHANNEL is the name of your test channel. Near the end of the above command, you should see END-E2E drawn out in ascii (**Figure A**).

###Figure A

{{https://tr1.cbsistatic.com/hub/i/2018/05/08/7d26a1a1-7193-446c-b65f-35008b85cf72/fd71baeb1e9b0b97eeabbe1649a21d28/hyperledgera.jpg|A successful run of an included example}}

You might wind up with errors regarding docker images hyperledger/fabric-tools. To fix this, you must pull down the latest images from Docker Hub and then retag them. This done with the following commands:

<code bash>
docker pull hyperledger/fabric-tools:x86_64-1.1.0
docker tag hyperledger/fabric-tools:x86_64-1.1.0 hyperledger/fabric-tools:latest
</code>

Once you've issued the above commands, rerun the ./network_setup.sh up command.

##Hyperledger Fabric is up and running

Congratulations! You now have Hyperledger Fabric up and running. You can now begin the process of developing for this blockchain framework.