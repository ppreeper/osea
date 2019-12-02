restic
======

:toc:
:icons: font

<<<<
== Introduction

restic is a program that does backups right. The design goals are:

* Easy: Doing backups should be a frictionless process, otherwise you are tempted to skip it. Restic should be easy to configure and use, so that in the unlikely event of a data loss you can just restore it. Likewise, restoring data should not be complicated.

* Fast: Backing up your data with restic should only be limited by your network or hard disk bandwidth so that you can backup your files every day. Nobody does backups if it takes too much time. Restoring backups should only transfer data that is needed for the files that are to be restored, so that this process is also fast.

* Verifiable: Much more important than backup is restore, so restic enables you to easily verify that all data can be restored.

* Secure: Restic uses cryptography to guarantee confidentiality and integrity of your data. The location where the backup data is stored is assumed to be an untrusted environment (e.g. a shared space where others like system administrators are able to access your backups). Restic is built to secure your data against such attackers, by encrypting it with AES-256 in counter mode and authenticating it using Poly1305-AES.

* Efficient: With the growth of data, additional snapshots should only take the storage of the actual increment. Even more, duplicate data should be de-duplicated before it is actually written to the storage backend to save precious backup space.

* Free: restic is free software and licensed under the BSD 2-Clause License and actively developed on GitHub.

== Installation

=== Packages

Note that if at any point the package you’re trying to use is outdated, you always have the option to use an official binary from the restic project.

These are up to date binaries, built in a reproducible and verifiable way, that you can download and run without having to do additional installation work.

Please see the Official Binaries section below for various downloads. Official binaries can be updated in place by using the `restic self-update` command.

==== Arch Linux

On Arch Linux, there is a package called restic installed from the official community repos, e.g. with pacman -S:

----
$ pacman -S restic
----

==== Debian

On Debian, there’s a package called restic which can be installed from the official repos, e.g. with apt-get:

----
$ apt-get install restic
----

[WARNING]
====
Please be aware that, at the time of writing, Debian _stable_ has `restic` version 0.3.3 which is very old. The testing and unstable branches have recent versions of `restic`.
====

==== Fedora

restic can be installed using dnf:

----
$ dnf install restic
----

If you used restic from copr previously, remove the copr repo as follows to avoid any conflicts:

----
$ dnf copr remove copart/restic
----

==== macOS

If you are using macOS, you can install restic using the homebrew package manager:

----
$ brew install restic
----

You may also install it using MacPorts:

----
$ sudo port install restic
----

==== Nix & NixOS

If you are using Nix or NixOS there is a package available named restic. It can be installed using nix-env:

----
$ nix-env --install restic
----

==== OpenBSD

On OpenBSD 6.3 and greater, you can install restic using pkg_add:

----
# pkg_add restic
----

==== FreeBSD

On FreeBSD (11 and probably later versions), you can install restic using pkg install:

----
# pkg install restic
----

==== RHEL & CentOS

restic can be installed via copr repository, for RHEL7/CentOS you can try the following:

----
$ yum install yum-plugin-copr
$ yum copr enable copart/restic
$ yum install restic
----

If that doesn’t work, you can try adding the repository directly, for CentOS6 use:

----
$ yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/copart/restic/repo/epel-6/copart-restic-epel-6.repo
----

For CentOS7 use:

----
$ yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/copart/restic/repo/epel-7/copart-restic-epel-7.repo
----

==== Solus

restic can be installed from the official repo of Solus via the eopkg package manager:

----
$ eopkg install restic
----

==== Windows

restic can be installed using Scoop:

----
scoop install restic
----

Using this installation method, `restic.exe` will automatically be available in the `PATH`. It can be called from cmd.exe or PowerShell by typing `restic`.

=== Official Binaries

==== Stable Releases

You can download the latest stable release versions of restic from the restic release page. These builds are considered stable and releases are made regularly in a controlled manner.

There’s both pre-compiled binaries for different platforms as well as the source code available for download. Just download and run the one matching your system.

The official binaries can be updated in place using the `restic self-update` command (needs restic 0.9.3 or later):

----
$ restic version
restic 0.9.3 compiled with go1.11.2 on linux/amd64

$ restic self-update
find latest release of restic at GitHub
latest version is 0.9.4
download file SHA256SUMS
download SHA256SUMS
download file SHA256SUMS
download SHA256SUMS.asc
GPG signature verification succeeded
download restic_0.9.4_linux_amd64.bz2
downloaded restic_0.9.4_linux_amd64.bz2
saved 12115904 bytes in ./restic
successfully updated restic to version 0.9.4

$ restic version
restic 0.9.4 compiled with go1.12.1 on linux/amd64
----

The `self-update` command uses the GPG signature on the files uploaded to GitHub to verify their authenticity. No external programs are necessary.

[NOTE]
====
Please be aware that the user executing the `restic self-update` command must have the permission to replace the restic binary. If you want to save the downloaded restic binary into a different file, pass the file name via the option `--output`.
====

==== Unstable Builds

Another option is to use the latest builds for the master branch, available on the restic beta download site. These too are pre-compiled and ready to run, and a new version is built every time a push is made to the master branch.

==== Windows

On Windows, put the restic.exe binary into %SystemRoot%\System32 to use restic in scripts without the need for absolute paths to the binary. This requires administrator rights.

=== Docker Container

We’re maintaining a bare docker container with just a few files and the restic binary, you can get it with docker pull like this:

----
$ docker pull restic/restic
----

[NOTE]
====
Another docker container which offers more configuration options is
available as a contribution (Thank you!). You can find it at
https://github.com/Lobaro/restic-backup-docker
====

=== From Source

restic is written in the Go programming language and you need at least Go version 1.9. Building restic may also work with older versions of Go, but that’s not supported. See the Getting started guide of the Go project for instructions how to install Go.

In order to build restic from source, execute the following steps:

----
$ git clone https://github.com/restic/restic
[...]

$ cd restic

$ go run -mod=vendor build.go
----

For Go versions < 1.11, the option -mod=vendor needs to be removed, like this:

----
$ go run build.go
----

You can easily cross-compile restic for all supported platforms, just supply the target OS and platform via the command-line options like this (for Windows and FreeBSD respectively):

----
$ go run -mod=vendor build.go --goos windows --goarch amd64

$ go run -mod=vendor build.go --goos freebsd --goarch 386

$ go run -mod=vendor build.go --goos linux --goarch arm --goarm 6
----

Again, for Go < 1.11 `-mod=vendor` needs to be removed.

The resulting binary is statically linked and does not require any libraries.

At the moment, the only tested compiler for restic is the official Go compiler. Building restic with gccgo may work, but is not supported.

=== Autocompletion

Restic can write out man pages and bash/zsh compatible autocompletion scripts:

----
$ ./restic generate --help

The "generate" command writes automatically generated files like the man pages
and the auto-completion files for bash and zsh).

Usage:
  restic generate [command] [flags]

Flags:
      --bash-completion file   write bash completion file
  -h, --help                   help for generate
      --man directory          write man pages to directory
      --zsh-completion file    write zsh completion file
----

Example for using sudo to write a bash completion script directly to the system-wide location:

----
$ sudo ./restic generate --bash-completion /etc/bash_completion.d/restic
writing bash completion file to /etc/bash_completion.d/restic
----

