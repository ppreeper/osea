= Duplicity Backup 

----
duplicity remove-all-but-n-full 2 --force file:///var/data/test/Desktop/

duplicity full --no-encryption /source file:///dest
duplicity incr --no-encryption /source file:///dest

duplicity cleanup file:///dest

#m h dom mon dow command
0 0 * * *  /usr/bin/duplicity cleanup --no-encryption file:///dest
5 0 * * *  /usr/bin/duplicity remove-all-but-n-full 2 --force file:///dest
10 0 * * 0  /usr/bin/duplicity full --no-encryption /source file:///dest
10 0 * * 1-6 /usr/bin/duplicity incr --no-encryption /source file:///dest
----
