## 

## 

## PASOS REALIZADOS PARA LA CONFIGURACIÓN DEL SERVIDOR DE DESARROLLO MINSAL DTIC

#### CREANDO UN NUEVO USUARIO Y AGREGANDOLO AL GRUPO SUDO

* Creamos un nuevo usuario

  ```
  # sudo adduser minsal
  Adding user `minsal' ...
  Adding new group `minsal' (1001) ...
  Adding new user `minsal' (1001) with group `minsal' ...
  Creating home directory `/home/minsal' ...
  Copying files from `/etc/skel' ...
  New password:m1ns4ldt1c
  Retype new password:m1ns4ldt1c
  passwd: password updated successfully
  Changing the user information for minsal
  Enter the new value, or press ENTER for the default
          Full Name []: MINSAL DTIC
          Room Number []: 7029
          Work Phone []: 25917029
          Home Phone []:
          Other []:
  Is the information correct? [Y/n] Y
  
  
  
  
  
  
  
  
  ```
* Agregamos el usuario al grupo sudo

```
# sudo usermod -aG sudo minsal
```

Con esto ya se puede usar el usuario minsal con privilegios de root anteponiendo el comando sudo a lo que se necesite ejecutar, por ejemplo listar el directorio /root que normalmente solo lo puede hacer el usuario root:

```
# su minsal
# sudo ls -la /root
total 28
drwx------  5 root root 4096 Oct  7 15:58 .
drwxr-xr-x 19 root root 4096 Sep 17 20:25 ..
-rw-r--r--  1 root root 3106 Dec  5  2019 .bashrc
drwxr-xr-x  3 root root 4096 Oct  7 15:58 .local
-rw-r--r--  1 root root  161 Dec  5  2019 .profile
drwx------  2 root root 4096 Sep 17 20:25 .ssh
drwxr-xr-x  4 root root 4096 Sep 17 20:25 snap
```

#### INSTALANDO DOCKER Y DOCKER-COMPOSE

* **Instalando DOCKER**

Para ello ejecutar el siguiente comando:

```
# sudo curl -sS https://get.docker.com/ | sh
```

Para hacer el uso de docker un poco más fácil sin estar siempre anteponiendo el comando sudo, ejecutar lo siguiente:

```
# sudo systemctl enable docker
# sudo groupadd docker
# sudo usermod -aG docker $USER
```

Salimos de la sesión y al volver a entrar ya podemos usar los comandos docker sin anteponer siempre sudo.

* **Instalando DOCKER-COMPOSER**

Para instalar docker-composer ejecutar los siguientes comandos

```
# sudo -i
# curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose
```

* **Agregando registros A al dominio**

Es importante preparar el dominio respectivo para que reconozca los servicios que estarán en el servidor.

Para ello debemos de colocar por ejemplo los siguientes registros tipo A:

```
    TIPO          NOMBRE                  DIRECCION IPV4         TTL
      A        docker.minsal               3.133.103.43       Automático
      A        mysql.minsal                3.133.103.43       Automático
```

Hay que tener en cuenta que el nombre que se elija queda a opción del administrador como nombrarlo, lo que sí es necesario comprender que ese nombre (alias) se apegaría a dns propietario por ejemplo:

docker.minsal.salud.gob.sv y mysql.minsal.salud.gob.sv respectivamente.

Ahora que ya tenemos los alias de los subdominios configurados es necesario proseguir a elaborar la pila de servicios que desplegará el docker compose.

* **Configurando docker-compose**

Usando el usuario minsal:

```
# su minsal
```

Nos ubicamos en la carpeta del usuario:

```
# cd ~
```

Creamos una carpeta que contendrá todo el contenido llamada "proxy":

```
# sudo mkdir proxy
# cd proxy
```

Creamos nuestro archivo docker-compose.yml y lo editamos con nano

```
# nano docker-compose.yml
```

Colocamos la siguiente estructura básica del archivo:

```
version: '2'

services:

volumes:

networks:
```

Es importante mencionar que la estructura de dicho archivo se base exclusivamente por sangrías (Muy importante).

A continuación vamos a estructurar el nginx proxy y el contenedor que genera los certificados automáticamente.

La estructura es la siguiente:

```
 proxy:
  image: jwilder/nginx-proxy
  container_name: proxy
  restart: unless-stopped
  labels:
   com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
  volumes:
   - /var/run/docker.sock:/tmp/docker.sock:ro
   - certs:/etc/nginx/certs:rw
   - vhost.d:/etc/nginx/vhost.d
   - html:/usr/share/nginx/html
   - ./uploadsize.conf:/etc/nginx/conf.d/uploadsize.conf:ro
  ports:
   - "80:80"
   - "443:443"
  networks:
   - "default"
   - "proxy-tier"

 proxy-letsencrypt:
  image: jrcs/letsencrypt-nginx-proxy-companion
  container_name: letsencrypt
  restart: unless-stopped
  environment:
   - NGINX_PROXY_CONTAINER=proxy
  volumes:
   - /var/run/docker.sock:/var/run/docker.sock:ro
  volumes_from:
   - "proxy"
  depends_on:
   - "proxy"
  networks:
   - "default"
   - "proxy-tier"
```

Aquí se puede observar 2 servicios: proxy y proxy-letsencrypt, agregando todo esto dentro del aparatado services el archivo final quedaría así:

```
version: '2'

services:
 proxy:
  image: jwilder/nginx-proxy
  container_name: proxy
  restart: unless-stopped
  labels:
   com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
  volumes:
   - /var/run/docker.sock:/tmp/docker.sock:ro
   - certs:/etc/nginx/certs:rw
   - vhost.d:/etc/nginx/vhost.d
   - html:/usr/share/nginx/html
   - ./uploadsize.conf:/etc/nginx/conf.d/uploadsize.conf:ro
  ports:
   - "80:80"
   - "443:443"
  networks:
   - "default"
   - "proxy-tier"

 proxy-letsencrypt:
  image: jrcs/letsencrypt-nginx-proxy-companion
  container_name: letsencrypt
  restart: unless-stopped
  environment:
   - NGINX_PROXY_CONTAINER=proxy
  volumes:
   - /var/run/docker.sock:/var/run/docker.sock:ro
  volumes_from:
   - "proxy"
  depends_on:
   - "proxy"
  networks:
   - "default"
   - "proxy-tier"

volumes:
 certs:
 vhost.d:
 html:
   
networks:
 proxy-tier:
```

Esta es la estructura básica de nuestra pila de servicios; a continuación agregaremos portainer para manejar todos los contenedores desde una interfaz web...

```
 portainer:
  image: portainer/portainer
  container_name: portainer
  restart: always
  environment:
   - VIRTUAL_HOST=docker.minsal.salud.gob.sv
   - LETSENCRYPT_HOST=docker.minsal.salud.gob.sv
   - LETSENCRYPT_EMAIL=ever.murcia@salud.gob.sv
  volumes:
   - ./portainer/:/data
   - /var/run/docker.sock:/var/run/docker.sock
  ports:
   - "9000:9000"
