Rôle Step-CA
============

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

Les variables "Required = yes" nécessitent d'être définies dans l'environnement qui utilise le rôle. Sinon, la valeur par défaut fonctionne.

| Variable                     | Required | Default                                                                                                                               | Choices                                | Comments                                                     |
|------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------|--------------------------------------------------------------------------------------------------------|
| step_ca_tmp_dir              | no       | /tmp                                                                                                                                  | string                                 |  |
| step_ca_version              | no       | 0.26.1                                                                                                                                | version                                |  |
| step_ca_arch                 | no       | amd64                                                                                                                                 | amd64, 383, arm64, armv7, armv6, armv5 | Architecture Matérielle du serveur Step-CA |
| step_ca_install_mode         | no       | manual                                                                                                                                | manual, binary, debian                 | De quelle façon installer Step-CA |
| step_ca_bin_file             | no       | /usr/local/bin/step-ca                                                                                                                | path                                   | Fichier cible de l'installation pour le binaire|
| step_ca_systemd_svc_file     | no      | /etc/systemd/system/step-ca.service                                                                                                   | path                                   | Fichier cible de l'installation pour le service |
| step_ca_pid_file             | no      | /run/step_ca.pid                                                                                                                      | path                                   | Fichier cible de l'installation pour la tarball |
| step_ca_tarball_manual       | no      | step-ca_linux_{{ step_ca_version }}.tar.gz                                                                                            | nom de fichier                         | En mode d'installation manuel, nom de fichier cible du téléchargement |
| step_ca_url_manual           | no      | https://github.com/smallstep/certificates/archive/refs/tags/v{{ step_ca_version }}.tar.gz                                             | url                                    | En mode d'installation manuel, URL à partir de la quelle télécharger la tarball source |
| step_ca_tarball_binary       | no      | step-ca_linux_{{ step_ca_version }}_{{ step_ca_arch }}.tar.gz                                                                         | nom de fichier                         | En mode d'installation avec le binaire, nom de fichier cible du téléchargement |
| step_ca_url_binary           | no      | https://github.com/smallstep/certificates/releases/download/v{{ step_ca_version }}/{{ step_ca_tarball }}                              | url                                    | En mode d'installation avec le binaire, URL à partir de la quelle télécharger la tarball source |
| step_ca_url_deb              | no      | https://github.com/smallstep/certificates/releases/download/v{{ step_ca_version }}/step-ca_{{ step_ca_arch }}.deb                     | url                                    | En mode d'installation par debian, URL à partir de la quelle télécharger le paquet .deb |
| step_ca_url_systemd_svc_file | no      | https://raw.githubusercontent.com/smallstep/certificates/v{{ step_ca_version }}/systemd/step-ca.service                               | url                                    | En mode d'installation par debian, URL à partir de la quelle télécharger le service step-ca |
| step_ca_apt_state            | no      | present                                                                                                                               | present, absent, latest                | Installer / Désinstaller / Installer la dernière version de Step-CA|
| step_ca_server_listen_port   | no      | 9100                                                                                                                                  | port                                   | |
| step_ca_server_insecure_port | no      | 8080                                                                                                                                  | port                                   | |
| step_ca_client_listen_port   | no      | 9110                                                                                                                                  | port                                   | |
| step_ca_filelist             | no      | - config/ca_client.json<br> - config/ca_server.json<br>                                                                               | liste de noms de fichiers              | |
| step_ca_ca_templates         | no      | - templates/certs/x509/root.tpl<br> - templates/certs/x509/intermediate_client.tpl<br> - templates/certs/x509/intermediate_server.tpl | liste de fichiers templates            | |
| step_ca_ra_templates         | no      | - templates/certs/x509/leaf_client.tpl<br> - templates/certs/x509/leaf_server.tpl                                                     | liste de fichiers templates            | |
| step_ca_dirlist              | no      | - certs<br> - config<br> - db_server<br> - db_client<br> - secrets<br> - templates                                                    | liste de dossiers                      | |
| step_ca_yubihsm              | no      | true                                                                                                                                  | booléen                                | Stocke les CA intermédiaires sur une YubiHSM (True) ou sur le disque (False). |
| step_ca_root_dir             | no      | /etc/step-ca                                                                                                                          | dossier                                | |
| proxy_env                    | no       |                                                                                                                                       | urls de proxys                         | Permet d'accéder à internet |
| step_ca_email                | yes      |                                                                                                                                       | Adresse e-mail                         | Contact technique |
| step_ca_domain               | yes      |                                                                                                                                       | Nom de domaine                         | Nom du domaine pour lequel signer les certificats. Utilisé dans les templates de certificats des leafs |

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

Configuration Reverse Proxy
---------------------------

### TODO :
Documenter que le reverse proxy doit ne laisser passer vers la CA que l'adresse EXACTE de la CRL.

License
-------

See license.md

Author Information
------------------

Sylvain LEROY <sylvain.leroy@eternilab.com>

https://www.eternilab.com
