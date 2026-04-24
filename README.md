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

**Coolify não entendendo bind mount através de variáveis de ambiente**: Esse erro aparentemente ocorre somente com o coolify, onde um bind mount configurado usando variáveis de ambiente não é entendido pela ferramenta.
Para solucionar esse problema, utilize o caminho absoluto do host ao invés de variáveis de ambiente, por exemplo:

```yml
# ao invés de
volumes:
  - ${ALFRESCO_VOLUME_BASE_PATH}/keystore:/usr/local/tomcat/shared/classes/alfresco/extension/keystore:ro

# usar
volumes:
  - /opt/alfresco/keystore:/usr/local/tomcat/shared/classes/alfresco/extension/keystore:ro
```

Caso seja necessário validar se a keystore está com os binários corretos (o erro acima criava uma keystore mas com os binários incorretos), verifique através do comando, dentro do container do alfresco:

```bash
head -c 20 keystore | od -t x1
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

## Web Scripts

Página inicial: <host>/alfresco/service/index

## Comandos úteis

```bash
# para copiar os arquivos de uma máquina local para o servidor remoto
scp -r <dir_host> <usuario>@<ip-do-servidor>:<dir_remoto>
```

## Apache

Atualmente temos o apache como proxy na frente devido a aplicações legado. Para que o apache redirecione o trafégo que chega para o coolify quando não encontrar o serviço registrado no apache, essa configuração é necessário:

Crie um arquivo `/etc/apache2/sites-available/alfresco.conf` com o seguinte texto:

```conf
<VirtualHost *:80>
    ServerName ged.habeasdata.com.br

    # Redireciona tudo para HTTPS de forma permanente
    Redirect permanent / https://ged.habeasdata.com.br/
</VirtualHost>
```

```conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName ged.habeasdata.com.br

    AllowEncodedSlashes NoDecode

    # Passa o IP real do usuário - proxy
    ProxyPreserveHost On
    # Estas 3 linhas garantem que o IP real chegue ao proxy
    ProxyAddHeaders On
    RequestHeader set X-Forwarded-For %{REMOTE_ADDR}s
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    # Garante que o IP chegue corretamente
    RequestHeader set X-Real-IP %{REMOTE_ADDR}s

    ProxyPassReverseCookiePath / /
    Header edit Location ^http:// https://

    # Redireciona o tráfego
    # O "nocanon" impede o Apache de decodificar o %2F para /
    ProxyPass / http://192.168.200.226:80/ nocanon
    ProxyPassReverse / http://192.168.200.226:80/

    ErrorLog ${APACHE_LOG_DIR}/ged-error.log
    CustomLog ${APACHE_LOG_DIR}/ged-access.log combined

SSLCertificateFile /etc/letsencrypt/live/ged.habeasdata.com.br/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/ged.habeasdata.com.br/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>
```

## Migrando do Apache para o Traefik

Quando migrarmos todas as aplicações para o traefik, precisamos alterar o seguinte no alfresco:

- no painel coolify da aplicação -> configuration -> advanced -> general -> habilite force HTTPS
- no painel coolify da aplicação -> configuration -> general -> alter o domínio de http://ged.habeasdata.com.br para https://ged.habeasdata.com.br
-
