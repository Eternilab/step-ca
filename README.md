Rôle Step-CA
============

Ce rôle ansible s'occupe de l'installation d'une Infrastructure de Gestion de Clefs (IGC) sous Debian et permet l'usage d'un YubiHSM pour stocker les secrets des autorités de certifications.


Exigences
----------

OS supportés : Toutes les distributions Linux utilisant Systemd

Architectures supportées : Toutes les architectures suivantes : i386, i686, x86_64, armv5, armv6, armv7, aarch64

Le rôle a été testé avec Debian 12 sur x86_64 et aarch64.

Vous devez définir 3 groupes dans votre inventaire :
````{verbatim}
[ca_server]
ca.eternilab.com

[ra_servers]
ra.eternilab.com

[va_servers]
va.eternilab.com
````
Le groupe ````ca_server```` contient la machine qui répondra aux demandes de signature. Elle peut éventuellement avoir un HSM connecté (via un port USB par exemple) auquel cas la variable step_ca_yubihsm devra être configurée a True.

Le groupe ````ra_servers```` contient les machines qui répondront frontalement aux requêtes ACME pour les clients souhaitant une signature d'une requête de certificat.

Le groupe ````va_servers```` contient les machines qui répondront aux demandes d'accès à la Certificate Revocation List (CRL) et aux demandent OCSP.


Variables du rôle
-----------------

Les variables "Requises" nécessitent d'être définies dans l'environnement qui utilise le rôle. Sinon, la valeur par défaut fonctionne.

| Variable                     | Requise | Valeur par défaut                                                                                                                      | Choix                                  | Commentaires                                                                                           |
|------------------------------|---------|----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------|--------------------------------------------------------------------------------------------------------|
| step_ca_tmp_dir              | non     | /tmp                                                                                                                                   | string                                 | Dossier utilisé pour télécharger les fichiers temporaires |
| step_ca_version              | non     | 0.27.2                                                                                                                                 | version                                |  |
| step_ca_install_mode         | non     | debian                                                                                                                                 | manual, binary, debian                 | De quelle façon installer Step-CA |
| step_ca_bin_file             | non     | /usr/local/bin/step-ca                                                                                                                 | path                                   | Fichier cible de l'installation pour le binaire|
| step_ca_tarball_manual       | non     | step-ca_linux_{{ step_ca_version }}.tar.gz                                                                                             | nom de fichier                         | En mode d'installation manuel, nom de fichier cible du téléchargement |
| step_ca_url_manual           | non     | https://github.com/smallstep/certificates/archive/refs/tags/v{{ step_ca_version }}.tar.gz                                              | url                                    | En mode d'installation manuel, URL à partir de la quelle télécharger la tarball source |
| step_ca_tarball_binary       | non     | step-ca_linux_{{ step_ca_version }}_{{ step_ca_arch }}.tar.gz                                                                          | nom de fichier                         | En mode d'installation avec le binaire, nom de fichier cible du téléchargement |
| step_ca_url_binary           | non     | https://github.com/smallstep/certificates/releases/download/v{{ step_ca_version }}/{{ step_ca_tarball }}                               | url                                    | En mode d'installation avec le binaire, URL à partir de la quelle télécharger la tarball source |
| step_ca_url_deb              | non     | https://github.com/smallstep/certificates/releases/download/v{{ step_ca_version }}/step-ca_{{ step_ca_arch }}.deb                      | url                                    | En mode d'installation par debian, URL à partir de la quelle télécharger le paquet .deb |
| step_ca_apt_state            | non     | present                                                                                                                                | latest, present, absent                | Installer la dernière version de / Désinstaller / Installer Step-CA|
| step_ca_dirlist              | non     | - certs<br> - config<br> - db_server<br> - db_client<br> - secrets<br> - templates                                                     | liste de dossiers                      | Liste des dossiers qui seront créés pour chaque instance de SubCA |
| step_ca_yubihsm              | non     | false                                                                                                                                  | booléen                                | Stocke les CA intermédiaires sur une YubiHSM (True) ou sur le disque (False). |
| step_ca_root_dir             | non     | /etc/step-ca                                                                                                                           | dossier                                | |
| proxy_env                    | non     |                                                                                                                                        | urls de proxys                         | Permet d'accéder à internet |
| step_ca_ra_fqdn              | non     |                                                                                                                                        | Nom de la machine                      | Nom de la machine servant de RA. Cette variable peut être définie pour chaque machine servant de RA pour permettre de surcharger les noms DNS acceptés par le service step-ca dans le champ SNI de la requête initiale du client lorsque l'on établie une connexion TLS au début d'une session ACME. Cette valeur sera utilisée pour généré le certificat utilisé par la RA sinon par défaut ce sera le nom d'hôte de l'inventaire (voir leaf.tpl) |
| step_ca_admin_jwk_name       | oui     |                                                                                                                                        | nom/e-mail                             | Identité de l'administrateur par défaut, utilisée pour créer le premier Json Web Key permettant l'accès admin (provider JWK) au service step-ca |
| step_ca_domain               | oui     |                                                                                                                                        | Nom de domaine                         | Nom du domaine pour lequel signer les certificats. Utilisé dans les templates de certificats des leafs : quand une requête de signature de certificat (CSR) est présentée à la CA, le FQDN dans cette CSR doit se terminer par cette chaîne de caractères pour que la requête soit validée.|