```

Agregándolo a nuestro archivo docker-composer.yml quedaría así:

```
version: '2'

services:
 proxy:
  image: jwilder/nginx-proxy
  container_name: proxy
  restart: unless-stopped
  labels:
   com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
  volumes:
   - /var/run/docker.sock:/tmp/docker.sock:ro
   - certs:/etc/nginx/certs:rw
   - vhost.d:/etc/nginx/vhost.d
   - html:/usr/share/nginx/html
   - ./uploadsize.conf:/etc/nginx/conf.d/uploadsize.conf:ro
  ports:
   - "80:80"
   - "443:443"
  networks:
   - "default"
   - "proxy-tier"

 proxy-letsencrypt:
  image: jrcs/letsencrypt-nginx-proxy-companion
  container_name: letsencrypt
  restart: unless-stopped
  environment:
   - NGINX_PROXY_CONTAINER=proxy
  volumes:
   - /var/run/docker.sock:/var/run/docker.sock:ro
  volumes_from:
   - "proxy"
  depends_on:
   - "proxy"
  networks:
   - "default"
   - "proxy-tier"

 portainer:
  image: portainer/portainer
  container_name: portainer
  restart: always
  environment:
   - VIRTUAL_HOST=docker.minsal.salud.gob.sv
   - LETSENCRYPT_HOST=docker.minsal.salud.gob.sv
   - LETSENCRYPT_EMAIL=ever.murcia@salud.gob.sv
  volumes:
   - ./portainer/:/data
   - /var/run/docker.sock:/var/run/docker.sock
  ports:
   - "9000:9000"

volumes:
 certs:
 vhost.d:
 html:
   
networks:
 proxy-tier:
```

Cabe destacar que las variables de entorno VIRTUAL_HOST, LETSENCRYPT_HOST y LETSENCRYPT_EMAIL son requeridas y se deben de llenar con la info del subdominio antes creado y destinado para este fin.

A continuación guardamos el archivo con CTRL+O y luego CTRL+X, y desde la misma carpeta /home/minsal/proxy/ ejecutamos los siguiente para levantar el servicio:

```
# docker-composer up -d
```

Descargará las imágenes y cargará los contenedores según como estén establecidos en el archivo docker-composer.yml

Enseguida podemos ir al navegador y entrar a l url: **https://docker.minsal.salud.gob.sv** y podemos visualizar el contenido de portainer donde tenemos que configurarlo por ser primera vez que ingresamos a él.

Si necesitamos por ejemplo agregar mas servicios al servidor como el mysql, debemos agregar las siguientes dos estructuras de contenedor:

```
 dbservice:
  image: mysql:5.7
  container_name: mysql_service
  restart: always
  environment:
   MYSQL_ROOT_PASSWORD: m1ns4ldt1c
   MYSQL_DATABASE: minsaltest
   MYSQL_USER: minsal
   MYSQL_PASSWORD: m1ns4ldt1c
  volumes:
   - ./services/mysql_service:/var/lib/mysql
  ports:
   - "3306:3306"
  networks:
   - proxy-tier
   - default

 phpmyadminservice:
  depends_on:
   - dbservice
  image: phpmyadmin/phpmyadmin
  container_name: phpmyadmin_service
  restart: always
  ports:
   - "8081:80"
  environment:
   LETSENCRYPT_EMAIL: ever.murcia@salud.gob.sv
   LETSENCRYPT_HOST: mysql.minsal.sigenesis.com
   VIRTUAL_HOST: mysql.minsal.sigenesis.com
   PMA_HOST: dbservice
   MYSQL_ROOT_PASSWORD: m1ns4ldt1c
  networks:
   - proxy-tier
   - default
```

Nuestro archivo final quedaría de la siguiente manera:

```
version: '2'

services:
 proxy:
  image: jwilder/nginx-proxy
  container_name: proxy
  restart: unless-stopped
  labels:
   com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
  volumes:
   - /var/run/docker.sock:/tmp/docker.sock:ro
   - certs:/etc/nginx/certs:rw
   - vhost.d:/etc/nginx/vhost.d
   - html:/usr/share/nginx/html
   - ./uploadsize.conf:/etc/nginx/conf.d/uploadsize.conf:ro
  ports:
   - "80:80"
   - "443:443"
  networks:
   - "default"
   - "proxy-tier"

 proxy-letsencrypt:
  image: jrcs/letsencrypt-nginx-proxy-companion
  container_name: letsencrypt
  restart: unless-stopped
  environment:
   - NGINX_PROXY_CONTAINER=proxy
  volumes:
   - /var/run/docker.sock:/var/run/docker.sock:ro
  volumes_from:
   - "proxy"
  depends_on:
   - "proxy"
  networks:
   - "default"
   - "proxy-tier"

 portainer:
  image: portainer/portainer
  container_name: portainer
  restart: always
  environment:
   - VIRTUAL_HOST=docker.minsal.salud.gob.sv
   - LETSENCRYPT_HOST=docker.minsal.salud.gob.sv
   - LETSENCRYPT_EMAIL=ever.murcia@salud.gob.sv
  volumes:
   - ./portainer/:/data
   - /var/run/docker.sock:/var/run/docker.sock
  ports:
   - "9000:9000"

 dbservice:
  image: mysql:5.7
  container_name: mysql_service
  restart: always
  environment:
   MYSQL_ROOT_PASSWORD: m1ns4ldt1c
   MYSQL_DATABASE: minsaltest
   MYSQL_USER: minsal
   MYSQL_PASSWORD: m1ns4ldt1c
  volumes:
   - ./services/mysql_service:/var/lib/mysql
  ports:
   - "3306:3306"
  networks:
   - proxy-tier
   - default

 phpmyadminservice:
  depends_on:
   - dbservice
  image: phpmyadmin/phpmyadmin
  container_name: phpmyadmin_service
  restart: always
  ports:
   - "8081:80"
  environment:
   LETSENCRYPT_EMAIL: ever.murcia@salud.gob.sv
   LETSENCRYPT_HOST: mysql.minsal.sigenesis.com
   VIRTUAL_HOST: mysql.minsal.sigenesis.com
   PMA_HOST: dbservice
   MYSQL_ROOT_PASSWORD: m1ns4ldt1c
  networks:
   - proxy-tier
   - default

volumes:
 certs:
 vhost.d:
 html:
   
networks:
 proxy-tier:
