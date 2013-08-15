#!/bin/bash
#
# Script d'installation de seedbox
# rutorrent + owncloud + urbackup + PDFtk
#

if [[ $EUID -ne 0 ]]; then
  echo "Le script doit être executé en tant que root" 1>&2
  exit 1
fi

#
# Choix des installations
#

read -p "Installation de ruTorrent ?" INSTALL_RUTORRENT
read -p "Installation de ownCloud ?" INSTALL_OWNCLOUD
read -p "Installation de urBackup ?" INSTALL_URBACKUP
read -p "Installation de PDFtk ?" INSTALL_PDFTK

#
# Preparation du script
#

INSTALL_DIR=/etc/my-seedbox-lionel/sources
read -p "Mot de passe root :" -s ROOT_PASS

aptitude update
aptitude safe-upgrade -y
apt-get --yes install git

rm -f -r /etc/my-seedbox-lionel
git clone https://github.com/blionel/my-seedbox-lionel.git /etc/my-seedbox-lionel

#
# Configuration des utilisateurs seedbox
#
read -p "Nombre d'utilisateurs à configurer :" nbuser

for i in `seq 1 $nbuser`;
do
     read -p "Nom d'utilisateur : " user[$i]
     read -p "Mot de passe : " pass[$i]
     echo -e "\n-----"
     uu[$i]=${user[$i]:0:3}
     UU[$i]=${uu[$i]^^*}
done

#
# Installation seedbox
#

if [ "$INSTALL_RUTORRENT" = "YES" ]; then

# Ajout des repos non-free
nano /etc/apt/sources.list

echo "deb http://ftp2.fr.debian.org/debian/ wheezy main non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp2.fr.debian.org/debian/ wheezy main non-free" >> /etc/apt/sources.list

# Installation des paquets necessaires

aptitude install -y vsftpd htop rar zip build-essential pkg-config libcurl4-openssl-dev libsigc++-2.0-dev libncurses5-dev lighttpd nano screen subversion libterm-readline-gnu-perl php5-cgi apache2-utils libcurl3 curl php5-curl php5-cli dtach unzip unrar ffmpeg

# Installation de libtorrent 0.13.2

cd /tmp
wget http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.2.tar.gz
tar zxfv libtorrent-0.13.2.tar.gz
cd libtorrent-0.13.2
./configure
make
make install

# Installation de XML RPC par le SVN

cd /tmp
svn checkout http://svn.code.sf.net/p/xmlrpc-c/code/stable xmlrpc-c
cd xmlrpc-c/
./configure
make
make install

# Installation de rTorrent 0.9.2

cd /tmp
wget http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.2.tar.gz
tar zxfv rtorrent-0.9.2.tar.gz
cd rtorrent-0.9.2
./configure --with-xmlrpc-c
make
make install

# Installation de ruTorrent

cd /var/www/
svn checkout http://rutorrent.googlecode.com/svn/trunk/rutorrent/

# Installation des plugins

cd rutorrent
rm -R plugins
svn checkout http://rutorrent.googlecode.com/svn/trunk/plugins/

cd /var/www/rutorrent/plugins/
svn co http://rutorrent-logoff.googlecode.com/svn/trunk/ logoff

cd /var/www/rutorrent/plugins/
svn co http://rutorrent-pausewebui.googlecode.com/svn/trunk/ pausewebui

cd /var/www/rutorrent/plugins/
wget http://rutorrent-tadd-labels.googlecode.com/files/lbll-suite_0.8.1.tar.gz
tar zxfv lbll-suite_0.8.1.tar.gz
rm lbll-suite_0.8.1.tar.gz

cd /var/www/rutorrent/plugins/
svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager

cd /tmp/
wget http://ftp.de.debian.org/debian/pool/main/b/buildtorrent/buildtorrent_0.8-4_amd64.deb
dpkg -i buildtorrent*.deb
rm buildtorrent*.deb

cd /tmp
wget http://downloads.sourceforge.net/project/zenlib/ZenLib/0.4.28/libzen0_0.4.28-1_amd64.Debian_6.0.deb
dpkg -i libzen0_0.4.28-1_amd64.Debian_6.0.deb
wget http://downloads.sourceforge.net/project/mediainfo/binary/libmediainfo0/0.7.61/libmediainfo0_0.7.61-1_amd64.Debian_6.0.deb
dpkg -i libmediainfo0_0.7.61-1_amd64.Debian_6.0.deb
wget http://downloads.sourceforge.net/project/mediainfo/binary/mediainfo/0.7.61/mediainfo_0.7.61-1_amd64.Debian_6.0.deb
dpkg -i mediainfo_0.7.61-1_amd64.Debian_6.0.deb

# Mise à jour des liens symboliques et des permissions

ldconfig
chown -R www-data:www-data /var/www/rutorrent

#
# Configuration générale
#

# Configuration du plugin create

