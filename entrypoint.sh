#!/bin/sh
set -e

if [ -n "${KEYSTORE_PASSWORD_FILE}" ]; then
  keystorePassword=`cat $KEYSTORE_PASSWORD_FILE`
fi

if [ -n "${TOMCAT_CERT_PATH}" ]; then
  openssl pkcs12 -export -in $TOMCAT_CERT_PATH -inkey $TOMCAT_KEY_PATH -name $keystoreSSLKey -out tomcat.p12 -password pass:$keystorePassword
  keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore tomcat.p12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
fi

if [ -d "${CERT_IMPORT_DIRECTORY}" ]; then
  for c in $CERT_IMPORT_DIRECTORY/*.crt; do
    FILENAME="${c}"
    echo "Importing ${FILENAME}"
    keytool -importcert -noprompt -trustcacerts -file $FILENAME -alias $FILENAME -keystore /etc/ssl/certs/java/cacerts -storepass changeit -noprompt;
  done
fi

if [ -f "/launch-app.sh" ]; then
  /launch-app.sh
elif [ -f "/app.jar" ]; then
  java -Djava.security.egd=file:/dev/./urandom -jar -DkeystorePassword=$keystorePassword app.jar $@
else
  echo "No /launch-app.sh or /app.jar found. Exiting."
  exit 0
fi

exec env "$@"