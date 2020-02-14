apt install python python3

$ ls /usr/bin/python*
/usr/bin/python  /usr/bin/python2  /usr/bin/python2.7  /usr/bin/python3  /usr/bin/python3.5  /usr/bin/python3.5m  /usr/bin/python3m

update-alternatives --list python
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
update-alternatives --install /usr/bin/python python /usr/bin/python3.5 2

python --version

update-alternatives --config python
