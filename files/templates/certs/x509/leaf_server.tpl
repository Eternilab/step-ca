{
{{ range .SANs }}
  {{ if not (or (and (regexMatch ".*\\.unmondelibre\\.fr" .Value) (eq .Type "dns")) (and (regexMatch ".*eternilab\\.com" .Value) (eq .Type "dns"))) }}
    {{ fail "Not a *.unmondelibre.fr host or *.eternilab.com" }}
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
    "extKeyUsage": ["serverAuth"],
    "basicConstraints": {
        "isCA": false
    },
    "IssuingCertificateURL": ["http://www.unmondelibre.fr/unmondelibre.fr-S1-SubCA.der"]
}