La variable "step_ca_structure" définit la structure de l'IGC. Chacune de ses valeurs est importante à définir (toutes ne sont pas indispensables, elles peuvent rester vide pour tout ce qui détaille les emplacements et sanFilterType).

| Variable                   | Choix                    | Commentaires                                                          |
|----------------------------|--------------------------|-----------------------------------------------------------------------|
| rootCA                     |                          | Clé qui prendra pour valeur les variables relatives à la CA racine    |
|   fqdn                     |                          | Pour RAs : adresse de la CA & pour CA : validation SNI TLS (optionnel)|
|   organisation             |                          | TODO |
|   locality                 |                          | TODO |
|   province                 |                          | TODO |
|   country                  |                          | TODO |
|   keytype                  |                          | TODO |
|   keycurve                 |                          | TODO |
|   certDuration             |                          | TODO |
|   IssuingCertificateURL    |                          | TODO |
|   crlDistributionPoints    |                          | TODO |
| subCA                      |                          | Clé qui prendra pour valeur chacune des clés des CA intermédiaires    |
|   instances                |                          | Liste des instances de subCA                                          |
|     name                   | String                   | Nom de l'instance                                                     |
|     organisation           | String                   | Nom de la société détentrice du certificat                            |
|     locality               | Nom de commune           |                                                                       |
|     province               | Région                   |                                                                       |
|     country                | Pays                     |                                                                       |
|     minTLSCertDuration     | String                   | Format "XhYmZs". Durée de vie minimale autorisée pour certificats TLS |
|     maxTLSCertDuration     | String                   | Format "XhYmZs". Durée de vie maximale autorisée pour certificats TLS |
|     defaultTLSCertDuration | Valeur horaire en string | Format "XhYmZs". Durée de vie par defaut pour certificats TLS         |
|     min_key_size_rsa       | Entier                   | Taille minimale autorisée des clés RSA                                |
|     extKeyUsage            | serverAuth, clientAuth   | Usage cible de la clé. Doit être l'un et seulement un des choix       |
|     IssuingCertificateURL  | URL de certificat        | URL sur laquel récupérer le certificat                                |
|     crlDistributionPoints  | URL de CRL               | URL sur lequel récupérer la liste de révocation des certificats       |
|     listen_port            | port                     | Port sur lequel écoute step-ca en TLS pour RA et CA                   |
|     insecure_port          | port                     | Port sur lequel écoute step-ca en clair pour servir la CRL sur la CA  |
|     sanFilterType          | Type de filtre           | Peut prendre soit la valeur "email" soit ne pas être définie ou être définie à n'importe quoi d'autre. Filtre utilisé pour permettre de produire des certificats avec des SAN de type email au lieu de DNS. Les SANs dont d'un type ou de l'autre, pas les deux. Les autres types de SANs ne sont pas encore supportés. |