== Preparing a new repository

The place where your backups will be saved is called a “repository”. This chapter explains how to create (“init”) such a repository. The repository can be stored locally, or on some remote server or service. We’ll first cover using a local repository; the remaining sections of this chapter cover all the other options. You can skip to the next chapter once you’ve read the relevant section here.

For automated backups, restic accepts the repository location in the environment variable `RESTIC_REPOSITORY`. For the password, several options exist:

* Setting the environment variable `RESTIC_PASSWORD`
* Specifying the path to a file with the password via the option `--password-file` or the environment variable `RESTIC_PASSWORD_FILE`
* Configuring a program to be called when the password is needed via the option `--password-command` or the environment variable `RESTIC_PASSWORD_COMMAND`

=== Local

In order to create a repository at /srv/restic-repo, run the following command and enter the same password twice:

----
$ restic init --repo /srv/restic-repo
enter password for new backend:
enter password again:
created restic backend 085b3c76b9 at /srv/restic-repo
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.
----

[WARNING]
====
Remembering your password is important! If you lose it, you won’t be able to access data stored in the repository.
====

=== SFTP

In order to backup data via SFTP, you must first set up a server with SSH and let it know your public key. Passwordless login is really important since restic fails to connect to the repository if the server prompts for credentials.

Once the server is configured, the setup of the SFTP repository can simply be achieved by changing the URL scheme in the `init` command:

----
$ restic -r sftp:user@host:/srv/restic-repo init
enter password for new backend:
enter password again:
created restic backend f1c6108821 at sftp:user@host:/srv/restic-repo
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.
----

You can also specify a relative (read: no slash (/) character at the beginning) directory, in this case the dir is relative to the remote user’s home directory.

[NOTE]
====
Please be aware that sftp servers do not expand the tilde character (`~`) normally used as an alias for a user’s home directory. If you want to specify a path relative to the user’s home directory, pass a relative path to the sftp backend.
====

The backend config string does not allow specifying a port. If you need to contact an sftp server on a different port, you can create an entry in the `ssh` file, usually located in your user’s home directory at `~/.ssh/config` or in `/etc/ssh/ssh_config`:

----
Host foo
    User bar
    Port 2222
----

Then use the specified host name foo normally (you don’t need to specify the user name in this case):

----
$ restic -r sftp:foo:/srv/restic-repo init
----

You can also add an entry with a special host name which does not exist, just for use with restic, and use the `Hostname` option to set the real host name:

----
Host restic-backup-host
    Hostname foo
    User bar
    Port 2222
----

Then use it in the backend specification:

----
$ restic -r sftp:restic-backup-host:/srv/restic-repo init
----

Last, if you’d like to use an entirely different program to create the SFTP connection, you can specify the command to be run with the option `-o sftp.command="foobar"`.

[NOTE]
====
Please be aware that sftp servers close connections when no data is received by the client. This can happen when restic is processing huge amounts of unchanged data. To avoid this issue add the following lines to the client’s .ssh/config file:
====

----
ServerAliveInterval 60
ServerAliveCountMax 240
----

=== REST Server

In order to backup data to the remote server via HTTP or HTTPS protocol, you must first set up a remote REST server instance. Once the server is configured, accessing it is achieved by changing the URL scheme like this:

----
$ restic -r rest:http://host:8000/
----

Depending on your REST server setup, you can use HTTPS protocol, password protection, multiple repositories or any combination of those features. The TCP/IP port is also configurable. Here are some more examples:

----
$ restic -r rest:https://host:8000/
$ restic -r rest:https://user:pass@host:8000/
$ restic -r rest:https://user:pass@host:8000/my_backup_repo/
----

If you use TLS, restic will use the system’s CA certificates to verify the server certificate. When the verification fails, restic refuses to proceed and exits with an error. If you have your own self-signed certificate, or a custom CA certificate should be used for verification, you can pass restic the certificate filename via the `--cacert` option. It will then verify that the server’s certificate is contained in the file passed to this option, or signed by a CA certificate in the file. In this case, the system CA certificates are not considered at all.

REST server uses exactly the same directory structure as local backend, so you should be able to access it both locally and via HTTP, even simultaneously.

=== Amazon S3

Restic can backup data to any Amazon S3 bucket. However, in this case, changing the URL scheme is not enough since Amazon uses special security credentials to sign HTTP requests. By consequence, you must first setup the following environment variables with the credentials you obtained while creating the bucket.

----
$ export AWS_ACCESS_KEY_ID=<MY_ACCESS_KEY>
$ export AWS_SECRET_ACCESS_KEY=<MY_SECRET_ACCESS_KEY>
----

You can then easily initialize a repository that uses your Amazon S3 as a backend. If the bucket does not exist it will be created in the default location:

----
$ restic -r s3:s3.amazonaws.com/bucket_name init
enter password for new backend:
enter password again:
created restic backend eefee03bbd at s3:s3.amazonaws.com/bucket_name
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.
----

It is not possible at the moment to have restic create a new bucket in a different location, so you need to create it using a different program. Afterwards, the S3 server (`s3.amazonaws.com`) will redirect restic to the correct endpoint.

Until version 0.8.0, restic used a default prefix of `restic`, so the files in the bucket were placed in a directory named `restic`. If you want to access a repository created with an older version of restic, specify the path after the bucket name like this:

----
$ restic -r s3:s3.amazonaws.com/bucket_name/restic [...]
----

For an S3-compatible server that is not Amazon (like Minio, see below), or is only available via HTTP, you can specify the URL to the server like this: `s3:http://server:port/bucket_name`.

=== Minio Server

Minio is an Open Source Object Storage, written in Go and compatible with AWS S3 API.

* Download and Install Minio Server.
* You can also refer to https://docs.minio.io for step by step guidance on installation and getting started on Minio Client and Minio Server.

You must first setup the following environment variables with the credentials of your Minio Server.

----
$ export AWS_ACCESS_KEY_ID=<YOUR-MINIO-ACCESS-KEY-ID>
$ export AWS_SECRET_ACCESS_KEY= <YOUR-MINIO-SECRET-ACCESS-KEY>
----

Now you can easily initialize restic to use Minio server as backend with this command.

----
$ ./restic -r s3:http://localhost:9000/restic init
enter password for new backend:
enter password again:
created restic backend 6ad29560f5 at s3:http://localhost:9000/restic1
Please note that knowledge of your password is required to access
the repository. Losing your password means that your data is irrecoverably lost.
----

=== OpenStack Swift

Restic can backup data to an OpenStack Swift container. Because Swift supports various authentication methods, credentials are passed through environment variables. In order to help integration with existing OpenStack installations, the naming convention of those variables follows the official Python Swift client:

----
# For keystone v1 authentication
$ export ST_AUTH=<MY_AUTH_URL>
$ export ST_USER=<MY_USER_NAME>
$ export ST_KEY=<MY_USER_PASSWORD>

# For keystone v2 authentication (some variables are optional)
$ export OS_AUTH_URL=<MY_AUTH_URL>
$ export OS_REGION_NAME=<MY_REGION_NAME>
$ export OS_USERNAME=<MY_USERNAME>
$ export OS_PASSWORD=<MY_PASSWORD>
$ export OS_TENANT_ID=<MY_TENANT_ID>
$ export OS_TENANT_NAME=<MY_TENANT_NAME>

