#!/bin/sh

echo '=SSL CERTS START=============================================='
echo "Checking for SSL certificate variable SSL_CERT"
if [[ -z "${SSL_CERT}" ]]; then
  echo "Certificate environment variable not found self signed certificate"
  cp /etc/certs/selfsigned.cert.pem /etc/certs/webapp_ssl.crt
else
  echo "Certificate environment variable found"
  if [ ! -d /etc/certs ] ; then
    mkdir -p /etc/certs
  fi
  echo ${SSL_CERT} | base64 -d  > /etc/certs/webapp_ssl.crt
  echo "Created /etc/certs/webapp_ssl.crt"
  export $SSL_CERT=''
fi
echo "Checking for SSL key variable SSL_KEY"
if [[ -z "${SSL_KEY}" ]]; then
  echo "Key environment variable not found using self signed certificate"
  cp /etc/certs/selfsigned.key.pem /etc/certs/webapp_ssl.key
else
  echo "Key environment variable found"
  if [ ! -d /etc/certs ] ; then
    mkdir -p /etc/certs
  fi
  echo ${SSL_KEY} | base64 -d  > /etc/certs/webapp_ssl.key
  echo "Created /etc/certs/webapp_ssl.key"
  export $SSL_KEY=''
fi
echo '=SSL CERTS END================================================'

/opt/confd/bin/confd -onetime -backend env

exec "$@"