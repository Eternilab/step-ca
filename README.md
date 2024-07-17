Rôle Step-CA
============

Ce rôle ansible s'occupe de l'installation d'une Infrastructure de Gestion de Clefs (IGC) sous Debian et permet l'usage d'un YubiHSM pour stocker les secrets des autorités de certifications.


Exigeances
----------

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


Variables du rôle
-----------------

Les variables "Requises" nécessitent d'être définies dans l'environnement qui utilise le rôle. Sinon, la valeur par défaut fonctionne.

| Variable                     | Requise | Valeur par défaut                                                                                                                      | Choix                                  | Commentaires                                                                                           |
|------------------------------|---------|----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------|--------------------------------------------------------------------------------------------------------|
| step_ca_tmp_dir              | non     | /tmp                                                                                                                                   | string                                 |  |
| step_ca_version              | non     | 0.26.1                                                                                                                                 | version                                |  |
| step_ca_arch                 | non     | amd64                                                                                                                                  | amd64, 383, arm64, armv7, armv6, armv5 | Architecture Matérielle du serveur Step-CA |
| step_ca_install_mode         | non     | manual                                                                                                                                 | manual, binary, debian                 | De quelle façon installer Step-CA |
| step_ca_bin_file             | non     | /usr/local/bin/step-ca                                                                                                                 | path                                   | Fichier cible de l'installation pour le binaire|
| step_ca_systemd_svc_file     | non     | /etc/systemd/system/step-ca.service                                                                                                    | path                                   | Fichier cible de l'installation pour le service |
| step_ca_pid_file             | non     | /run/step_ca.pid                                                                                                                       | path                                   | Fichier cible de l'installation pour la tarball |
| step_ca_tarball_manual       | non     | step-ca_linux_{{ step_ca_version }}.tar.gz                                                                                             | nom de fichier                         | En mode d'installation manuel, nom de fichier cible du téléchargement |
| step_ca_url_manual           | non     | https://github.com/smallstep/certificates/archive/refs/tags/v{{ step_ca_version }}.tar.gz                                              | url                                    | En mode d'installation manuel, URL à partir de la quelle télécharger la tarball source |
| step_ca_tarball_binary       | non     | step-ca_linux_{{ step_ca_version }}_{{ step_ca_arch }}.tar.gz                                                                          | nom de fichier                         | En mode d'installation avec le binaire, nom de fichier cible du téléchargement |
| step_ca_url_binary           | non     | https://github.com/smallstep/certificates/releases/download/v{{ step_ca_version }}/{{ step_ca_tarball }}                               | url                                    | En mode d'installation avec le binaire, URL à partir de la quelle télécharger la tarball source |
| step_ca_url_deb              | non     | https://github.com/smallstep/certificates/releases/download/v{{ step_ca_version }}/step-ca_{{ step_ca_arch }}.deb                      | url                                    | En mode d'installation par debian, URL à partir de la quelle télécharger le paquet .deb |
| step_ca_url_systemd_svc_file | non     | https://raw.githubusercontent.com/smallstep/certificates/v{{ step_ca_version }}/systemd/step-ca.service                                | url                                    | En mode d'installation par debian, URL à partir de la quelle télécharger le service step-ca |
| step_ca_apt_state            | non     | present                                                                                                                                | present, absent, latest                | Installer / Désinstaller / Installer la dernière version de Step-CA|
| step_ca_server_listen_port   | non     | 9100                                                                                                                                   | port                                   | |
| step_ca_server_insecure_port | non     | 8080                                                                                                                                   | port                                   | |
| step_ca_client_listen_port   | non     | 9110                                                                                                                                   | port                                   | |
| step_ca_filelist             | non     | - config/ca_client.json<br> - config/ca_server.json<br>                                                                                | liste de noms de fichiers              | |
| step_ca_ca_templates         | non     | - templates/certs/x509/root.tpl<br> - templates/certs/x509/intermediate_client.tpl<br> - templates/certs/x509/intermediate_server.tpl  | liste de fichiers templates            | |
| step_ca_ra_templates         | non     | - templates/certs/x509/leaf_client.tpl<br> - templates/certs/x509/leaf_server.tpl                                                      | liste de fichiers templates            | |
| step_ca_dirlist              | non     | - certs<br> - config<br> - db_server<br> - db_client<br> - secrets<br> - templates                                                     | liste de dossiers                      | |
| step_ca_yubihsm              | non     | false                                                                                                                                  | booléen                                | Stocke les CA intermédiaires sur une YubiHSM (True) ou sur le disque (False). |
| step_ca_root_dir             | non     | /etc/step-ca                                                                                                                           | dossier                                | |
| proxy_env                    | non     |                                                                                                                                        | urls de proxys                         | Permet d'accéder à internet |
| step_ca_email                | oui     |                                                                                                                                        | Adresse e-mail                         | Contact technique |
| step_ca_domain               | oui     |                                                                                                                                        | Nom de domaine                         | Nom du domaine pour lequel signer les certificats. Utilisé dans les templates de certificats des leafs |

