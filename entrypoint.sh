#!/bin/bash 

if [ ! -d /etc/samba ]; then
	mkdir /etc/samba
fi

if [ ! -d /etc/smbldap-tools ]; then
	mkdir /etc/smbldap-tools
fi

if [ $LDAP_CAPABLE = 1 ]; then
	pushd /
	wget https://gist.githubusercontent.com/Spredzy/6389499/raw/e503ecc6bb530316b8d1db9c1f33d89a677e66d3/Crypt-SmbHash --no-check-certificate -O script
	pushd /tmp
        wget http://search.cpan.org/CPAN/authors/id/B/BJ/BJKUIT/Crypt-SmbHash-0.12.tar.gz
        tar xzf Crypt-SmbHash-0.12.tar.gz
	pushd /tmp/Crypt-SmbHash-0.12
        perl Makefile.PL
        make && make test && make install

if [ ! -f /etc/samba/smb.conf ]; then
cat > /etc/samba/smb.conf << EOF
[global]
   workgroup = $WORKGROUP
   dns proxy = no

   passdb backend = ldapsam:ldap://$LDAP_HOST/
   ldap suffix = $LDAP_SUFIX
   ldap user suffix = $LDAP_USERS_SUFIX
   ldap group suffix = $LDAP_GROUPS_SUFIX
   ldap machine suffix = $LDAP_MACHINES_SUFIX
   ldap admin dn = $LDAP_ADMIN_DN
   ldap ssl = $LDAP_SSL
   ldap passwd sync = yes

   security = user

[share]
    comment = Some share
    path = /share
    browseable = yes
    read only = no
    valid users = usera userb
EOF
fi

cat > /etc/nslcd.conf << EOF
uid nslcd
gid nslcd
uri ldap://$LDAP_HOST/
base $LDAP_BASE_DN
binddn $LDAP_ADMIN_DN
bindpw $LDAP_ADMIN_PASSWD
EOF

if [ ! -f /etc/smbldap-tools/smbldap.conf ]; then
cat > /etc/smbldap-tools/smbldap.conf << EOF
sambaDomain="$WORKGROUP"
slaveLDAP="$LDAP_HOST"
slavePort="389"
masterLDAP="$LDAP_HOST"
masterPort="389"
ldapTLS="$LDAP_TLS"
verify=""
cafile=""
clientcert=""
clientkey=""
suffix="$LDAP_SUFIX"
usersdn="$LDAP_USERS_SUFIX"
computersdn="$LDAP_MACHINES_SUFIX"
groupsdn="$LDAP_GROUPS_SUFIX"
idmapdn="$LDAP_USERS_SUFIX"
sambaUnixIdPooldn="sambaDomainName=$(hostname),${suffix}"
scope="sub"
hash_encrypt="SSHA"
crypt_salt_format=""
userLoginShell="/bin/bash"
userHome="/home/%U"
userHomeDirectoryMode="700"
userGecos="System User"
defaultUserGid="513"
defaultComputerGid="515"
skeletonDir="/etc/skel"
defaultMaxPasswordAge="45"
userSmbHome="\\\%U"
userProfile="\\\profiles\%U"
userHomeDrive=""
userScript=""
mailDomain="iglu.lu"
with_smbpasswd="0"
smbpasswd="/usr/bin/smbpasswd"
with_slappasswd="0"
slappasswd="/usr/sbin/slappasswd"
EOF
fi

if [ ! -f /etc/smbldap-tools/smbldap_bind.conf ]; then
cat > /etc/smbldap-tools/smbldap_bind.conf << EOF
slaveDN="$LDAP_ADMIN_DN"
slavePw="$LDAP_ADMIN_PASSWD"
masterDN="$LDAP_ADMIN_DN"
masterPw="$LDAP_ADMIN_PASSWD"
EOF
fi

smbpasswd -w $LDAP_ADMIN_PASSWD

else

    # If LDAP is not enabled, copy original files from tmp to their original location
    if [ -z "$(ls -A /etc/samba)" ]; then
        cp -R /tmp/samba/* /etc/samba
    fi

    # create a user for the samba share
    groupadd smbgrp
    useradd $SMB_USER -G smbgrp
    echo "$SMB_USER:$SMB_USER_PASSWD" | chpasswd

    # reproduce the user and password for samba
    echo -ne "$SMB_USER_PASSWD\n$SMB_USER_PASSWD\n" | smbpasswd -a -s $SMB_USER

    mkdir /share/data
    chown -R $SMB_USER:smbgrp /share/data
    chmod -R ug+rwx,o+rx-w /share/data

    mkdir /share/external
    chown -R $SMB_USER:smbgrp /share/external
    chmod -R ug+rwx,o+rx-w /share/external

cat >> /etc/samba/smb.conf << EOF
[data]
comment = Data
path = /share/data
valid users = @smbgrp
force group = smbgrp
create mask = 0660
directory mask = 0771
writable = yes

[external]
path = /share/external
force group = smbgrp
create mask = 0660
directory mask = 0771
browsable =yes
writable = yes
guest ok = yes
EOF

fi

exec "$@"
