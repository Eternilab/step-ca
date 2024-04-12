{
    "subject": {
	"country": "FR",
        "organization": "Un Monde Libre",
	"locality": "Paris",
	"province": "IDF",
	"commonName": {{ toJson .Subject.CommonName }}
    },
    "keyUsage": ["certSign", "crlSign"],
    "basicConstraints": {
        "isCA": true,
        "maxPathLen": 0
    },
    "IssuingCertificateURL": ["http://www.unmondelibre.fr/unmondelibre.fr-CA.der"]
}