```

Guardamos con CTRL+O y luego con CTRL+X y volvemos a ejecutar:

```
# docker-compose up -d
```

Vamos a notar una pequeña diferencia que los contenedores anteriores no van a sufrir ningún cambio, solamente descargará las imágenes nuevas y las montará y ejecutará.

Podemos acceder a nuestro mysql desde la url: **https://mysql.minsal.salud.gob.sv**

Las credenciales son las mismas que se colocaron en el archivo yml.

* **PARA HABILITAR CI/CD**

Primero entrar al contenedor con:

```
$ docker exec -it backend_namecontenedor bash
```

Instalar el paquete cron

```
# apt-get install cron
```

```
# service cron start
[ ok ] Starting periodic command scheduler: cron.
```

Comprobar que el servicio este corriendo

```
# service cron status
[ ok ] cron is running.
```

abrir el crontab :

```
$ crontab -e
```

agregar la siguiente entrada:

```
* * * * * cd /var/www/html/ && git pull origin master
```

Para ejecutar php artisan swagger-lume:generate es necesario agregar la siguiente entrada (En el caso de estar usando swagger), esto para que la documentación de swagger se actualize automaticamente:

```
* * * * * /usr/local/bin/php /var/www/html/artisan swagger-lume:generate
```

Antes debe de asegurarse de que github.com tenga la llave publica agregada a la lista de llaves.

# INSTALANDO UN BACKEND

Para ello vamos a tomar en cuenta el siguiente repositorio en la rama jwt_init:

<https://github.com/MINSAL-Proyectos/backend-base/tree/jwt_init>

**CREANDO IMAGEN DOCKER DE PHP7.3**

Para esto usaremos el dockerfile de dtic, estructura siguiente:

```
FROM php:7.3-apache-buster
LABEL maintainer "ever.murcia@salud.gob.sv"

RUN cp /dev/null /etc/apt/sources.list \
    && echo "deb http://debian.salud.gob.sv/debian/ buster main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://debian.salud.gob.sv/debian/ buster main contrib non-free" >> /etc/apt/sources.list \
    && echo "" >> /etc/apt/sources.list \
    && echo "deb http://debian.salud.gob.sv/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://debian.salud.gob.sv/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "" >> /etc/apt/sources.list \
    && echo "deb http://debian.salud.gob.sv/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://debian.salud.gob.sv/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list

#Instalando Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.overload_var_dump=On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache \
    && echo "opcache.file_cache = /var/www/html/.opcache" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

#Instalando apc
RUN printf "\n" | pecl install apcu \
    && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

# Instalando Paquetes faltantes
RUN apt-get update \
    && apt-get install -y nano zip libzip-dev libpq-dev zlib1g-dev libicu-dev g++ libxml2-dev memcached libmemcached-dev \
    wkhtmltopdf freetds-bin freetds-common wget lsb-release gnupg libpng-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && docker-php-ext-install intl mbstring xml gd \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip

# Instalando mysqli
RUN docker-php-ext-install mysqli pdo_mysql

# COPY php.ini /usr/local/etc/php/

# Instalando memcached
RUN pecl install memcached \
    && docker-php-ext-enable memcached

# Instalando Couchbase lib
# RUN wget http://packages.couchbase.com/ubuntu/couchbase.key \
#    && apt-key add couchbase.key \
#    && echo "deb http://packages.couchbase.com/ubuntu buster buster/main" > /etc/apt/sources.list.d/couchbase.list \
#    && apt update \
#    && apt-get install -y libcouchbase-dev libcouchbase2-bin build-essential \
#    && pecl install couchbase \
#    && docker-php-ext-enable couchbase

#Instalando Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"


# ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite
RUN a2enmod headers
```

**Creación de la Imagen**

Esto debe de ejecutarse en el lugar donde se encuentra el archivo DockerFile

```
docker build -t php:7.3-minsal .
```

Consultamos las imágenes disponibles con:

```
docker images
```

**Creamos en cloudflare el subdominio:**

api-backend-base.minsal.sigenesis.com

Tipo: A; Nombre: api-backend-base.minsal; Contenido: 172.93.51.59 (Mi servidor)

**Agregamos al archivo docker-compose.yml el siguiente contenido:**

```
# site: backend-base minsal inicio:
# inicio: 15-03-2022
 backend_base:
  image: php:7.3-minsal
  container_name: backend_base_lumen
  restart: always
  environment:
   - VIRTUAL_HOST=api-backend-base.minsal.sigenesis.com
   - LETSENCRYPT_HOST=api-backend-base.minsal.sigenesis.com
   - LETSENCRYPT_EMAIL=ever.murcia@salud.gob.sv
  volumes:
   - ./services/minsal/backend-base/html:/var/www/html
   - ./services/minsal/backend-base/apache_log:/var/log/apache2
  ports:
   - "7002:80"
   - "7003:8000"
```

Si necesitamos usar swagger es necesario utilizar el el apratado environment lo siguiente:

```
- HTTPS_METHOD=noredirect
```

Guardamos y ejecutamos: docker-compose up -d

Ingresamos al contenedor con:

```
docker exec -it backend_base_lumen bash
```

Luego actualizamos con:

```
apt-get update
```

Instalamos GIT con:

```
apt-get install git
```

**Agregando la llave pública a GitHub**

Los pasos y documentación del proceso se encuentra en:

> <https://wiki.salud.gob.sv/wiki/Configurar>*un*proyecto*con*Git

Moverse al directorio home del usuario:

```
cd ~
```

Verificamos si ya está creada la carpeta .ssh (Esta carpeta contiene las llaves publica y privada)

```
ls .ssh
```

Si da error *ls: cannot access '.ssh': No such file or directory.* Esto es porque no está creada la carpeta y por lo tanto las llaves públicas privada tampoco. Proseguimos a crearlas con:

```
ssh-keygen -t rsa
```

Darle "Enter" a todo lo que pide para dejar la info por defecto.

Al terminar el proceso y hacemos nuevamente ls .ssh nos aparecerán dos archivos: id_\*rsa y id_\*rsa.pub

Usaremos el archivo id_rsa.pub, lo abrimos con:

```
nano id_rsa.pub
```

Copiamos el contenido completo, abrimos nuestra cuenta de github y en settings Apartado **SSH and GPG keys** agregamos una nueva key, pegamos absolutamente todo lo que contenía el archivo y listo.

Ya con esto podemos clonar directo del repositorio.

**REPARANDO EL VIRTUALHOST QUE TRAE POR DEFECTO:**

```
nano /etc/apache2/sites-available/000-default.conf
```

Colocamos el siguiente contenido:

```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/public
        DirectoryIndex index.php
        <Directory /var/www/html/public>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Require all granted
            Header set Access-Control-Allow-Origin "*"
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/sis-error.log
        LogLevel warn
        CustomLog ${APACHE_LOG_DIR}/sis-access.log combined