# For keystone v3 authentication (some variables are optional)
$ export OS_AUTH_URL=<MY_AUTH_URL>
$ export OS_REGION_NAME=<MY_REGION_NAME>
$ export OS_USERNAME=<MY_USERNAME>
$ export OS_PASSWORD=<MY_PASSWORD>
$ export OS_USER_DOMAIN_NAME=<MY_DOMAIN_NAME>
$ export OS_PROJECT_NAME=<MY_PROJECT_NAME>
$ export OS_PROJECT_DOMAIN_NAME=<MY_PROJECT_DOMAIN_NAME>

# For keystone v3 application credential authentication (application credential id)
$ export OS_AUTH_URL=<MY_AUTH_URL>
$ export OS_APPLICATION_CREDENTIAL_ID=<MY_APPLICATION_CREDENTIAL_ID>
$ export OS_APPLICATION_CREDENTIAL_SECRET=<MY_APPLICATION_CREDENTIAL_SECRET>

# For keystone v3 application credential authentication (application credential name)
$ export OS_AUTH_URL=<MY_AUTH_URL>
$ export OS_USERNAME=<MY_USERNAME>
$ export OS_USER_DOMAIN_NAME=<MY_DOMAIN_NAME>
$ export OS_APPLICATION_CREDENTIAL_NAME=<MY_APPLICATION_CREDENTIAL_NAME>
$ export OS_APPLICATION_CREDENTIAL_SECRET=<MY_APPLICATION_CREDENTIAL_SECRET>

# For authentication based on tokens
$ export OS_STORAGE_URL=<MY_STORAGE_URL>
$ export OS_AUTH_TOKEN=<MY_AUTH_TOKEN>
----

Restic should be compatible with an OpenStack RC file in most cases.

Once environment variables are set up, a new repository can be created. The name of the Swift container and optional path can be specified. If the container does not exist, it will be created automatically:

----
$ restic -r swift:container_name:/path init   # path is optional
enter password for new backend:
enter password again:
created restic backend eefee03bbd at swift:container_name:/path
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.
----

The policy of the new container created by restic can be changed using environment variable:

----
$ export SWIFT_DEFAULT_CONTAINER_POLICY=<MY_CONTAINER_POLICY>
----

=== Backblaze B2

Restic can backup data to any Backblaze B2 bucket. You need to first setup the following environment variables with the credentials you can find in the dashboard on the “Buckets” page when signed into your B2 account:

----
$ export B2_ACCOUNT_ID=<MY_APPLICATION_KEY_ID>
$ export B2_ACCOUNT_KEY=<MY_SECRET_ACCOUNT_KEY>
----

[NOTE]
====
In case you want to use Backblaze Application Keys replace <MY_APPLICATION_KEY_ID> and <MY_SECRET_ACCOUNT_KEY> with <applicationKeyId> and <applicationKey> respectively.
====

You can then initialize a repository stored at Backblaze B2. If the bucket does not exist yet and the credentials you passed to restic have the privilege to create buckets, it will be created automatically:

----
$ restic -r b2:bucketname:path/to/repo init
enter password for new backend:
enter password again:
created restic backend eefee03bbd at b2:bucketname:path/to/repo
Please note that knowledge of your password is required to access the repository.
Losing your password means that your data is irrecoverably lost.
----

Note that the bucket name must be unique across all of B2.

The number of concurrent connections to the B2 service can be set with the `-o b2.connections=10` switch. By default, at most five parallel connections are established.

=== Microsoft Azure Blob Storage

You can also store backups on Microsoft Azure Blob Storage. Export the Azure account name and key as follows:

----
$ export AZURE_ACCOUNT_NAME=<ACCOUNT_NAME>
$ export AZURE_ACCOUNT_KEY=<SECRET_KEY>
----

Afterwards you can initialize a repository in a container called foo in the root path like this:

----
$ restic -r azure:foo:/ init
enter password for new backend:
enter password again:

created restic backend a934bac191 at azure:foo:/
[...]
----

The number of concurrent connections to the Azure Blob Storage service can be set with the `-o azure.connections=10` switch. By default, at most five parallel connections are established.

=== Google Cloud Storage

Restic supports Google Cloud Storage as a backend and connects via a service account.

For normal restic operation, the service account must have the `storage.objects.{create,delete,get,list}` permissions for the bucket. These are included in the “Storage Object Admin” role. `restic init` can create the repository bucket. Doing so requires the `storage.buckets.create` permission (“Storage Admin” role). If the bucket already exists, that permission is unnecessary.

To use the Google Cloud Storage backend, first create a service account key and download the JSON credentials file. Second, find the Google Project ID that you can see in the Google Cloud Platform console at the “Storage/Settings” menu. Export the path to the JSON key file and the project ID as follows:

----
$ export GOOGLE_PROJECT_ID=123123123123
$ export GOOGLE_APPLICATION_CREDENTIALS=$HOME/.config/gs-secret-restic-key.json
----

Restic uses Google’s client library to generate default authentication material, which means if you’re running in Google Container Engine or are otherwise located on an instance with default service accounts then these should work out of the box.

Once authenticated, you can use the `gs:` backend type to create a new repository in the bucket `foo` at the root path:

----
$ restic -r gs:foo:/ init
enter password for new backend:
enter password again:

created restic backend bde47d6254 at gs:foo2/
[...]
----

The number of concurrent connections to the GCS service can be set with the `-o gs.connections=10` switch. By default, at most five parallel connections are established.

=== Other Services via rclone

The program rclone can be used to access many other different services and store data there. First, you need to install and configure rclone. The general backend specification format is `rclone:<remote>:<path>`, the `<remote>:<path> `component will be directly passed to rclone. When you configure a remote named `foo`, you can then call restic as follows to initiate a new repository in the path `bar` in the repo:

----
$ restic -r rclone:foo:bar init
----

Restic takes care of starting and stopping rclone.

As a more concrete example, suppose you have configured a remote named `b2prod` for Backblaze B2 with rclone, with a bucket called `yggdrasil`. You can then use rclone to list files in the bucket like this:

----
$ rclone ls b2prod:yggdrasil
----

In order to create a new repository in the root directory of the bucket, call restic like this:

----
$ restic -r rclone:b2prod:yggdrasil init
----

If you want to use the path `foo/bar/baz` in the bucket instead, pass this to restic:

----
$ restic -r rclone:b2prod:yggdrasil/foo/bar/baz init
----

Listing the files of an empty repository directly with rclone should return a listing similar to the following:

----
$ rclone ls b2prod:yggdrasil/foo/bar/baz
    155 bar/baz/config
    448 bar/baz/keys/4bf9c78049de689d73a56ed0546f83b8416795295cda12ec7fb9465af3900b44
----

Rclone can be configured with environment variables, so for instance configuring a bandwidth limit for rclone can be achieved by setting the `RCLONE_BWLIMIT` environment variable:

----
$ export RCLONE_BWLIMIT=1M
----

For debugging rclone, you can set the environment variable `RCLONE_VERBOSE=2`.

The rclone backend has two additional options:

* `-o rclone.program` specifies the path to rclone, the default value is just `rclone`
* `-o rclone.args` allows setting the arguments passed to rclone, by default this is `serve restic --stdio --b2-hard-delete --drive-use-trash=false`

