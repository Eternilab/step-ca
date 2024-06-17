Role Name
=========

Ce rôle ansible s'occupe de l'installation d'une Infrastructure de Gestion de Clefs (IGC) sous Debian et permet l'usage d'un YubiHSM pour stocker les secrets des autorités de certifications.


Requirements
------------

OS : Debian >= 12

Architecture : amd64

Vous devez définir 3 groupes dans votre inventaire :
````{verbatim}
[ca_servers]
ca.eternilab.com

[ra_servers]
ra.eternilab.com

[va_servers]
va.eternilab.com
````
Le groupe ````ca_servers```` contient les machines qui répondront aux demandes de signature. Ce sont celles qui ont un HSM connecté (via un port USB par exemple).

Le groupe ````ra_servers```` contient les machines qui répondront frontalement aux requêtes ACME pour les clients souhaitant une signature d'une requête de certificat.

Le groupe ````va_servers```` contient les machines qui répondront aux demandes d'accès à la Certificate Revocation List (CRL) et aux demandent OCSP.


Role Variables
--------------

| Variable                | Required | Default | Choices                   | Comments                                 |
|-------------------------|----------|---------|---------------------------|------------------------------------------|
| step_ca_tmp_dir         | yes      | /tmp    | string                    |  |
| step_ca_version         | yes      | 0.26.1  | version                   |  |
| step_ca_arch            | yes      | amd64   | structure                 |  |
| step_ca_install_mode    | yes      | manual  | manual, binary, debian    |  |


Dependencies
------------

roles:
  step-cli
  openssl

Example Playbook
----------------

````{verbatim}
### PKI/IGC
- hosts:
    - ca_servers
    - ra_servers
    - va_servers
  roles:
    - step-ca
````

License
-------

See license.md

Author Information
------------------

Sylvain LEROY <sylvain.leroy@eternilab.com>

https://www.eternilab.com
