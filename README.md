## Requisitos de hardware

- RAM: 8GB (Mínimo absoluto), 16GB (Recomendado).
- CPU: 4 Cores.
- Storage: SSD é altamente recomendado devido ao processo de indexação do Solr.

## Base de dados

Para criar a base de dados do repositório do alfresco, acesse o `psql` do postgres da seguinte forma:

```bash
psql -U <usuario> -d <database>
```

Após isso, execute as seguintes queries:

```sql
-- cria o usuário do alfresco
CREATE USER <usuario> WITH PASSWORD '<senha>';

-- cria a base de dados para ser utilizada pelo alfresco
CREATE DATABASE <db_name> WITH ENCODING 'UTF8' OWNER <usuario>;

-- concede as permissões necessárias para o usuário do alfresco
GRANT ALL PRIVILEGES ON DATABASE <db_name> TO <usuario>;
```

## Alfresco Repository

### Keystore

ATENÇÃO: A PERDA DA KEYSTORE RESULTA EM NÃO CONSEGUIR ACESSAR MAIS OS ARQUIVOS, uma vez que os mesmos estão criptografados e a keystore é a chave.

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
