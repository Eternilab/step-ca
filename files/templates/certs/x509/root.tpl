{
    "subject": {
	"country": "FR",
        "organization": "Un Monde Libre",
	"locality": "Paris",
	"province": "IDF",
	"commonName": {{ toJson .Subject.CommonName }}
    },
    "issuer": {{ toJson .Subject }},
    "keyUsage": ["certSign", "crlSign"],
    "basicConstraints": {
        "isCA": true,
        "maxPathLen": 1
    }
}
