#!/bin/bash

# Update and install prerequisites
apt-get -y update
apt-get -y install git qemu qemu-user qemu-user-static binfmt-support
apt-get -y install libc6-i386 xinetd
apt-get -y install libstdc++6-armhf-cross libc6-armhf-cross
apt-get -y install daemontools-run daemontools

# compile pcap rotator
gcc /etc/service/pcap/rotate.c -o /etc/service/pcap/rotate

# DEFCON 22 challenges require /dev/ctf
ln -s /dev/urandom /dev/ctf

# By default, everything should be owned by root, and read-only.
chmod 700 /root
for file in $(git ls-files); do
    chown root:root $file
done
for file in $(git ls-files -- etc/sudoers.d); do
    chmod 0440 $file
done
for file in $(git ls-files -- usr); do
    chmod +rx $file
done

useradd -m ctf

# Service Permissions
for dir in /home/*/; do
  user=$(basename "$dir")

  useradd -m $user
  passwd  -l $user

  # Everything inside of the home directory should belong to the user
  chown -R $user:$user /home/$user
  chmod -R ug+rw,o=    /home/$user

  # The home directory itself is owned by root, so that it cannot be deleted.
  chown    root:$user  /home/$user
  chmod    1770        /home/$user

  # The service binary should be owned by the CTF user, so that it cannot
  # be modified or deleted.
  if [ -e /home/$user/$user ];
  then
    chown -h ctf:ctf     /home/$user/$user*
    chmod    0755        /home/$user/$user*
  fi

  # The CTF user should be in the group for everything
  usermod -a -G $user ctf

  # Remove the password and unlock the account
  passwd -u -d $user

  # Remove all cron jobs
  crontab -r -u $user
done

# Remove all cron jobs for root and ctf
crontab -r
crontab -u ctf -r

# Install armhf required libraries, which are not available via apt-get
pushd /root
wget -nc http://mirrors.mit.edu/debian/pool/main/p/pcre3/libpcre3_8.35-3.3_armhf.deb
wget -nc http://mirrors.mit.edu/debian/pool/main/g/glib2.0/libglib2.0-0_2.42.1-1_armhf.deb
wget -nc http://mirrors.mit.edu/debian/pool/main/o/openssl/libssl1.0.0_1.0.1k-3%2bdeb8u1_armhf.deb
mkdir out
for FILE in $(ls *.deb); do dpkg -x "$FILE" out; done
cp -r out/usr/lib/arm-linux-gnueabihf/* /usr/arm-linux-gnueabihf/lib
cp out/lib/arm-linux-gnueabihf/* /usr/arm-linux-gnueabihf/lib
rm -rf *.deb out
popd

# Kickstart xinetd
service xinetd restart

# Reload apparmor for tcpdump config
service apparmor reload

# reload sshd for configuration updates
service ssh restart

# Start daemontools
start svscan

# Everything below this line is optional hardening
apt-get -yq remove kexec-tools
apt-get -yq install fail2ban kpartx unattended-upgrades
rm -f /boot/System.map*

# Disable 'last'
chmod o-r /var/*/{btmp,wtmp,utmp}