La variable "step_ca_structure" définit la structure de l'IGC. Chacune de ses valeurs est importante à définir.

| Variable                   | Choix                    | Commentaires                                                       |
|----------------------------|--------------------------|--------------------------------------------------------------------|
| rootCA                     |                          | Clé qui prendra pour valeur les variables relatives à la CA racine |
| SubCA                      |                          | Clé qui prendra pour valeur chacune des clés des CA intermédiaires |
|   NomDeSubCA               |                          | Clé qui prendra pour valeur les variables relatives à cette CA intermédiaire. Peut être renommée comme voulue |
|     is_root                | Booléen                  | Doit être définie sur true pour la rootCA et elle uniquement       |
|     organisation           | String                   | Nom de la société détentrice du certificat                         |
|     locality               | Nom de commune           | |
|     province               | Région                   | |
|     country                | Pays                     | |
|     minTLSCertDuration     | String                   | String au format "XXXXh". Durée minimale en heures de validité autorisée dans une demande de certificats TLS |
|     maxTLSCertDuration     | String                   | String au format "XXXXh". Durée maximale en heures de validité autorisée dans une demande de certificats TLS |
|     defaultTLSCertDuration | Valeur horaire en string | String au format "XXXXh". Durée par défaut en heures de validité des certificats TLS (si non spécifée dans la demande de certificat) |
|     min_key_size_rsa       | Entier                   | Taille minimale autorisée des clés RSA                             |
|     extKeyUsage            | serverAuth, clientAuth   | Usage cible de la clé. Doit être l'un et seulement un des choix    |
|     IssuingCertificateURL  | URL de certificat        | URL sur lequel récupérer le certificat                             |
|     crlDistributionPoints  | URL de CRL               | URL sur lequel récupérer la liste de révocation des certificats    |


Gestion des DNS
---------------

FQDN de la CA, sur laquelle tourne un step-ca en mode StepCAS CA qui a la capacité de signer avec l'identité de la SubCA (fichier ou HSM)
- ca.example.com

FQDN de la RA, sur laquelle tourne un step-ca en mode StepCAS RA qui fournit un service de renouvellement ACME.
- ra.example.com

FQDN du serveur OCSP OpenSSL, accessible uniquement par les reverse proxies frontaux.
- va.example.com

FQDN du reverse proxy frontal, exposé publiquement pour fournir le service OCSP (Authority Information Access - OCSP).
- ocsp.example.com

FQDN du reverse proxy frontal, exposé publiquement pour distribuer la CRL (CRL Distribution Points - FullName).
- crl.example.com

FQDN du reverse proxy frontal, exposé publiquement pour distribuer des certificats racines et intermédiaires (Authority Information Access - CA Issuers).
- dist.example.com


Dépendances
-----------

roles:
  step-cli
  openssl


Exemple de playbook
-------------------

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