The reason for the two last parameters (`--b2-hard-delete` and `--drive-use-trash=false`) can be found in the corresponding GitHub issue #1657.

In order to start rclone, restic will build a list of arguments by joining the following lists (in this order): `rclone.program`, `rclone.args` and as the last parameter the value that follows the `rclone:` prefix of the repository specification.

So, calling restic like this

----
$ restic -o rclone.program="/path/to/rclone" \
  -o rclone.args="serve restic --stdio --bwlimit 1M --b2-hard-delete --verbose" \
  -r rclone:b2:foo/bar
----

runs rclone as follows:

----
$ /path/to/rclone serve restic --stdio --bwlimit 1M --b2-hard-delete --verbose b2:foo/bar
----

Manually setting `rclone.program` also allows running a remote instance of rclone e.g. via SSH on a server, for example:

----
$ restic -o rclone.program="ssh user@host rclone" -r rclone:b2:foo/bar
----

The rclone command may also be hard-coded in the SSH configuration or the user’s public key, in this case it may be sufficient to just start the SSH connection (and it’s irrelevant what’s passed after `rclone:` in the repository specification):

----
$ restic -o rclone.program="ssh user@host" -r rclone:x
----

=== Password prompt on Windows

At the moment, restic only supports the default Windows console interaction. If you use emulation environments like MSYS2 or Cygwin, which use terminals like `Mintty` or `rxvt`, you may get a password error.

You can workaround this by using a special tool called `winpty` (look here and here for detail information). On MSYS2, you can install `winpty` as follows:

----
$ pacman -S winpty
$ winpty restic -r /srv/restic-repo init
----

== Backing up

Now we’re ready to backup some data. The contents of a directory at a specific point in time is called a “snapshot” in restic. Run the following command and enter the repository password you chose above again:

----
$ restic -r /srv/restic-repo --verbose backup ~/work
open repository
enter password for repository:
password is correct
lock repository
load index files
start scan
start backup
scan finished in 1.837s
processed 1.720 GiB in 0:12
Files:        5307 new,     0 changed,     0 unmodified
Dirs:         1867 new,     0 changed,     0 unmodified
Added:      1.200 GiB
snapshot 40dc1520 saved
----

As you can see, restic created a backup of the directory and was pretty fast! The specific snapshot just created is identified by a sequence of hexadecimal characters, `40dc1520` in this case.

You can see that restic tells us it processed 1.720 GiB of data, this is the size of the files and directories in `~/work` on the local file system. It also tells us that only 1.200 GiB was added to the repository. This means that some of the data was duplicate and restic was able to efficiently reduce it.

If you don’t pass the `--verbose` option, restic will print less data. You’ll still get a nice live status display. Be aware that the live status shows the processed files and not the transferred data. Transferred volume might be lower (due to de-duplication) or higher.

If you run the command again, restic will create another snapshot of your data, but this time it’s even faster and no new data was added to the repository (since all data is already there). This is de-duplication at work!

----
$ restic -r /srv/restic-repo backup --verbose ~/work
open repository
enter password for repository:
password is correct
lock repository
load index files
using parent snapshot d875ae93
start scan
start backup
scan finished in 1.881s
processed 1.720 GiB in 0:03
Files:           0 new,     0 changed,  5307 unmodified
Dirs:            0 new,     0 changed,  1867 unmodified
Added:      0 B
snapshot 79766175 saved
----

You can even backup individual files in the same repository (not passing `--verbose` means less output):

----
$ restic -r /srv/restic-repo backup ~/work.txt
enter password for repository:
password is correct
snapshot 249d0210 saved
----

If you’re interested in what restic does, pass `--verbose` twice (or `--verbose 2`) to display detailed information about each file and directory restic encounters:

----
$ echo 'more data foo bar' >> ~/work.txt

$ restic -r /srv/restic-repo backup --verbose --verbose ~/work.txt
open repository
enter password for repository:
password is correct
lock repository
load index files
using parent snapshot f3f8d56b
start scan
start backup
scan finished in 2.115s
modified  /home/user/work.txt, saved in 0.007s (22 B added)
modified  /home/user/, saved in 0.008s (0 B added, 378 B metadata)
modified  /home/, saved in 0.009s (0 B added, 375 B metadata)
processed 22 B in 0:02
Files:           0 new,     1 changed,     0 unmodified
Dirs:            0 new,     2 changed,     0 unmodified
Data Blobs:      1 new
Tree Blobs:      3 new
Added:      1.116 KiB
snapshot 8dc503fc saved
----

In fact several hosts may use the same repository to backup directories and files leading to a greater de-duplication.

Please be aware that when you backup different directories (or the directories to be saved have a variable name component like a time/date), restic always needs to read all files and only afterwards can compute which parts of the files need to be saved. When you backup the same directory again (maybe with new or changed files) restic will find the old snapshot in the repo and by default only reads those files that are new or have been modified since the last snapshot. This is decided based on the following attributes of the file in the file system:

* Type (file, symlink, or directory?)
* Modification time
* Size
* Inode number (internal number used to reference a file in a file system)

Now is a good time to run `restic check` to verify that all data is properly stored in the repository. You should run this command regularly to make sure the internal structure of the repository is free of errors.

=== Including and Excluding Files

You can exclude folders and files by specifying exclude patterns, currently the exclude options are:

* `--exclude` Specified one or more times to exclude one or more items
* `--iexclude` Same as `--exclude` but ignores the case of paths
* `--exclude-caches` Specified once to exclude folders containing a special file
* `--exclude-file` Specified one or more times to exclude items listed in a given file
* `--exclude-if-present foo` Specified one or more times to exclude a folder’s content if it contains a file called `foo` (optionally having a given header, no wildcards for the file name supported)

Let’s say we have a file called `excludes.txt` with the following content:

----
# exclude go-files
*.go
# exclude foo/x/y/z/bar foo/x/bar foo/bar
foo/**/bar
----

It can be used like this:

----
$ restic -r /srv/restic-repo backup ~/work --exclude="*.c" --exclude-file=excludes.txt
----

This instruct restic to exclude files matching the following criteria:

* All files matching `*.go` (second line in `excludes.txt`)
* All files and sub-directories named `bar` which reside somewhere below a directory called `foo` (fourth line in `excludes.txt`)
* All files matching `*.c` (parameter `--exclude`)

Please see `restic help backup` for more specific information about each exclude option.

Patterns use filepath.Glob internally, see filepath.Match for syntax. Patterns are tested against the full path of a file/dir to be saved, even if restic is passed a relative path to save. Environment-variables in exclude-files are expanded with os.ExpandEnv, so `/home/$USER/foo` will be expanded to `/home/bob/foo` for the user bob. To get a literal dollar sign, write `$$` to the file.

Patterns need to match on complete path components. For example, the pattern foo:

* matches `/dir1/foo/dir2/file` and `/dir/foo`
* does not match `/dir/foobar` or `barfoo`

A trailing `/` is ignored, a leading `/` anchors the pattern at the root directory. This means, `/bin` matches `/bin/bash` but does not match `/usr/bin/restic`.

Regular wildcards cannot be used to match over the directory separator `/`. For example: `b*ash` matches `/bin/bash` but does not match `/bin/ash`.

For this, the special wildcard `**` can be used to match arbitrary sub-directories: The pattern `foo/**/bar` matches:

* `/dir1/foo/dir2/bar/file`
* `/foo/bar/file`
* `/tmp/foo/bar`

By specifying the option `--one-file-system` you can instruct restic to only backup files from the file systems the initially specified files or directories reside on. For example, calling restic like this won’t backup `/sys` or `/dev` on a Linux system:

----
$ restic -r /srv/restic-repo backup --one-file-system /
----

[NOTE]
====
`--one-file-system` is currently unsupported on Windows, and will cause the backup to immediately fail with an error.
====

By using the `--files-from` option you can read the files you want to backup from one or more files. This is especially useful if a lot of files have to be backed up that are not in the same folder or are maybe pre-filtered by other software.

For example maybe you want to backup files which have a name that matches a certain pattern:

----
$ find /tmp/somefiles | grep 'PATTERN' > /tmp/files_to_backup
----

You can then use restic to backup the filtered files:

----
$ restic -r /srv/restic-repo backup --files-from /tmp/files_to_backup
----

Incidentally you can also combine `--files-from` with the normal files args:

----
$ restic -r /srv/restic-repo backup --files-from /tmp/files_to_backup /tmp/some_additional_file
----

Paths in the listing file can be absolute or relative.

=== Comparing Snapshots

Restic has a diff command which shows the difference between two snapshots and displays a small statistic, just pass the command two snapshot IDs:

----
$ restic -r /srv/restic-repo diff 5845b002 2ab627a6
password is correct
comparing snapshot ea657ce5 to 2ab627a6:

 C   /restic/cmd_diff.go
+    /restic/foo
 C   /restic/restic

Files:           0 new,     0 removed,     2 changed
Dirs:            1 new,     0 removed
Others:          0 new,     0 removed
Data Blobs:     14 new,    15 removed
Tree Blobs:      2 new,     1 removed
  Added:   16.403 MiB
  Removed: 16.402 MiB
----

=== Backing up special items and metadata

Symlinks are archived as symlinks, `restic` does not follow them. When you restore, you get the same symlink again, with the same link target and the same timestamps.

If there is a bind-mount below a directory that is to be saved, restic descends into it.

*Device files* are saved and restored as device files. This means that e.g. `/dev/sda` is archived as a block device file and restored as such. This also means that the content of the corresponding disk is not read, at least not from the device file.

By default, restic does not save the access time (atime) for any files or other items, since it is not possible to reliably disable updating the access time by restic itself. This means that for each new backup a lot of metadata is written, and the next backup needs to write new metadata again. If you really want to save the access time for files and directories, you can pass the `--with-atime` option to the `backup` command.

In filesystems that do not support inode consistency, like FUSE-based ones and pCloud, it is possible to ignore inode on changed files comparison by passing `--ignore-inode` to `backup` command.

=== Reading data from stdin

Sometimes it can be nice to directly save the output of a program, e.g. `mysqldump` so that the SQL can later be restored. Restic supports this mode of operation, just supply the option `--stdin` to the `backup` command like this:

----
$ set -o pipefail
$ mysqldump [...] | restic -r /srv/restic-repo backup --stdin
----

This creates a new snapshot of the output of `mysqldump`. You can then use e.g. the fuse mounting option (see below) to mount the repository and read the file.

By default, the file name stdin is used, a different name can be specified with `--stdin-filename`, e.g. like this:

----
$ mysqldump [...] | restic -r /srv/restic-repo backup --stdin --stdin-filename production.sql
----

The option `pipefail` is highly recommended so that a non-zero exit code from one of the programs in the pipe (e.g. mysqldump here) makes the whole chain return a non-zero exit code. Refer to the Use the Unofficial Bash Strict Mode for more details on this.

=== Tags for backup

Snapshots can have one or more tags, short strings which add identifying information. Just specify the tags for a snapshot one by one with `--tag`:

----
$ restic -r /srv/restic-repo backup --tag projectX --tag foo --tag bar ~/work
[...]
----

The tags can later be used to keep (or forget) snapshots with the forget command. The command tag can be used to modify tags on an existing snapshot.

=== Space requirements

Restic currently assumes that your backup repository has sufficient space for the backup operation you are about to perform. This is a realistic assumption for many cloud providers, but may not be true when backing up to local disks.

Should you run out of space during the middle of a backup, there will be some additional data in the repository, but the snapshot will never be created as it would only be written at the very (successful) end of the backup operation. Previous snapshots will still be there and will still work.

=== Environment Variables

In addition to command-line options, restic supports passing various options in environment variables. The following list of environment variables:

----
RESTIC_REPOSITORY                   Location of repository (replaces -r)
RESTIC_PASSWORD_FILE                Location of password file (replaces --password-file)
RESTIC_PASSWORD                     The actual password for the repository

AWS_ACCESS_KEY_ID                   Amazon S3 access key ID
AWS_SECRET_ACCESS_KEY               Amazon S3 secret access key

ST_AUTH                             Auth URL for keystone v1 authentication
ST_USER                             Username for keystone v1 authentication
ST_KEY                              Password for keystone v1 authentication

OS_AUTH_URL                         Auth URL for keystone authentication
OS_REGION_NAME                      Region name for keystone authentication
OS_USERNAME                         Username for keystone authentication
OS_PASSWORD                         Password for keystone authentication
OS_TENANT_ID                        Tenant ID for keystone v2 authentication
OS_TENANT_NAME                      Tenant name for keystone v2 authentication

OS_USER_DOMAIN_NAME                 User domain name for keystone authentication
OS_PROJECT_NAME                     Project name for keystone authentication
OS_PROJECT_DOMAIN_NAME              Project domain name for keystone authentication

OS_APPLICATION_CREDENTIAL_ID        Application Credential ID (keystone v3)
OS_APPLICATION_CREDENTIAL_NAME      Application Credential Name (keystone v3)
OS_APPLICATION_CREDENTIAL_SECRET    Application Credential Secret (keystone v3)

OS_STORAGE_URL                      Storage URL for token authentication
OS_AUTH_TOKEN                       Auth token for token authentication

B2_ACCOUNT_ID                       Account ID or applicationKeyId for Backblaze B2
B2_ACCOUNT_KEY                      Account Key or applicationKey for Backblaze B2

AZURE_ACCOUNT_NAME                  Account name for Azure
AZURE_ACCOUNT_KEY                   Account key for Azure

GOOGLE_PROJECT_ID                   Project ID for Google Cloud Storage
GOOGLE_APPLICATION_CREDENTIALS      Application Credentials for Google Cloud Storage (e.g. $HOME/.config/gs-secret-restic-key.json)

RCLONE_BWLIMIT                      rclone bandwidth limit
----

== Working with repositories

=== Listing all snapshots

Now, you can list all the snapshots stored in the repository:

----
$ restic -r /srv/restic-repo snapshots
enter password for repository:
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
40dc1520  2015-05-08 21:38:30  kasimir        /home/user/work
79766175  2015-05-08 21:40:19  kasimir        /home/user/work
bdbd3439  2015-05-08 21:45:17  luigi          /home/art
590c8fc8  2015-05-08 21:47:38  kazik          /srv
9f0bc19e  2015-05-08 21:46:11  luigi          /srv
----

You can filter the listing by directory path:

----
$ restic -r /srv/restic-repo snapshots --path="/srv"
enter password for repository:
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
590c8fc8  2015-05-08 21:47:38  kazik          /srv
9f0bc19e  2015-05-08 21:46:11  luigi          /srv
----

Or filter by host:

----
$ restic -r /srv/restic-repo snapshots --host luigi
enter password for repository:
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
bdbd3439  2015-05-08 21:45:17  luigi          /home/art
9f0bc19e  2015-05-08 21:46:11  luigi          /srv
----

Combining filters is also possible.

Furthermore you can group the output by the same filters (host, paths, tags):

----
$ restic -r /srv/restic-repo snapshots --group-by host

enter password for repository:
snapshots for (host [kasimir])
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
40dc1520  2015-05-08 21:38:30  kasimir        /home/user/work
79766175  2015-05-08 21:40:19  kasimir        /home/user/work
2 snapshots
snapshots for (host [luigi])
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
bdbd3439  2015-05-08 21:45:17  luigi          /home/art
9f0bc19e  2015-05-08 21:46:11  luigi          /srv
2 snapshots
snapshots for (host [kazik])
ID        Date                 Host    Tags   Directory
----------------------------------------------------------------------
590c8fc8  2015-05-08 21:47:38  kazik          /srv
1 snapshots
----

=== Checking a repo’s integrity and consistency

Imagine your repository is saved on a server that has a faulty hard drive, or even worse, attackers get privileged access and modify your backup with the intention to make you restore malicious data:

----
$ echo "boom" >> backup/index/d795ffa99a8ab8f8e42cec1f814df4e48b8f49129360fb57613df93739faee97
----

In order to detect these things, it is a good idea to regularly use the check command to test whether everything is alright, your precious backup data is consistent and the integrity is unharmed:

----
$ restic -r /srv/restic-repo check
Load indexes
ciphertext verification failed
----

Trying to restore a snapshot which has been modified as shown above will yield the same error:

----
$ restic -r /srv/restic-repo restore 79766175 --target /tmp/restore-work
Load indexes
ciphertext verification failed
----

By default, `check` command does not check that repository data files are unmodified. Use `--read-data` parameter to check all repository data files:

----
$ restic -r /srv/restic-repo check --read-data
load indexes
check all packs
check snapshots, trees and blobs
read all data
----

Use `--read-data-subset=n/t` parameter to check subset of repository data files. The parameter takes two values, `n` and `t`. All repository data files are logically divided in `t` roughly equal groups and only files that belong to the group number `n` are checked. For example, the following commands check all repository data files over 5 separate invocations:

----
$ restic -r /srv/restic-repo check --read-data-subset=1/5
$ restic -r /srv/restic-repo check --read-data-subset=2/5
$ restic -r /srv/restic-repo check --read-data-subset=3/5
$ restic -r /srv/restic-repo check --read-data-subset=4/5
$ restic -r /srv/restic-repo check --read-data-subset=5/5
----

== Restoring from backup

=== Restoring from a snapshot

Restoring a snapshot is as easy as it sounds, just use the following command to restore the contents of the latest snapshot to `/tmp/restore-work`:

----
$ restic -r /srv/restic-repo restore 79766175 --target /tmp/restore-work
enter password for repository:
restoring <Snapshot of [/home/user/work] at 2015-05-08 21:40:19.884408621 +0200 CEST> to /tmp/restore-work
----

Use the word `latest` to restore the last backup. You can also combine `latest` with the `--host` and `--path` filters to choose the last backup for a specific host, path or both.

----
$ restic -r /srv/restic-repo restore latest --target /tmp/restore-art --path "/home/art" --host luigi
enter password for repository:
restoring <Snapshot of [/home/art] at 2015-05-08 21:45:17.884408621 +0200 CEST> to /tmp/restore-art
----

Use `--exclude` and `--include` to restrict the restore to a subset of files in the snapshot. For example, to restore a single file:

----
$ restic -r /srv/restic-repo restore 79766175 --target /tmp/restore-work --include /work/foo
enter password for repository:
restoring <Snapshot of [/home/user/work] at 2015-05-08 21:40:19.884408621 +0200 CEST> to /tmp/restore-work
----

This will restore the file `foo` to `/tmp/restore-work/work/foo`.

You can use the command `restic ls latest` or `restic find foo` to find the path to the file within the snapshot. This path you can then pass to `--include` in verbatim to only restore the single file or directory.

There are case insensitive variants of of `--exclude` and `--include` called `--iexclude` and `--iinclude`. These options will behave the same way but ignore the casing of paths.

=== Restore using mount

Browsing your backup as a regular file system is also very easy. First, create a mount point such as `/mnt/restic` and then use the following command to serve the repository with FUSE:

----
$ mkdir /mnt/restic
$ restic -r /srv/restic-repo mount /mnt/restic
enter password for repository:
Now serving /srv/restic-repo at /mnt/restic
When finished, quit with Ctrl-c or umount the mountpoint.
----

Mounting repositories via FUSE is not possible on OpenBSD, Solaris/illumos and Windows. For Linux, the `fuse` kernel module needs to be loaded. For FreeBSD, you may need to install FUSE and load the kernel module (`kldload fuse`).

Restic supports storage and preservation of hard links. However, since hard links exist in the scope of a filesystem by definition, restoring hard links from a fuse mount should be done by a program that preserves hard links. A program that does so is rsync, used with the option –hard-links.

=== Printing files to stdout

Sometimes it’s helpful to print files to stdout so that other programs can read the data directly. This can be achieved by using the dump command, like this:

----
$ restic -r /srv/restic-repo dump latest production.sql | mysql
----

If you have saved multiple different things into the same repo, the latest snapshot may not be the right one. For example, consider the following snapshots in a repo:

----
$ restic -r /srv/restic-repo snapshots
ID        Date                 Host        Tags        Directory
----------------------------------------------------------------------
562bfc5e  2018-07-14 20:18:01  mopped                  /home/user/file1
bbacb625  2018-07-14 20:18:07  mopped                  /home/other/work
e922c858  2018-07-14 20:18:10  mopped                  /home/other/work
098db9d5  2018-07-14 20:18:13  mopped                  /production.sql
b62f46ec  2018-07-14 20:18:16  mopped                  /home/user/file1
1541acae  2018-07-14 20:18:18  mopped                  /home/other/work
----------------------------------------------------------------------
----

