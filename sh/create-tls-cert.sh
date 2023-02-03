#!/bin/bash
# shellcheck disable=SC2029

# Required environment vars:
#   OU: The certificate 'OU' field
#   CN: The certificate common-name (typically a DNS name or email addr)
#   FILENAME: Basename for cert and key files. eg: FILENAME=foo: foo.key, foo.crt, foo.pem

# Optional environment vars:
#   DIRECTORY: Directory to store downloaded certs in. Defaults to current dir ('.')
#   CA_HOST: Defaults to 'cimt.getpantheon.com' (production CA). Use your onebox address to create a development/sandbox cert.
#   SANS: SubjectAltNames to add to the cert. The CN will automatically be added to the SAN list so you don't need to add it.
#         The format is OpenSSL's SAN format documented here: https://www.openssl.org/docs/man1.0.2/apps/x509v3_config.html (Subject Alt Name section)
#         Example - 1 DNS name, 1 ipv4 address, 1 ipv6 address:
#           SANS="DNS:foo;IP:10.0.0.1:IP:2001::1"
#
#   CASSANDRA: "true" to generate a Java Keystore (.ks file) that Cassandra requires
#   CASSANDRA_CA_CERT_FILE: Full path to the CA file, used to generate the certs, when CASSANDRA=yes
#   CASSANDRA_CA_KEY_FILE: Full path to the key file, used to generate the certs, when CASSANDRA=yes
#
#   Notes on Cassandra flags:
#   - If USE_ONEBOX_CA=true and CASSANDRA=true, then the CA `onebox_cassandra_ca.{crt,key} will be used.
#   - Currently Valhalla Cassandra shares a CA, in future we would like to have each one use a separate CA.
#
# Usage examples:
#
#   - Create a certificate with CN=foo, OU=bar and no extra SANs (subjectAltNames) with filenames: mycert.key, mycert.crt, mycert.pem
#
#       CN=foo OU=bar FILENAME=mycert bash ./create-tls-cert.sh
#
#   - Add SubjectAltNames "foobar.com", and IP "10.0.0.1":
#
#       CN=foo OU=bar FILENAME=mycert SANS="DNS:foobar.com;IP:10.0.0.1" bash ./create-tls-cert.sh
#
#   - Issue a development certificate from a onebox (any onebox can be used, so use yours if you have one):
#
#       CA_HOST=onebox CN=foo OU=bar FILENAME=mycert bash ./create-tls-cert.sh
#
#   - Generate certs for use by Cassandra, using the Ygg CA (Valhalla make commands use this)
#
#       CN=valhalla OU=valhalla \
#       CASSANDRA=true \
#       CASSANDRA_CA_CERT_FILE=/etc/pantheon/yggdrasil_ca.crt \
#       CASSANDRA_CA_KEY_FILE=/etc/pantheon/yggdrasil_ca.key \
#       DIRECTORY=./devops/k8s/secrets/production/cassandra-certs \
#       FILENAME=cassandra \
#       bash ./create-tls-cert.sh

set -eou pipefail

CA_HOST="${CA_HOST:-cimt.getpantheon.com}"
DIRECTORY="${DIRECTORY:-.}"
FILENAME="${FILENAME:-}"
OU="${OU:-}"
CN="${CN:-}"
SANS="${SANS:-}"
USE_ONEBOX_CA="${USE_ONEBOX_CA:-false}"
CA_CERT_FILE="/etc/pantheon/ca.crt"
CA_KEY_FILE="/etc/pantheon/ca.key"
CASSANDRA="${CASSANDRA:-}"
CASSANDRA_CA_CERT_FILE="${CASSANDRA_CA_CERT_FILE:-}"
CASSANDRA_CA_KEY_FILE="${CASSANDRA_CA_KEY_FILE:-}"

if [[ "$USE_ONEBOX_CA" == "true" ]]; then
    CA_CERT_FILE="/etc/pantheon/onebox_ca.crt"
    CA_KEY_FILE="/etc/pantheon/onebox_ca.key"
    CASSANDRA_CA_CERT_FILE="/etc/pantheon/onebox_cassandra_ca.crt"
    CASSANDRA_CA_KEY_FILE="/etc/pantheon/onebox_cassandra_ca.key"
fi
if [[ "$CASSANDRA" == "true" ]]; then
    CA_CERT_FILE="${CASSANDRA_CA_CERT_FILE}"
    CA_KEY_FILE="${CASSANDRA_CA_KEY_FILE}"
fi

if [[ -z "$CA_HOST" ]] || [[ -z "$FILENAME" ]] || [[ -z "$OU" ]] || [[ -z "$CN" ]] || [[ -z "$CA_KEY_FILE" ]] || [[ -z "$CA_CERT_FILE" ]]; then
    echo "missing one or more required env vars: CA_HOST, FILENAME, OU, CN, CA_KEY_FILE, CA_CERT_FILE"
    exit 1
fi

main() {
    echo "Creating directory: $DIRECTORY"
    mkdir -p "${DIRECTORY}"

    echo "[INFO] SSH'ing to '$CA_HOST' to create MTLS certificate: CN=$CN, OU=$OU, FILENAME=$FILENAME, DIRECTORY=$DIRECTORY, SANS=$SANS, CA_CERT_FILE=$CA_CERT_FILE, CA_KEY_FILE=$CA_KEY_FILE"
    ssh "${CA_HOST}" "sudo pantheon pki.create_key:cn='$CN',ou='$OU',san=\"$SANS\",filename='$FILENAME',ca_key='$CA_KEY_FILE',ca_cert='$CA_CERT_FILE',directory='.',noninteractive=True" >/dev/null

    echo "[INFO] Downloading $CA_HOST:$FILENAME.{key,crt,pem}"
    scp "${CA_HOST}":"${FILENAME}".{key,crt,pem} "${DIRECTORY}/" >/dev/null
    ssh "${CA_HOST}" "sudo rm -f -- ${FILENAME}.{key,crt,pem}" >/dev/null

    echo "[INFO] Downloaded MTLS certificate files (Run 'openssl x509 -text -noout -in $FILENAME.pem' to view certificate):"

    if [[ -n "$CASSANDRA" ]]; then
        echo "[INFO] creating java keystore"
        CA_FILE_OUT="cassandra_ca.crt"
        scp "${CA_HOST}:${CA_CERT_FILE}" "$DIRECTORY/${CA_FILE_OUT}" >/dev/null
        openssl pkcs12 \
                -chain -export -password pass:pantheon \
                -CAfile "$DIRECTORY/${CA_FILE_OUT}" \
                -in "$DIRECTORY/${FILENAME}.pem" \
                -out "$DIRECTORY/${FILENAME}.p12" \
                -name cassandra
        keytool -importkeystore \
                -srckeystore "$DIRECTORY/${FILENAME}.p12" \
                -destkeystore "$DIRECTORY/${FILENAME}.ks" \
                -srcstoretype pkcs12 \
                -deststoretype JKS \
                -srcstorepass pantheon \
                -storepass pantheon
        keytool -importcert \
                -alias ca \
                -file "$DIRECTORY/${CA_FILE_OUT}" \
                -keystore "$DIRECTORY/${FILENAME}.ks" \
                -trustcacerts \
                -noprompt \
                -storepass pantheon
    fi
    ls -l "$DIRECTORY/$FILENAME"*
}
main "$@"