</VirtualHost>
```

Reiniciamos el apache con:

```
 /etc/init.d/apache2 restart
```

**CLONANDO EL PROYECTO**

Debemos de estar en la carpeta:

```
cd /var/www/html/
```

Para clonar ejecutamos lo siguiente:

```
git clone git@github.com:MINSAL-Proyectos/backend-base.git .
```

Creamos el archivo .env en la raiz con:

```
nano .env
```

Agregamos el siguiente contenido:

```
APP_NAME=Lumen
APP_ENV=production
APP_KEY=base64:CVu+vzhWYIRk5VqZw1Cbw+G8jw+ghq6iuE6JrQ9vtyM=
APP_DEBUG=false
APP_URL=http://localhost
APP_TIMEZONE=UTC

LOG_CHANNEL=stack
LOG_SLACK_WEBHOOK_URL=

DB_CONNECTION=mysql
DB_HOST=mysql.dev.salud.gob.sv
DB_PORT=3306
DB_HOST_READ=mysql.dev.salud.gob.sv
DB_PORT_READ=3306
DB_DATABASE=minsaltest
DB_USERNAME=minsal_farid
DB_PASSWORD=dvaBzFWxaGOosukK

CACHE_DRIVER=file
QUEUE_CONNECTION=sync

USE_RECAPTCHA=true

FASE_ACTUAL=1
APP_TIMEZONE=America/El_Salvador

X_IMG_URL=http://img.minsal.qualium.net/

PAIS=SV

SMS_USUARIO=Minsal
SMS_CLAVE=y512f2$
```

Para instalar los vendors ejecutamos lo siguiente:

```
composer install
```

Agregamos unas acl, para ello instalamos el paquete con el siguiente comando:

```
apt-get install acl
```

Ejecutamos lo siguiente luego de la instalación:

```
setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx storage/logs

setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx storage/logs
```

Con lo de swagger es necesario agregar permisos 777 a la carpeta /var/www/html/storage:

```
chmod -R 777 /var/www/html/storage
```

Cargamos la url (api-backend-base.minsal.sigenesis.com) y ya vamos a poder observar el mensaje:

API OK.

## CONECTANDOSE POR MEDIO DE TUNNEL A UNA DB AMAZONE

Es necesario tener corriendo ya el contenedor donde hay que realizar el tunel.

Además es de poseer el archivo .pem (llave para conectarse al tunnel), debe de ser en ese formato (.pem), si es proporcionado en otro formato necesitamos convertirlo, pero ello usamos el PuttyGen, hay una guía que explica del proceso en:

<https://aws.amazon.com/es/premiumsupport/knowledge-center/ec2-ppk-pem-conversion/>

Teniendo el insumo anterior (archivo.pem) es necesario ubicarlo en el contenedor, lo guardaremos en: /root/.ssh/archivo.pem

También necesitamos la información de el acceso a la base y al tunnel que queremos establecer, ejemplo:

```
BASE-RNPN-postgresql
host-DB: database-rnpn.cluster-ro-c6c8s2memz3g.us-east-1.rds.amazonaws.com
User: dgii_user
Pass: 8p?#paqpcRpX7@B$SoCs
DB: produccion
SCHEMA: soporte


Info para Tunel
host: 54.166.254.248
user: ubuntu
key: archivo.pem
```

A continuación es necesario instalar screen y autossh en el contenedor con:

```
# apt-get install screen

# apt-get install autossh
```

Iniciamos una nueva sesión en screen con: screen -S nombre-de-sesión

```
# screen -S tunnel-ejemplo
```

*Nota: Esto abrirá una terminal nueva que no se cerrará y se mantendrá ejecutándose en segundo plano hasta salir con **exit**, si necesitamos salir de dicha terminal sin que se cierre la sesión presionamos **ctrl+a+d***

Estando dentro de la nueva terminal crearemos el tunnel con:

```
# cd /var/www/html/

# autossh -4 -i /root/.ssh/archivo.pem ubuntu@54.166.254.248 -L 5433:database-rnpn.cluster-ro-c6c8s2memz3g.us-east-1.rds.amazonaws.com:5432
```

*Nota: Creación de tunnel información:* <https://support.cloud.engineyard.com/hc/en-us/articles/205408088-Access-Your-Database-Remotely-Through-an-SSH-Tunnel>

Si no hay problema con el tunnel iniciará sesión ssh en el servidor de destino, este debe de quedar así, debemos presionar en seguida **ctrl+a+d** para salir de la sesión sin destruirla.

Para regresar a la sesión tunnel-ejemplo debemos averiguar el id que se le asignó, para ello ejecumos lo siguiente:

```
# screen -rd
There are several suitable screens on:
        1797.tunnel-ejemplo     (04/20/22 16:24:55)     (Detached)
        1790.pts-1.86996f2e6b16 (04/20/22 16:21:33)     (Detached)
Type "screen [-d] -r [pid.]tty.host" to resume one of them.
```

Podemos observar 2 sesiones pero la que nos interesa posee el id 1797, y para volver a él hacemos lo siguiente:

```
# screen -r 1797
```

Volviendo a ingresar a la terminal cerramos el tunnel autossh con **exit**, y destruimos la sesión de screen definitivamente con **exit** nuevamente.

*Nota: El uso completo de screen se puede encontrar en: <https://www.ochobitshacenunbyte.com/2019/04/24/que-es-y-como-funciona-el-comando-screen-en-linux/>*

---

Si mantenemos el tunnel abierto podemos utilizar la base de datos realizando la siguiente configuración en el archivo .env de lumen:

```
DB_CONNECTION=mysql
DB_HOST=mysql.dev.salud.gob.sv
DB_PORT=3306
DB_HOST_READ=mysql.dev.salud.gob.sv
DB_PORT_READ=3306
DB_DATABASE=dev_01
DB_USERNAME=minsal_farid
DB_PASSWORD=dvaBzFWxaGOosukK