cd /var/www/rutorrent/plugins/create
chaine="\$useExternal = \"buildtorrent\";"
sed -i "s/\$useExternal.*$/$chaine/" conf.php
chaine2="\$pathToCreatetorrent = \'\/usr\/bin\/buildtorrent\';"
sed -i "s/\$pathToCreatetorrent.*$/$chaine2/" conf.php

# Configuration du serveur web

cat $INSTALL_DIR/install_lighttpd.conf >> /etc/lighttpd/lighttpd.conf

# Active le module fastcgi

/usr/sbin/lighty-enable-mod fastcgi

# Creation du certificat SSL

mkdir /etc/lighttpd/certs
cd /etc/lighttpd/certs
openssl req -new -newkey rsa:1024 -days 365 -nodes -x509 -keyout lighttpd.pem -out lighttpd.pem

# Redemarrage du serveur pour activer les changements

/etc/init.d/lighttpd force-reload

# Configuration du serveur FTP

cd /etc
sed -i "s/^anonymous_enable=.*$//" vsftpd.conf
sed -i "s/^dirlist_enable=.*$//" vsftpd.conf
sed -i "s/^dirlist_enable=.*$//" vsftpd.conf
sed -i "s/^download_enable=.*$//" vsftpd.conf
sed -i "s/^guest_enable=.*$//" vsftpd.conf
sed -i "s/^listen=.*$//" vsftpd.conf
sed -i "s/^listen_ipv6=.*$//" vsftpd.conf
sed -i "s/^local_enable=.*$//" vsftpd.conf
sed -i "s/^local_umask=.*$//" vsftpd.conf
sed -i "s/^max_per_ip=.*$//" vsftpd.conf
sed -i "s/^pasv_enable=.*$//" vsftpd.conf
sed -i "s/^port_enable=.*$//" vsftpd.conf
sed -i "s/^pasv_promicuous=.*$//" vsftpd.conf
sed -i "s/^port_promiscuous=.*$//" vsftpd.conf
sed -i "s/^pasv_min_port=.*$//" vsftpd.conf
sed -i "s/^pasv_max_port=.*$//" vsftpd.conf
sed -i "s/^write_enable=.*$//" vsftpd.conf
sed -i "s/^chroot_local_user=.*$//" vsftpd.conf
sed -i "s/^chroot_list_enable=.*$//" vsftpd.conf
sed -i "s/^chroot_list_file=.*$//" vsftpd.conf

echo 'anonymous_enable=NO' >> vsftpd.conf
echo 'dirlist_enable=YES' >> vsftpd.conf
echo 'download_enable=YES' >> vsftpd.conf
echo 'guest_enable=NO' >> vsftpd.conf
echo 'listen=YES' >> vsftpd.conf
echo 'listen_ipv6=NO' >> vsftpd.conf
echo 'local_enable=YES' >> vsftpd.conf
echo 'local_umask=022' >> vsftpd.conf
echo 'max_per_ip=0' >> vsftpd.conf
echo 'pasv_enable=YES' >> vsftpd.conf
echo 'port_enable=YES' >> vsftpd.conf
echo 'pasv_promiscuous=NO' >> vsftpd.conf
echo 'port_promiscuous=NO' >> vsftpd.conf
echo 'pasv_min_port=0' >> vsftpd.conf
echo 'pasv_max_port=0' >> vsftpd.conf
echo 'write_enable=YES' >> vsftpd.conf
echo 'chroot_local_user=YES' >> vsftpd.conf
echo 'chroot_list_enable=YES' >> vsftpd.conf
echo 'chroot_list_file=\/etc\/vsftpd.chroot_list' >> vsftpd.conf

touch /etc/vsftpd.chroot_list

/etc/init.d/vsftpd reload

# Configuration du SSH

cd /etc/ssh
sed -i 's/^UsePAM yes/#UsePAM yes/' sshd_config
sed -i 's/^Subsystem sftp \/usr\/lib\/openssh\/sftp-server/#Subsystem sftp \/usr\/lib\/openssh\/sftp-server/' sshd_config
echo 'Subsystem sftp internal-sftp' >> sshd_config

#
# Ajout des utilisateurs
#

for i in `seq 1 $nbuser`;
do
	cat $INSTALL_DIR/install_lighttpd.conf_pre_user >> /etc/lighttpd/lighttpd.conf

	sed -i "s/<user>/${user[$i]}/" /etc/lighttpd/lighttpd.conf
        sed -i "s/<u>/${uu[$i]}/" /etc/lighttpd/lighttpd.conf
        sed -i "s/<UU>/${UU[$i]}/" /etc/lighttpd/lighttpd.conf
done

echo ")" >> /etc/lighttpd/lighttpd.conf
echo "server.modules += ( \"mod_scgi\" )" >> /etc/lighttpd/lighttpd.conf
echo "scgi.server = (" >> /etc/lighttpd/lighttpd.conf

