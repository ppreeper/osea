= Parted Usage

== Make disklabel (old msdos, new gpt)

    parted /dev/sda mklabel gpt
    parted /dev/sda mklabel msdos

== Make basic partiion (from 1MB to 100% of disk)

    parted /dev/sda mkpart primary 1 100%

== Align partition optimally

    parted -a optimal /dev/sda mkpart primary 0% 100%