DB_HOST_T=127.0.0.1
DB_PORT_T=5433
DB_DATABASE_T=produccion
DB_USERNAME_T=dgii_user
DB_PASSWORD_T="8p?#paqpcRpX7@B$SoCs"
DB_SCHEMA_T=soporte
```

*Nota: en la configuración anterior manejamos dos conexiones a base de datos diferentes, pero la que nos interesa con tunnel es la de postgres que es el segundo bloque, podemos verificar que el host que debemos usar ahora es localhost(127.0.0.1) esto porque hemos realizado el tunnel y la manejamos de manera local bajo el puerto 5433 según el tunnel que se abrió en el comando anterior.*

En el archivo /config/database.php debemos de realizar la siguiente configuración:

```
'connections' => [
        'mysql' => [
            'driver' => 'mysql',
            'read' => [
                'host' => env('DB_HOST_READ', env('DB_HOST', '127.0.0.1')),
                'port' => env('DB_PORT_READ', env('DB_PORT', 3306)),
            ],
            'write' => [
                'host' => env('DB_HOST', '127.0.0.1'),
                'port' => env('DB_PORT', 3306),
            ],
            'sticky' => true,
            'database' => env('DB_DATABASE', 'forge'),
            'username' => env('DB_USERNAME', 'forge'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'prefix' => env('DB_PREFIX', ''),
            'strict' => env('DB_STRICT_MODE', true),
            'engine' => env('DB_ENGINE', null),
            'timezone' => env('DB_TIMEZONE', '-06:00'),
            'wait_timeout'  =>  '30',
            'interactive_timeout'   => '30',
            'net_read_timeout'  => '30',
            'options'   => array(
                PDO::ATTR_EMULATE_PREPARES => true,
            ),
            'modes'  => [
                'IGNORE_SPACE,',
                'STRICT_TRANS_TABLES',
                ],
        ],

        'pgsql' => [
            'driver' => 'pgsql',
            'host' => env('DB_HOST_T', '127.0.0.1'),
            'port' => env('DB_PORT_T', 5432),
            'database' => env('DB_DATABASE_T', 'forge'),
            'username' => env('DB_USERNAME_T', 'forge'),
            'password' => env('DB_PASSWORD_T', ''),
            'charset' => env('DB_CHARSET_T', 'utf8'),
            'prefix' => env('DB_PREFIX_T', ''),
            'schema' => env('DB_SCHEMA_T', 'public'),
            'sslmode' => env('DB_SSL_MODE_T', 'prefer'),
        ]
    ],
```

*Nota: Observamos que tenemos dos conexiones, una por mysql y la otra por postgresql (pgsql).*

Mapeando una tabla de postgresql (rc_ruc) RcRuc.php

```
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RcRuc extends Model
{
    protected $table = 'rc_ruc';
}
```

*Nota: el modelo es exactamente como cualquier otro, no hay necesidad de definir a que conexion o base de datos es.*

Ejemplo de controlador para su uso:

```
<?php

namespace App\Http\Controllers;

use App\Helpers\Http;
use App\Helpers\LogHelper;
use App\Models\RcRuc;

use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Validator;

class DgiiController extends Controller
{
    public function getInformacion($documento){
        $datos = RcRuc::on('pgsql')->where('nit',$documento)->first();
        $response = [
            "estado"   => $datos ? "SI" : "NO",
            "nombre"   => $datos ? $datos->s_1ape_rasoc : "",

        ];
        return ($response);
    }
}
```

*Nota: para el uso de dicha base de datos es necesario especificar en elocuent a que conexion queremos consultar con el parametro **on** en la query.*

## CONECTANDOSE POR TUNNEL A BURO CREDITOS BASE DE DATOS Y HACIENDO API

Información de conexión enviada por Milton:

```
Archivo de certificado: cdntest.pem
host: 127.0.0.1
usuario: buro_ro
pass: jbQTVMJpVZv4dz8C
puerto: 3307
```

Se agregará al proyecto: <https://github.com/MINSAL-Proyectos/dev01-be>

Nos conectamos al servidor y corremos:

```
minsal@ip-172-31-31-11:~/proxy$ docker exec -it backend_dev_01 bash
```

> *Nota: Sin olvidar agregar el archivo de certificado pem a la ubicación de este contenedor: /root/.ssh/cdntest.pem*

Luego agregamos una nueva screen para dejar corriendo nuestro tunnel con:

```
# screen -S tunnel-buro-credito
```

Ya con la nueva screen ejecutamos el siguiente comando para establecer el tunnel

```
# autossh -4 -i /root/.ssh/cdntest.pem ubuntu@13.51.207.72 -L 3309:127.0.0.1:3307
```

Ahora salimos de la screen con **Ctrl + a + d**

#### MODIFICANDO ARCHIVO .env

Debemos agregar al archivo .env los datos de la nueva conexión, a continuación se presente dichos datos:

```
DB_HOST_M=127.0.0.1
DB_PORT_M=3309
DB_DATABASE_M=saldos
DB_USERNAME_M=buro_ro
DB_PASSWORD_M="jbQTVMJpVZv4dz8C"
```

> *Nota: Se puede notar que se agregó un sufijo a cada variable "_M" esto para que no se confunda el framework con lo que hay que colocar en el archivo config/database.php*

A continuación modificamos el archivo *config/database.php,* agregamos el siguiente contenido al arreglo ***connections***\*:\*

```
'mysql2' => [
            'driver' => 'mysql',
            'host' => env('DB_HOST_M', '127.0.0.1'),
            'port' => env('DB_PORT_M', 3307),
            'database' => env('DB_DATABASE_M', 'forge'),
            'username' => env('DB_USERNAME_M', 'forge'),
            'password' => env('DB_PASSWORD_M', ''),
            'charset' => env('DB_CHARSET_M', 'utf8mb4'),
            'collation' => env('DB_COLLATION_M', 'utf8mb4_unicode_ci'),
            'prefix' => env('DB_PREFIX_M', ''),
            'strict' => env('DB_STRICT_MODE_M', false),
            'engine' => env('DB_ENGINE_M', null),
            'timezone' => env('DB_TIMEZONE_M', '-06:00'),
            'wait_timeout'  =>  '30',
            'interactive_timeout'   => '30',
            'net_read_timeout'  => '30',
            'options'   => [
                \PDO::ATTR_EMULATE_PREPARES => true
            ]
        ],
```

Creamos el modelo de la tabla buro:

```
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Buro extends Model
{
    protected $table = 'buro';
}
```

Agregamos un nuevo controlador y una función de ejemplo (BuroController.php):

```
<?php
namespace App\Http\Controllers;
use App\Helpers\Http;
use App\Helpers\LogHelper;
use App\Models\Buro;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Validator;

class BuroController extends Controller
{
    public function getData(){
        $datos = Buro::on('mysql2')->where('identifier','04804796-5')->first();
        return $datos;
    }
}
```

Registramos la ruta:

```
$router->get('get/qualification',  'BuroController@getData');
```

# INSTALANDO UN FRONTEND EN VUE 3

Para ello vamos a ocupar el repositorio: <https://github.com/MINSAL-Academia/dnm-laboratorio-ui>

El contenido del archivo **docker-compose.yml** es:

```
#FRONTEND DNM (Direccion Nacional de Medicamento)
 frontend_dnm:
  image: php:7.3-dtic
  container_name: frontend_dnm
  restart: always
  environment:
   - VIRTUAL_HOST=dnm.minsal.dev
   - LETSENCRYPT_HOST=dnm.minsal.dev
   - LETSENCRYPT_EMAIL=ever.murcia@salud.gob.sv
  volumes:
   - ./services/dnm-fe/master/frontend/html:/var/www/html
   - ./services/dnm-fe/master/frontend/apache_log:/var/log/apache2
   - ./services/dnm-fe/master/frontend/code:/var/www/code
  ports:
   - "826:80"
   - "827:8000"
```

Lo guardamos y ejecutamos con ***docker-compose up -d***

Como esta es una instalación limpia de debian, necesitamos instalar lo siguiente:

```
> apt-get update
> apt-get install git
> apt-get install cron
> apt-get install nodejs
> apt-get install npm
> apt-get install rsync
```

> Instalar nvm: <https://www.delftstack.com/es/howto/node.js/update-node-js/>

Al instalar node js lo más seguro que instale una versión antigua, por ejemplo la 10, pero necesitamos trabajar con la version 16.17.0.

Para verficar la versión de node hacer lo siguiente: ***node --version***

---

Ahora cambiaremos la versión de node a la 16.17.0, para ello haremos uso de la app **nvm** (Node Version Manager), ejecutamos lo siguiente ya sea con wget o curl:

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

```
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

*Nota: Hay que salirse del contenedor y luego volver a entrar para que el comando **nvm** funcione.*

Listo ya tenemos nvm instalado, ahora actualizaremos la versión de node:

```
nvm install 16.17.0
```

Listo, ya está por defecto esa versión.

---

**Instalaremos los distintos logs** al sistema con:

```
apt-get install rsyslog
```

Configuramos el servicio de rsyslog para que también nos muestre los logs de los cronjobs, para ello modificamos el archivo: **nano /etc/rsyslog.conf**

Descomentamos la línea que hace referencia a los cron, específicamente dice:

```
#cron.*                          /var/log/cron.log
```

Ahora hechamos andar el servicio de logs con: **service rsyslog start**

Esto instalará todos los servicios de logs del sistema, pero los que vamos a hacer uso para monitorear lo que nos interesa son:

```
/var/log/cron.log
/var/log/syslog
```

Podemos estarlos monitoreando en tiempo real con:

```
tail -f /var/log/syslog
```

Hay un tercer log adicional que vamos a estar monitoreando pero lo definiremos en el cronjob.

Info sacada de: <https://linuxtect.com/where-is-cron-or-crontab-log/>

---

**Clonando el proyecto**

Previamente tuvimos que haber generado el archivo ***id_rsa.pub*** con ***ssh-keygen -t rsa***

Acordarse que el contenido de este archivo hay que registrarlo en github para que podamos clonar y usar git con ssh (Más arriba está detallado todo este proceso).

Clonamos el proyecto en la carpeta ***/var/www/code/*** , esto lo hacemos con:

```
cd /var/www/code/
git clone git@github.com:MINSAL-Academia/dnm-laboratorio-ui.git .
```

*Nota: acordarse que debe de estar seleccionada la opción de ssh en github para que tire la ruta con git no con url https*

Ahora que ya está clonado instalaremos todas las dependencias del proyecto, hacemos en la raiz (/var/www/code/):

```
npm install
```

Ahora importante que tambien en la raiz exista el archivo ***.htaccess*** con el siguiente contenido para que se pueda navegar en todas la rutas de la aplicación:

```
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

*Nota: este archivo lo integraremos posteriormente al despliegue automático tambien.*

Ahora debemos de generar la carpeta ***dist*** que es la que tiene el compilado del código y es la que debemos de publicar en la carpeta /var/www/html/, para ello generamos dist con:

```
npm run build
```

Ahora que ya tenemos el compilado en dist lo debemos de pasar a carpeta /var/www/html/ y también el archivo .htaccess con:

```
> cd /var/www/code/dist/
> cp * -r /var/www/html/
> cp /var/www/code/.htaccess /var/www/html/
```

Y listo ya está publicado el proyecto y todo funcionando bien.

---

#### Colocando despliegue continuo para frontend VUE 3

Creamos un archivo ***build.sh*** en la raiz del proyecto (si es que no lo trae ya el repositorio), debe de contener el siguiente contenido:

```
#!/bin/sh
echo " "
echo "*********************************************************************************"
echo "*********************************************************************************"
echo "---------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------"
echo "----------------------------INICIO DESPLIEGUE CONTINUO---------------------------"
echo "---------------------------------------------------------------------------------"
date
echo " "

echo "<<<<<<----------------SET: version de node 16.17.0 de trabajo--------------------"
# Load nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 16.17.0

#pwd paths
pwd
echo "<<<<<<-------------------------SET: Path de trabajo------------------------>>>>>>"
cd /var/www/code/
pwd

#puleando el codigo de git :'-)
echo "<<<<<<----------------BEGIN: Descargando cambios si las hay---------------->>>>>>"
git pull origin master

#instalando dependencias nuevas
echo "<<<<<<----------BEGIN: Instalando nuevas dependencias si las hay----------->>>>>>"
npm install

#compilando para produccion
echo "<<<<<<------------------BEGIN: Compilando para produccion------------------>>>>>>"
npm run build

#copiando archivo .htaccess a carpeta dist anteriomente creada
echo "<<<<<<-----------BEGIN:Compiando archivo .htaccess a carpeta dist---------->>>>>>"
cp /var/www/code/.htaccess /var/www/code/dist/
echo "OK!"

#sincronizando carpeta de /var/www/code/dist con carpeta /var/www/html/
echo "<<<<<<--------------BEGIN: Sincronizando carpeta dist con html------------->>>>>>"
rsync -avr /var/www/code/dist/ /var/www/html/ --delete
echo "Carpetas sincronizadas exitosamente!"
echo "Proceso finalizado!"

echo " "
date
echo "---------------------------------------------------------------------------------"
echo "-----------------------------FIN DESPLIEGUE CONTINUO-----------------------------"
echo "---------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------"
echo " "
```

*Nota: las 2 lineas donde contiene:* export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" [ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"

*Son super importantes ya que sin ella no se puede usar el nvm en el archivo .sh dentro del cron*

> Guia de rsync: <https://www.hostinger.es/tutoriales/rsync-linux>

Luego le concedemos permisos de ejecución con:

```
> chmod +x /var/www/code/build.sh
```

Ahora creamos un cron ejecutando:

```
> crontab -e
```

Colocamos el siguiente contenido:

```
* * * * * /var/www/code/build.sh >> /var/log/mycrons.log 2>&1
```

Guardamos el archivo con ***ctrl + x***

Esto ejecutará el archivo **build.sh** y el resultado de dicha ejecución lo depositará en el archivo: **/var/log/mycrons.log**

Por si aún no están activados los cronjob vamos a hacer lo siguiente:

```
> service cron start
```

Podemos monitorear el archivo en tiempo real con:

```
> tail -f /var/log/mycrons.log
```

# CONFIGURAR FECHA HORA ZONA HORARIA SERVIDOR UBUNTU DEBIAN

Para ello ejecutar en la terminal lo siguiente:

```
> sudo dpkg-reconfigure tzdata
```

Y seguir las indicaciones para configurar la zona horaria del servidor, elegir primero el área geográfica de las opciones que ahí se despliegan:

```
debconf: unable to initialize frontend: Dialog
debconf: (No usable dialog-like program is installed, so the dialog based frontend cannot be used. at /usr/share/perl5/Debconf/FrontEnd/Dialog.pm line 78.)
debconf: falling back to frontend: Readline
Configuring tzdata
------------------

Please select the geographic area in which you live. Subsequent configuration questions will narrow this down by presenting a list of cities, representing the
time zones in which they are located.

  1. Africa  2. America  3. Antarctica  4. Australia  5. Arctic  6. Asia  7. Atlantic  8. Europe  9. Indian  10. Pacific  11. SystemV  12. US  13. Etc
Geographic area: 2
```

Seleccionamos el área #2 ya que esa corresponde a América...

Ahora debemos de seleccionar el país del listado que se presenta:

```
Please select the city or region corresponding to your time zone.

  1. Adak                     27. Blanc-Sablon   53. Ensenada              79. Juneau               105. New_York                131. Santarem
  2. Anchorage                28. Boa_Vista      54. Fort_Nelson           80. Kentucky/Louisville  106. Nipigon                 132. Santiago
  3. Anguilla                 29. Bogota         55. Fortaleza             81. Kentucky/Monticello  107. Nome                    133. Santo_Domingo
  4. Antigua                  30. Boise          56. Glace_Bay             82. Kralendijk           108. Noronha                 134. Sao_Paulo
  5. Araguaina                31. Cambridge_Bay  57. Godthab               83. La_Paz               109. North_Dakota/Beulah     135. Scoresbysund
  6. Argentina/Buenos_Aires   32. Campo_Grande   58. Goose_Bay             84. Lima                 110. North_Dakota/Center     136. Shiprock
  7. Argentina/Catamarca      33. Cancun         59. Grand_Turk            85. Los_Angeles          111. North_Dakota/New_Salem  137. Sitka
  8. Argentina/Cordoba        34. Caracas        60. Grenada               86. Lower_Princes        112. Nuuk                    138. St_Barthelemy
  9. Argentina/Jujuy          35. Cayenne        61. Guadeloupe            87. Maceio               113. Ojinaga                 139. St_Johns
  10. Argentina/La_Rioja      36. Cayman         62. Guatemala             88. Managua              114. Panama                  140. St_Kitts
  11. Argentina/Mendoza       37. Chicago        63. Guayaquil             89. Manaus               115. Pangnirtung             141. St_Lucia
  12. Argentina/Rio_Gallegos  38. Chihuahua      64. Guyana                90. Marigot              116. Paramaribo              142. St_Thomas
  13. Argentina/Salta         39. Coral_Harbour  65. Halifax               91. Martinique           117. Phoenix                 143. St_Vincent
  14. Argentina/San_Juan      40. Costa_Rica     66. Havana                92. Matamoros            118. Port-au-Prince          144. Swift_Current
  15. Argentina/San_Luis      41. Creston        67. Hermosillo            93. Mazatlan             119. Port_of_Spain           145. Tegucigalpa
  16. Argentina/Tucuman       42. Cuiaba         68. Indiana/Indianapolis  94. Menominee            120. Porto_Acre              146. Thule
  17. Argentina/Ushuaia       43. Curacao        69. Indiana/Knox          95. Merida               121. Porto_Velho             147. Thunder_Bay
  18. Aruba                   44. Danmarkshavn   70. Indiana/Marengo       96. Metlakatla           122. Puerto_Rico             148. Tijuana
  19. Asuncion                45. Dawson         71. Indiana/Petersburg    97. Mexico_City          123. Punta_Arenas            149. Toronto
  20. Atikokan                46. Dawson_Creek   72. Indiana/Tell_City     98. Miquelon             124. Rainy_River             150. Tortola
  21. Atka                    47. Denver         73. Indiana/Vevay         99. Moncton              125. Rankin_Inlet            151. Vancouver
  22. Bahia                   48. Detroit        74. Indiana/Vincennes     100. Monterrey           126. Recife                  152. Virgin
  23. Bahia_Banderas          49. Dominica       75. Indiana/Winamac       101. Montevideo          127. Regina                  153. Whitehorse
  24. Barbados                50. Edmonton       76. Inuvik                102. Montreal            128. Resolute                154. Winnipeg
  25. Belem                   51. Eirunepe       77. Iqaluit               103. Montserrat          129. Rio_Branco              155. Yakutat
  26. Belize                  52. El_Salvador    78. Jamaica               104. Nassau              130. Santa_Isabel            156. Yellowknife
Time zone: 52
```

En este caso seleccionamos el 52 que es El_Salvador, y presionamos Enter.

Al finalizar nos confirma el cambio de zona horaria:

```
Current default time zone: 'America/El_Salvador'
Local time is now:      Tue Aug 30 09:50:20 CST 2022.
Universal Time is now:  Tue Aug 30 15:50:20 UTC 2022.
```

# CAMBIAR REPOSITORIOS DE SOURCES.LIST

Hacer: **nano /etc/apt/sources.list**

Colocar estas repo:

```
deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free

deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free

deb http://deb.debian.org/debian buster-backports main contrib non-free
deb-src http://deb.debian.org/debian buster-backports main contrib non-free

deb http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security/ buster/updates main contrib non-free
```

# INSTALANDO UN FRONTEND EN REACTJS

Para ello vamos a ocupar el repositorio: <https://github.com/MINSAL-Academia/ticket-ui>

El contenido del archivo **docker-compose.yml** es:

```
#FRONTEND TICKETS (react.js)
 frontend_tickets:
  image: php:7.3-dtic
  container_name: frontend_tickets
  restart: always
  environment:
   - VIRTUAL_HOST=tickets.emplea.goes-dev.net
   - LETSENCRYPT_HOST=tickets.emplea.goes-dev.net
   - LETSENCRYPT_EMAIL=ever.murcia@salud.gob.sv
  volumes:
   - ./services/tickets/fe/master/html:/var/www/html
   - ./services/tickets/fe/master/apache_log:/var/log/apache2
  ports:
   - "8034:80"
   - "8035:3000"
```

Lo guardamos y ejecutamos con ***docker-compose up -d***

Como esta es una instalación limpia de debian, necesitamos instalar lo siguiente:

```
> apt-get update
> apt-get install git
> apt-get install cron
> apt-get install nodejs
> apt-get install npm
> apt-get install rsync
```

> Instalar nvm: <https://www.delftstack.com/es/howto/node.js/update-node-js/>

Al instalar node js lo más seguro que instale una versión antigua, por ejemplo la 10, pero necesitamos trabajar con la version 18.12.1.

Para verficar la versión de node hacer lo siguiente: ***node --version***

---

Ahora cambiaremos la versión de node a la 18.12.1, para ello haremos uso de la app **nvm** (Node Version Manager), ejecutamos lo siguiente ya sea con wget o curl:

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

```
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

*Nota: Hay que salirse del contenedor y luego volver a entrar para que el comando **nvm** funcione.*

Listo ya tenemos nvm instalado, ahora actualizaremos la versión de node:

```
nvm install 18.12.1
```

Listo, ya está por defecto esa versión.

---

**Instalando YARN**

Con npm debemos de instalar yarn realizando el siguiente comando (Esto en cualquier ubicación ya que se instalará de manera global)[Se hizo en /var/www/]:

```
npm install --global yarn
```

---

**Instalaremos los distintos logs** al sistema con:

```
apt-get install rsyslog
```

Configuramos el servicio de rsyslog para que también nos muestre los logs de los cronjobs, para ello modificamos el archivo: **nano /etc/rsyslog.conf**

Descomentamos la línea que hace referencia a los cron, específicamente dice:

```
#cron.*                          /var/log/cron.log
```

Ahora hechamos andar el servicio de logs con: **service rsyslog start**

Esto instalará todos los servicios de logs del sistema, pero los que vamos a hacer uso para monitorear lo que nos interesa son:

```
/var/log/cron.log
/var/log/syslog
```

Podemos estarlos monitoreando en tiempo real con:

```
tail -f /var/log/syslog
```

Hay un tercer log adicional que vamos a estar monitoreando pero lo definiremos en el cronjob.

Info sacada de: <https://linuxtect.com/where-is-cron-or-crontab-log/>

---

**Clonando el proyecto**

Previamente tuvimos que haber generado el archivo ***id_rsa.pub*** con ***ssh-keygen -t rsa***

Acordarse que el contenido de este archivo hay que registrarlo en github para que podamos clonar y usar git con ssh (Más arriba está detallado todo este proceso).

Clonamos el proyecto en la carpeta ***/var/www/code/*** , esto lo hacemos con:

```
cd /var/www/code/
git clone https://github.com/MINSAL-Academia/ticket-ui .
```

*Nota: acordarse que debe de estar seleccionada la opción de ssh en github para que tire la ruta con git no con url https*

Ahora que ya está clonado instalaremos todas las dependencias del proyecto, hacemos en la raiz (/var/www/code/):

```
yarn
```

Ahora importante que tambien en la raiz exista el archivo ***.htaccess*** con el siguiente contenido para que se pueda navegar en todas la rutas de la aplicación:

```
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

*Nota: este archivo lo integraremos posteriormente al despliegue automático tambien.*

Ahora debemos de generar la carpeta ***dist*** que es la que tiene el compilado del código y es la que debemos de publicar en la carpeta /var/www/html/, para ello generamos dist con:

```
yarn run build
```

Ahora que ya tenemos el compilado en dist lo debemos de pasar a carpeta /var/www/html/ y también el archivo .htaccess con:

```
> cd /var/www/code/dist/
> cp * -r /var/www/html/
> cp /var/www/code/.htaccess /var/www/html/
```

Y listo ya está publicado el proyecto y todo funcionando bien.

---

#### Colocando despliegue continuo para frontend React.js

Creamos un archivo ***build.sh*** en la raiz del proyecto (si es que no lo trae ya el repositorio), debe de contener el siguiente contenido:

```
#!/bin/sh
echo " "
echo "*********************************************************************************"
echo "*********************************************************************************"
echo "---------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------"
echo "----------------------------INICIO DESPLIEGUE CONTINUO---------------------------"
echo "---------------------------------------------------------------------------------"
date
echo " "

echo "<<<<<<----------------SET: version de node 18.12.1 de trabajo--------------------"
# Load nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18.12.1

#pwd paths
pwd
echo "<<<<<<-------------------------SET: Path de trabajo------------------------>>>>>>"
cd /var/www/code/
pwd

#puleando el codigo de git :'-)
echo "<<<<<<----------------BEGIN: Descargando cambios si las hay---------------->>>>>>"
git pull --no-edit origin master

#instalando dependencias nuevas
echo "<<<<<<----------BEGIN: Instalando nuevas dependencias si las hay----------->>>>>>"
yarn

#compilando para produccion
echo "<<<<<<------------------BEGIN: Compilando para produccion------------------>>>>>>"
yarn run build

#copiando archivo .htaccess a carpeta dist anteriomente creada
echo "<<<<<<-----------BEGIN:Compiando archivo .htaccess a carpeta dist---------->>>>>>"
cp /var/www/code/.htaccess /var/www/code/dist/
echo "OK!"

#sincronizando carpeta de /var/www/code/dist con carpeta /var/www/html/
echo "<<<<<<--------------BEGIN: Sincronizando carpeta dist con html------------->>>>>>"
rsync -avr /var/www/code/dist/ /var/www/html/ --delete
echo "Carpetas sincronizadas exitosamente!"
echo "Proceso finalizado!"

echo " "
date
echo "---------------------------------------------------------------------------------"
echo "-----------------------------FIN DESPLIEGUE CONTINUO-----------------------------"
echo "---------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------"
echo " "
```

*Nota: las 2 lineas donde contiene:* export NVM*DIR="$([ -z "${XDG*CONFIG*HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG*CONFIG*HOME}/nvm")" [ -s "$NVM*DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"

*Nota: el --no-edit en el **git pull --no-edit origin master,** funciona para que el archivo de resumen del merge no aparezca, ya que en versiones actualizadas del git cada que descarga información con un pull siempre muestra ese archivo de mensaje y nos queremos saltar eso para hacer el despliegue continuo.*

*Son super importantes ya que sin ella no se puede usar el nvm en el archivo .sh dentro del cron*

> Guia de rsync: <https://www.hostinger.es/tutoriales/rsync-linux>

Luego le concedemos permisos de ejecución con:

```
> chmod +x /var/www/code/build.sh
```

Ahora creamos un cron ejecutando:

```
> crontab -e
```

Colocamos el siguiente contenido:

```
* * * * * /var/www/code/build.sh >> /var/log/mycrons.log 2>&1
```

Guardamos el archivo con ***ctrl + x***

Esto ejecutará el archivo **build.sh** y el resultado de dicha ejecución lo depositará en el archivo: **/var/log/mycrons.log**

Por si aún no están activados los cronjob vamos a hacer lo siguiente:

```
> service cron start
```

Podemos monitorear el archivo en tiempo real con:

```
> tail -f /var/log/mycrons.log

```