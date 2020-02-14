sudo apt-get install gddrescue xz-utils
unxz ubuntu-mate-15.10.3-desktop-armhf-raspberry-pi-2.img.xz
sudo ddrescue -D --force ubuntu-mate-15.10.3-desktop-armhf-raspberry-pi-2.img /dev/sdx