Here, restic would resolve `latest to the snapshot `1541acae`, which does not contain the file we’d like to print at all (`production.sql`). In this case, you can pass restic the snapshot ID of the snapshot you like to restore:

----
$ restic -r /srv/restic-repo dump 098db9d5 production.sql | mysql
----

Or you can pass restic a path that should be used for selecting the latest snapshot. The path must match the patch printed in the “Directory” column, e.g.:

----
$ restic -r /srv/restic-repo dump --path /production.sql latest production.sql | mysql
----

It is also possible to `dump` the contents of a whole folder structure to stdout. To retain the information about the files and folders Restic will output the contents in the tar format:

----
$ restic -r /srv/restic-repo dump /home/other/work latest > restore.tar
----

== Removing backup snapshots

All backup space is finite, so restic allows removing old snapshots. This can be done either manually (by specifying a snapshot ID to remove) or by using a policy that describes which snapshots to forget. For all remove operations, two commands need to be called in sequence: `forget` to remove a snapshot and `prune` to actually remove the data that was referenced by the snapshot from the repository. This can be automated with the `--prune` option of the `forget` command, which runs `prune` automatically if snapshots have been removed.

[WARNING]
====
Pruning snapshots can be a very time-consuming process, taking nearly as long as backups themselves. During a prune operation, the index is locked and backups cannot be completed. Performance improvements are planned for this feature.
====

It is advisable to run `restic check` after pruning, to make sure you are alerted, should the internal data structures of the repository be damaged.

=== Remove a single snapshot

The command `snapshots` can be used to list all snapshots in a repository like this:

----
$ restic -r /srv/restic-repo snapshots
enter password for repository:
ID        Date                 Host      Tags  Directory
----------------------------------------------------------------------
40dc1520  2015-05-08 21:38:30  kasimir         /home/user/work
79766175  2015-05-08 21:40:19  kasimir         /home/user/work
bdbd3439  2015-05-08 21:45:17  luigi           /home/art
590c8fc8  2015-05-08 21:47:38  kazik           /srv
9f0bc19e  2015-05-08 21:46:11  luigi           /srv
----

In order to remove the snapshot of `/home/art`, use the forget command and specify the snapshot ID on the command line:

----
$ restic -r /srv/restic-repo forget bdbd3439
enter password for repository:
removed snapshot d3f01f63
----

Afterwards this snapshot is removed:

----
$ restic -r /srv/restic-repo snapshots
enter password for repository:
ID        Date                 Host     Tags  Directory
----------------------------------------------------------------------
40dc1520  2015-05-08 21:38:30  kasimir        /home/user/work
79766175  2015-05-08 21:40:19  kasimir        /home/user/work
590c8fc8  2015-05-08 21:47:38  kazik          /srv
9f0bc19e  2015-05-08 21:46:11  luigi          /srv
----

But the data that was referenced by files in this snapshot is still stored in the repository. To cleanup unreferenced data, the `prune` command must be run:

----
$ restic -r /srv/restic-repo prune
enter password for repository:

counting files in repo
building new index for repo
[0:00] 100.00%  22 / 22 files
repository contains 22 packs (8512 blobs) with 100.092 MiB bytes
processed 8512 blobs: 0 duplicate blobs, 0B duplicate
load all snapshots
find data that is still in use for 1 snapshots
[0:00] 100.00%  1 / 1 snapshots
found 8433 of 8512 data blobs still in use
will rewrite 3 packs
creating new index
[0:00] 86.36%  19 / 22 files
saved new index as 544a5084
done
----

Afterwards the repository is smaller.

You can automate this two-step process by using the `--prune` switch to `forget`:

----
$ restic forget --keep-last 1 --prune
snapshots for host mopped, directories /home/user/work:

keep 1 snapshots:
ID        Date                 Host        Tags        Directory
----------------------------------------------------------------------
4bba301e  2017-02-21 10:49:18  mopped                  /home/user/work

remove 1 snapshots:
ID        Date                 Host        Tags        Directory
----------------------------------------------------------------------
8c02b94b  2017-02-21 10:48:33  mopped                  /home/user/work

1 snapshots have been removed, running prune
counting files in repo
building new index for repo
[0:00] 100.00%  37 / 37 packs
repository contains 37 packs (5521 blobs) with 151.012 MiB bytes
processed 5521 blobs: 0 duplicate blobs, 0B duplicate
load all snapshots
find data that is still in use for 1 snapshots
[0:00] 100.00%  1 / 1 snapshots
found 5323 of 5521 data blobs still in use, removing 198 blobs
will delete 0 packs and rewrite 27 packs, this frees 22.106 MiB
creating new index
[0:00] 100.00%  30 / 30 packs
saved new index as b49f3e68
done
----

=== Removing snapshots according to a policy

Removing snapshots manually is tedious and error-prone, therefore restic allows specifying which snapshots should be removed automatically according to a policy. You can specify how many hourly, daily, weekly, monthly and yearly snapshots to keep, any other snapshots are removed. The most important command-line parameter here is `--dry-run` which instructs restic to not remove anything but print which snapshots would be removed.

When `forget` is run with a policy, restic loads the list of all snapshots, then groups these by host name and list of directories. The grouping options can be set with `--group-by`, to only group snapshots by paths and tags use `--group-by paths,tags`. The policy is then applied to each group of snapshots separately. This is a safety feature.

The forget command accepts the following parameters:

* `--keep-last n` never delete the `n` last (most recent) snapshots
* `--keep-hourly n` for the last `n` hours in which a snapshot was made, keep only the last snapshot for each hour.
* `--keep-daily n` for the last `n` days which have one or more snapshots, only keep the last one for that day.
* `--keep-weekly n` for the last `n` weeks which have one or more snapshots, only keep the last one for that week.
* `--keep-monthly n` for the last `n` months which have one or more snapshots, only keep the last one for that month.
* `--keep-yearly n` for the last `n` years which have one or more snapshots, only keep the last one for that year.
* `--keep-tag` keep all snapshots which have all tags specified by this option (can be specified multiple times).
* `--keep-within duration` keep all snapshots which have been made within the `duration` of the latest snapshot. duration needs to be a number of years, months, days, and hours, e.g. `2y5m7d3h` will keep all snapshots made in the two years, five months, seven days, and three hours before the latest snapshot.

Multiple policies will be ORed together so as to be as inclusive as possible for keeping snapshots.

Additionally, you can restrict removing snapshots to those which have a particular hostname with the `--hostname` parameter, or tags with the `--tag` option. When multiple tags are specified, only the snapshots which have all the tags are considered. For example, the following command removes all but the latest snapshot of all snapshots that have the tag `foo`:

----
$ restic forget --tag foo --keep-last 1
----

This command removes all but the last snapshot of all snapshots that have either the `foo` or `bar` tag set:

----
$ restic forget --tag foo --tag bar --keep-last 1
----

To only keep the last snapshot of all snapshots with both the tag `foo` and `bar` set use:

----
$ restic forget --tag foo,tag bar --keep-last 1
----

All the `--keep-*` options above only count hours/days/weeks/months/years which have a snapshot, so those without a snapshot are ignored.

For safety reasons, restic refuses to act on an “empty” policy. For example, if one were to specify `--keep-last 0` to forget all snapshots in the repository, restic will respond that no snapshots will be removed. To delete all snapshots, use `--keep-last 1` and then finally remove the last snapshot ID manually (by passing the ID to `forget`).

All snapshots are evaluated against all matching `--keep-*` counts. A single snapshot on 2017-09-30 (Sat) will count as a daily, weekly and monthly.

Let’s explain this with an example: Suppose you have only made a backup on each Sunday for 12 weeks. Then `forget --keep-daily 4` will keep the last four snapshots for the last four Sundays, but remove the rest. Only counting the days which have a backup and ignore the ones without is a safety feature: it prevents restic from removing many snapshots when no new ones are created. If it was implemented otherwise, running `forget --keep-daily 4` on a Friday would remove all snapshots!

Another example: Suppose you make daily backups for 100 years. Then forget `--keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 75` will keep the most recent 7 daily snapshots, then 4 (remember, 7 dailies already include a week!) last-day-of-the-weeks and 11 or 12 last-day-of-the-months (11 or 12 depends if the 5 weeklies cross a month). And finally 75 last-day-of-the-year snapshots. All other snapshots are removed.

== Encryption

__“The design might not be perfect, but it’s good. Encryption is a first-class feature, the implementation looks sane and I guess the deduplication trade-off is worth it. So… I’m going to use restic for my personal backups.”__ Filippo Valsorda

=== Manage repository keys

The `key` command allows you to set multiple access keys or passwords per repository. In fact, you can use the `list`, `add`, `remove`, and `passwd` (changes a password) sub-commands to manage these keys very precisely:

----
$ restic -r /srv/restic-repo key list
enter password for repository:
 ID          User        Host        Created
----------------------------------------------------------------------
*eb78040b    username    kasimir   2015-08-12 13:29:57

$ restic -r /srv/restic-repo key add
enter password for repository:
enter password for new key:
enter password again:
saved new key as <Key of username@kasimir, created on 2015-08-12 13:35:05.316831933 +0200 CEST>

$ restic -r /srv/restic-repo key list
enter password for repository:
 ID          User        Host        Created
----------------------------------------------------------------------
 5c657874    username    kasimir   2015-08-12 13:35:05
*eb78040b    username    kasimir   2015-08-12 13:29:57
----

== Scripting

This is a list of how certain tasks may be accomplished when you use restic via scripts.

=== Check if a repository is already initialized

You may find a need to check if a repository is already initialized, perhaps to prevent your script from initializing a repository multiple times. The command `snapshots` may be used for this purpose:

----
$ restic -r /srv/restic-repo snapshots
Fatal: unable to open config file: Stat: stat /srv/restic-repo/config: no such file or directory
Is there a repository at the following location?
/srv/restic-repo
----

If a repository does not exist, restic will return a non-zero exit code and print an error message. Note that restic will also return a non-zero exit code if a different error is encountered (e.g.: incorrect password to `snapshots`) and it may print a different error message. If there are no errors, restic will return a zero exit code and print all the snapshots.

== FAQ

This is the list of Frequently Asked Questions for restic.

=== `restic check` reports packs that aren’t referenced in any index, is my repository broken?

When `restic check` reports that there are pack files in the repository that are not referenced in any index, that’s (in contrast to what restic reports at the moment) not a source for concern. The output looks like this:

----
$ restic check
Create exclusive lock for repository
Load indexes
Check all packs
pack 819a9a52e4f51230afa89aefbf90df37fb70996337ae57e6f7a822959206a85e: not referenced in any index
pack de299e69fb075354a3775b6b045d152387201f1cdc229c31d1caa34c3b340141: not referenced in any index
Check snapshots, trees and blobs
Fatal: repository contains errors
----

The message means that there is more data stored in the repo than strictly necessary. With high probability this is duplicate data. In order to clean it up, the command `restic prune` can be used. The cause of this bug is not yet known.

=== I ran a `restic` command but it is not working as intended, what do I do now?

If you are running a restic command and it is not working as you hoped it would, there is an easy way of checking how your shell interpreted the command you are trying to run.

Here is an example of a mistake in a backup command that results in the command not working as expected. A user wants to run the following `restic backup` command

----
$ restic backup --exclude "~/documents" ~
----

[IMPORTANT]
====
This command contains an intentional user error described in this paragraph.
====

This command will result in a complete backup of the current logged in user’s home directory and it won’t exclude the folder `~/documents/` - which is not what the user wanted to achieve. The problem is how the path to `~/documents` is passed to restic.

In order to spot an issue like this, you can make use of the following ruby command preceding your restic command.

----
$ ruby -e 'puts ARGV.inspect' restic backup --exclude "~/documents" ~
["restic", "backup", "--exclude", "~/documents", "/home/john"]
----

As you can see, the command outputs every argument you have passed to the shell. This is what restic sees when you run your command. The error here is that the tilde `~` in "`~/documents`" didn’t get expanded as it is quoted.

----
$ echo ~/documents
/home/john/documents

$ echo "~/documents"
~/document

$ echo "$HOME/documents"
/home/john/documents
----

Restic handles globbing and expansion in the following ways:

* Globbing is only expanded for lines read via `--files-from`
* Environment variables are not expanded in the file read via `--files-from`
* `*` is expanded for paths read via `--files-from`
* e.g. For backup targets given to restic as arguments on the shell, neither glob expansion nor shell variable replacement is done. If restic is called as `restic backup '*' '$HOME'`, it will try to backup the literal file(s)/dir(s) `*` and `$HOME`
* Double-asterisk `**` only works in exclude patterns as this is a custom extension built into restic; the shell must not expand it

=== How can I specify encryption passwords automatically?

When you run `restic backup`, you need to enter the passphrase on the console. This is not very convenient for automated backups, so you can also provide the password through the `--password-file` option, or one of the environment variables `RESTIC_PASSWORD` or `RESTIC_PASSWORD_FILE`. A discussion is in progress over implementing unattended backups happens in #533.

[IMPORTANT]
====
Be careful how you set the environment; using the env command, a system() call or using inline shell scripts (e.g. RESTIC_PASSWORD=password restic …) might expose the credentials in the process list directly and they will be readable to all users on a system. Using export in a shell script file should be safe, however, as the environment of a process is accessible only to that user. Please make sure that the permissions on the files where the password is eventually stored are safe (e.g. 0600 and owned by root).
====

=== How to prioritize restic’s IO and CPU time

If you’d like to change the IO priority of restic, run it in the following way

----
$ ionice -c2 -n0 ./restic -r /media/your/backup/ backup /home
----

This runs `restic `in the so-called best effort class (`-c2`), with the highest possible priority (`-n0`).

Take a look at the ionice manpage to learn about the other classes.

To change the *CPU scheduling priority* to a higher-than-standard value, use would run:

----
$ nice --10 ./restic -r /media/your/backup/ backup /home
----

Again, the nice manpage has more information.

You can also *combine IO and CPU scheduling priority*:

----
$ ionice -c2 nice -n19 ./restic -r /media/gour/backup/ backup /home
----

This example puts restic in the IO class 2 (best effort) and tells the CPU scheduling algorithm to give it the least favorable niceness (19).

The above example makes sure that the system the backup runs on is not slowed down, which is particularly useful for servers.

=== Creating new repo on a Synology NAS via sftp fails

Sometimes creating a new restic repository on a Synology NAS via sftp fails with an error similar to the following:

----
$ restic init -r sftp:user@nas:/volume1/restic-repo init
create backend at sftp:user@nas:/volume1/restic-repo/ failed:
    mkdirAll(/volume1/restic-repo/index): unable to create directories: [...]
----

Although you can log into the NAS via SSH and see that the directory structure is there.

The reason for this behavior is that apparently Synology NAS expose a different directory structure via sftp, so the path that needs to be specified is different than the directory structure on the device and maybe even as exposed via other protocols.

Try removing the /volume1 prefix in your paths. If this does not work, use sftp and ls to explore the SFTP file system hierarchy on your NAS.

The following may work:

----
$ restic init -r sftp:user@nas:/restic-repo init
----

=== Why does restic perform so poorly on Windows?

In some cases the real-time protection of antivirus software can interfere with restic’s operations. If you are experiencing bad performance you can try to temporarily disable your antivirus software to find out if it is the cause for your performance problems.
