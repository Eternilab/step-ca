{
{{ range .SANs }}
  {{ if not (and (regexMatch ".*\\.unmondelibre\\.fr" .Value) (eq .Type "dns")) }}
    {{ fail "Not a *.unmondelibre.fr host" }}
  {{ end }}
{{ end }}
    "subject": {
        "commonName": {{ toJson .Subject.CommonName }}
    },
    "sans": {{ toJson .SANs }},
{{- if typeIs "*rsa.PublicKey" .Insecure.CR.PublicKey }}
    {{ if lt .Insecure.CR.PublicKey.Size 512 }}
        {{ fail "Key length must be at least 4096 bits" }}
    {{ end }}
    "keyUsage": ["keyEncipherment", "digitalSignature"],
{{- else }}
    "keyUsage": ["digitalSignature"],
{{- end }}
    "extKeyUsage": ["clientAuth"],
    "basicConstraints": {
        "isCA": false
    },
    "IssuingCertificateURL": ["http://www.unmondelibre.fr/unmondelibre.fr-C1-SubCA.der"]
}