Gestion des DNS
---------------

<ul>
<li>FQDN de la CA, sur laquelle tourne un step-ca en mode StepCAS CA qui a la capacité de signer avec l'identité de la subCA (fichier ou HSM) :

```
ca.example.com
```
</li>

<li>FQDN de la RA, sur laquelle tourne un step-ca en mode StepCAS RA qui fournit un service de renouvellement ACME :

```
ra.example.com
```
</li>

<li>FQDN du serveur OCSP OpenSSL, accessible uniquement par les reverse proxies frontaux :

```
va.example.com
```
</li>

<li>FQDN du reverse proxy frontal, exposé publiquement pour fournir le service OCSP (Authority Information Access - OCSP) :

```
ocsp.example.com
```
</li>

<li>FQDN du reverse proxy frontal, exposé publiquement pour distribuer la CRL (CRL Distribution Points - FullName) :

```
crl.example.com
```
Il faudra configurer le reverse proxy pour que les connexions aux URL valides et elles seulement soient transférées du FQDN de ce reverse proxy à l'URL de la CA qui délivrera la CRL, en liste blanche.
Les deux seules URL valides sont ```/crl``` et ```/1.0/crl```.
Pour l'exemple du FQDN ci-dessus, ```crl.example.com/crl``` et ```crl.example.com/1.0/crl```.
</li>


<li>FQDN du reverse proxy frontal, exposé publiquement pour distribuer des certificats racines et intermédiaires (Authority Information Access - CA Issuers) :

```
issuers.example.com
```
</li>
</ul>


Révocation de certificats
-------------------------

Pour révoquer un certificat, nous pouvons utiliser la commande "step ca revoke" (attention, pas "step-ca" mais bien "step ca") :

```
step ca revoke --reason "Raison de la revocation" --reasonCode "4" XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

en remplaçant les X par la fingerprint du certificat.
Nous devons alors authentifier la demande avec le mot de passe de la clé privée l'ayant signé.


Il est aussi possible de révoquer un certificat avec son fichier et sa clé privée, auquel cas aucun mot de passe n'est demandé.

```
step ca revoke --reason "Raison de la revocation" --reasonCode "4" --cert exemplecertificat.crt --key exemplecle.key
```

Il est important de justifier chaque révocation avec le paramètre ```--reasonCode``` (voir la [documentation](https://smallstep.com/docs/step-cli/reference/ca/revoke/#options)).
Nous utiliserons le plus souvent le reasonCode 4 ("superseded" - "remplacé") avec une description plus claire de la raison exacte dans le paramètre ```--reason```.


Dépendances
-----------

rôles:
<ul>
  <li>step-cli</li>
  <li>openssl</li>
</ul>

Le rôle openssl ne sert qu'à s'assurer de la présence du binaire OpenSSL sur la machine. Si un rôle relatif à openssl et son binaire sont déjà présents, celui-ci n'est pas nécessaire.


Exemple de playbook intégrant ce rôle
-------------------------------------

````{verbatim}
### PKI/IGC
- hosts:
    - ca_server
    - ra_servers
  roles:
    - step-ca
  tags:
    - igc
    - pki
- hosts:
    - va_servers
  roles:
    - openssl
    - nginx
  tags:
    - igc
    - pki
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

Jérôme MAURIN <jerome.maurin@eternilab.com>
Sylvain LEROY <sylvain.leroy@eternilab.com>
Dionys COLSON <dionys.colson@eternilab.com>
Maxime BREL <maxime.brel@eternilab.com>

https://www.eternilab.com
