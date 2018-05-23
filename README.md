# docker-samba-ldap
Docker container with openLDAP preconfiguration

This container is not yet functional with LDAP (for unknown reasons, suggestions welcome).

Contains the Crypt-SmbHash scrip mentionned in this [guide](https://spredzy.wordpress.com/2013/08/30/samba-standalone-openldap/)

I will redact a more indepth README once I'm over with finals, thanks for understanding.

## Sample docker run commands

### Simple samba container
```
docker run -d \
-p 139:139 \
-p 445:445 \
-v /mnt/share/samba/etc/samba:/etc/samba \
-v /mnt/share/samba/etc/smbldap-tools:/etc/smbldap-tools \
-v /mnt/share/samba/private:/var/lib/samba/private \
-v /mnt/share/samba/share:/share \
--name samba \
cajetan19/samba-ldap
```

### Samba with OpenLDAP configuration
```
docker run \
-p 139:139 \
-p 445:445 \
--env LDAP_CAPABLE=1 \
--env WORKGROUP=CONTOSO \
--env LDAP_HOST=172.17.0.10 \
--env LDAP_SUFIX=dc=contoso,dc=com \
--env LDAP_USERS_SUFIX=ou=Users,dc=contoso,dc=com \
--env LDAP_GROUPS_SUFIX=ou=Groups,dc=contoso,dc=com \
--env LDAP_MACHINES_SUFIX=ou=Computers,dc=contoso,dc=com \
--env LDAP_ADMIN_DN=cn=admin,dc=contoso,dc=com \
--env LDAP_ADMIN_PASSWD=P@$$w0rd \
--env LDAP_SSL=no \
--env LDAP_TLS=0 \
--env LDAP_BASE_DN=ou=Users,dc=contoso,dc=com \
-v /mnt/share/samba/etc/samba:/etc/samba \
-v /mnt/share/samba/etc/smbldap-tools:/etc/smbldap-tools \
-v /mnt/share/samba/private:/var/lib/samba/private \
-v /mnt/share/samba/share:/share \
--network yournetwork \
--ip 172.17.0.13 \
--dns 172.18.0.12 \
-h samba.contoso.com \
--name samba \
cajetan19/samba
```
