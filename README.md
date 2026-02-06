## Alfresco Repository

### Keystore

Para configurar a keystore, usamos volumes mapeados entre o host e o volume do container. Dessa forma, coloque o arquivo `keystore` no mesmo diretório configurado pela variável de ambiente `$KEYSTORE_HOST_PATH`.

Caso a `keystore` seja do tipo `PKCS12`, utilize as seguintes opções:

```docker-compose
JAVA_TOOL_OPTIONS: >-
  -Dencryption.keystore.type=PKCS12
  -Dencryption.keystore.location=/usr/local/tomcat/shared/classes/alfresco/extension/keystore/keystore
  -Dmetadata-keystore.password=${KEYSTORE_PASSWORD}
  -Dmetadata-keystore.aliases=${KEYSTORE_ALIAS}
  -Dmetadata-keystore.metadata.password=${KEYSTORE_KEYPASSWORD}
```

Caso seja do tipo `JCEKS`, utilize as seguintes opções:

```
JAVA_TOOL_OPTIONS: >-
  -Dencryption.keystore.type=JCEKS
  -Dencryption.cipherAlgorithm=DESede/CBC/PKCS5Padding
  -Dencryption.keyAlgorithm=DESede
  -Dencryption.keystore.location=/usr/local/tomcat/shared/classes/alfresco/extension/keystore/keystore
  -Dmetadata-keystore.password=${KEYSTORE_PASSWORD}
  -Dmetadata-keystore.aliases=${KEYSTORE_ALIAS}
  -Dmetadata-keystore.metadata.password=${KEYSTORE_KEYPASSWORD}
  -Dmetadata-keystore.metadata.algorithm=DESede
```

#### Erros conhecidos

**Permissão do diretório**: Se ao executar o container, o mesmo não conseguir ler ou utilizar a keystore configurada, verifique se alterando as permissões do `host` o problema é resolvido.
Para isso, execute os seguintes comandos no diretório do host onde está a `keystore`:

```bash
# 999 é o ID do usuário do alfresco
sudo chown -R 999:999 <keystore_dir>

# pode ser necessário també alterar as permissões do diretório
sudo chmod -R 700 <keystore_dir>
```

## Solr6 (Search service)

#### Erros conhecidos

**solr host**: Caso o repositório do alfresco não consiga se comunicar com o serviço de pesquisa (solr6), verifique se o `host do solr` está definido com o mesmo nome do serviço do `docker-compose`. Caso tenha definido um nome para o container, utilize o nome definido. Por exemplo:

```docker-compose
environment:
...
  SOLR_SOLR_HOST: "alfresco_search"
...
```

## Comandos úteis

```bash
# para copiar os arquivos de uma máquina local para o servidor remoto
scp -r <dir_or_file> <usuario>@<ip-do-servidor>:<dir_remoto>
```
