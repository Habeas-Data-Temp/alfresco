#!/bin/bash

# necessário utilizar o gerador de chaves do alfresco em: https://github.com/Alfresco/alfresco-ssl-generator

KEYSTORE_PASS=""

# gera uma keystore PKCS12
./run.sh \
	-alfrescoversion "community" \
	-keysize 4096 \
	-keystorepass $KEYSTORE_PASS \
	-truststorepass $KEYSTORE_PASS \
	-encstorepass $KEYSTORE_PASS \
	-encmetadatapass $KEYSTORE_PASS \
	-cacertdname "/C=BR/ST=MG/L=Betim/O=Habeas Data Soluções em Informática LTDA./OU=TI/CN=Habeas Data Alfresco" \
	-repocertdname "/C=BR/ST=MG/L=Betim/O=Habeas Data Soluções em Informática LTDA./OU=TI/CN=Habeas Data Alfresco Repository" \
	-solrcertdname "/C=BR/ST=MG/L=Betim/O=Habeas Data Soluções em Informática LTDA./OU=TI/CN=Habeas Data Alfresco Repository Client" \
	-browsercertdname "/C=BR/ST=MG/L=Betim/O=Habeas Data Soluções em Informática LTDA./OU=TI/CN=Habeas Data Alfresco Browser Client"

keytool -genkeypair \
    -alias metadata \
    -keyalg RSA \
    -keysize 4096 \
    -sigalg SHA256withRSA \
    -validity 3650 \
    -storetype PKCS12 \
    -keystore keystore \
    -storepass teste \
    -keypass teste \
    -dname "CN=Habeas Data Alfresco Repository, OU=TI, O=Habeas Data Soluções em Informática LTDA., L=Betim, ST=MG, C=BR"

# para validar se foi gerada corretamente
keytool -list -v -keystore ./keystore -storetype PKCS12
