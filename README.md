# docker-samba-ldap
Docker container with openLDAP preconfiguration

This container is not yet functional with LDAP (for unknown reasons, suggestions welcome).

Contains the Crypt-SmbHash scrip mentionned in this [guide](https://spredzy.wordpress.com/2013/08/30/samba-standalone-openldap/)

I will redact a more indepth README once I'm over with finals, thanks for understanding.

## Sample docker run commands

### Simple samba container
The basic SAMBA configuration creates 2 default shares:

**\\samba-srv\data** accessible only from the SMB_USER account with the SMB_USER_PASSWD password.

**\\samba-srv\external** accessible by anyone with read/write permissions.

```
docker run -d \
-p 139:139 \
-p 445:445 \
-v /mnt/share/samba/etc/samba:/etc/samba \
-v /mnt/share/samba/share:/share \
--env SMB_USER=user \
--env SMB_USER_PASSWD=password \
--env SMB_EXT_USER=extuser \
--env SMB_EXT_USER_PASSWD=extpassword \
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

## Disclaimers

### LDAP authentication functionality

**NOTE** I am fully unable to get this container working by authenticating LDAP users for the shared folder. This was built together in a relatively short period of time, with a fall back to a classic samba share as a backup solution.

Any information/tips/pointer/hints as to why this did not work and/or how to fix this would be very appreciated. I shall update this image accordingly with the provided information to render this image functional.

### Performance issues

Be aware that the classic Samba shares are not the most performant, while I tried investigating the reasons, time constraints forced me to leave this as is. As for the LDAP authentication, any information/tips/clues are most welcome.