for i in `seq 1 $nbuser`;
do
	useradd ${user[$i]}
	echo "${user[$i]}:${pass[$i]}" | chpasswd

	mkdir /home/${user[$i]}
	mkdir /home/${user[$i]}/watch
	mkdir /home/${user[$i]}/torrents
	mkdir /home/${user[$i]}/torrents/finish
	mkdir /home/${user[$i]}/.session

	ln -s /torrents/finish /home/${user[$i]}/finish

	# On bloque l'utilisateur dans son home en SFTP
	cd /etc/ssh/
	echo "Match user ${user[$i]}" >> sshd_config
	echo "ChrootDirectory /home/%u" >> sshd_config

	/etc/init.d/ssh restart

	# Creation du fichier de configuration rTorrent
	cd /home/${user[$i]}
	cp $INSTALL_DIR/install_rtorrent.rc .rtorrent.rc

	sed -i "s/<user>/${user[$i]}/" .rtorrent.rc
	sed -i "s/<u>/${uu[$i]}/" .rtorrent.rc

	# Permissions
	chown -R ${user[$i]}:${user[$i]} /home/${user[$i]}
	chown root:${user[$i]} /home/${user[$i]}
	chmod 755 /home/${user[$i]}

	# Ajout accès serveur web
	cat $INSTALL_DIR/install_lighttpd.conf_user >> /etc/lighttpd/lighttpd.conf
	sed -i "s/<user>/${user[$i]}/" /etc/lighttpd/lighttpd.conf
        sed -i "s/<u>/${uu[$i]}/" /etc/lighttpd/lighttpd.conf
        sed -i "s/<UU>/${UU[$i]}/" /etc/lighttpd/lighttpd.conf

	touch /etc/lighttpd/.auth
	htdigest /etc/lighttpd/.auth 'ruTorrent Seedbox' ${user[$i]}

	mkdir /var/www/rutorrent/conf/users/${user[$i]}
	cat $INSTALL_DIR/install_config.php >> /var/www/rutorrent/conf/users/${user[$i]}/config.php

	sed -i "s/<user>/${user[$i]}/" /var/www/rutorrent/conf/users/${user[$i]}/config.php
        sed -i "s/<u>/${uu[$i]}/" /var/www/rutorrent/conf/users/${user[$i]}/config.php
        sed -i "s/<UU>/${UU[$i]}/" /var/www/rutorrent/conf/users/${user[$i]}/config.php

	# Création d'un script de démarrage
	cp $INSTALL_DIR/install_user.rtord /etc/init.d/${uu[$i]}.rtord
	sed -i "s/<user>/${user[$i]}/" /etc/init.d/${uu[$i]}.rtord

	# Rendre le script executable
	chmod +x /etc/init.d/${uu[$i]}.rtord

	# Ajout tache cron
	$cron="*/1 * * * * if ! ( ps -U ${user[$i]} | grep rtorrent > /dev/null ); then /etc/init.d/${uu[$i]}.rtord start; fi"
	cat <(crontab -l) <(echo $cron) | crontab -
done

echo ")" >> /etc/lighttpd/lighttpd.conf

/etc/init.d/lighttpd restart

fi

#
# Installation owncloud
#

if [ "$INSTALL_OWNCLOUD" = "YES" ]; then

cd /tmp
wget http://download.owncloud.org/community/owncloud-5.0.9.tar.bz2
tar -xjvf owncloud-5.0.9.tar.bz2
mv owncloud /var/www
chown -R www-data:www-data /var/www/owncloud

# Configuration mySQL
echo "CREATE DATABASE owncloud;CREATE USER owncloud@localhost IDENTIFIED BY  '${pass[1]}';GRANT ALL PRIVILEGES ON  owncloud . * TO  'owncloud'@'localhost';" | mysql -u root -p$ROOT_PASS

# Création des répertoires user

for i in `seq 1 $nbuser`;
do
	mkdir /var/www/owncloud/data/${user[$i]}
	mkdir /var/www/owncloud/data/${user[$i]}/files/PDF/Deverrouiller
        mkdir /var/www/owncloud/data/${user[$i]}/files/PDF/Fusionner
        mkdir /var/www/owncloud/data/${user[$i]}/files/PDF/Separer
        mkdir /var/www/owncloud/data/${user[$i]}/files/PDF/Special
	ln -s /home/${user[$i]}/torrents/ /var/www/owncloud/data/${user[$i]}/files/Torrents
	ln -s /backup/${user[$i]}/ /var/www/owncloud/data/${user[$i]}/files/Backup
	chown www-data:www-data -R /var/www/owncloud/data/${user[$i]}
	chmod 755 /var/www/owncloud/data/${user[$i]}
done

fi

#
# Installation urBackup
#

if [ "$INSTALL_URBACKUP" = "YES" ]; then

dpkg -i urbackup-*.deb
apt-get -f install

fi

#
# Installation de PDFtk
#

if [ "$INSTALLWEBMIN1" = "YES" ]; then

apt-get --yes install pdftk
cp $INSTALL_DIR/install_pdf.php /var/www/pdf.php

fi

#
# Ajout page accueil
#

cp $INSTALL_DIR/install_quoi.php /var/www/quoi.php

echo "### INSTALLATION TERMINEE ###"

