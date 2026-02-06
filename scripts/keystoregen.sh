#!/bin/bash

# necessário utilizar o gerador de chaves do alfresco em: https://github.com/Alfresco/alfresco-ssl-generator

KEYSTORE_PASS=""

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
