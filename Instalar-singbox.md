## Instaltar SINGBOX docker

##### Esto para firma de larga duración.

Documentación en:

`https://felqapbs.hightech-corp.com/SignBox/SignBoxIndex`

#### Indicaciones:

 1. Preparar maquina con ubuntu server >= ver. 20
 2. Instalar docker y docker-compose
 3. Trabajar en ubicación: `$ cd  /opt`
 4. Descargar zip de imagen

    ```
    $ wget https://download.hightech-corp.com/fel/clientes-prueba/estable/signbox_optimizer_docker.zip
    ```
 5. Descomprimir el archivo descargado: `$ unzip signbox_optimizer_docker.zip`
 6. Luego de descompreso trabajar sobre la carpeta creada: `$ cd signbox_optimizer_docker/`
 7. Cargar la imagen de docker con: ` $ docker load --input signbox.tar.gz `
 8. Modificar el archivo docker-compose.yml con el siguiente contenido:

    ```
    version: "3"
    
    services:
    
        api:
            image: signbox
            restart: always
            command: /opt/bit4id/de/bin/de.exe --console api 0
            volumes:
                - ./etc/settings.ini:/opt/bit4id/de/etc/settings.ini
                - db_storage:/opt/bit4id/de/var/
            environment:
                CRYPTOSVC_URL: http://cryptosvc:4096
                DOCKER_RUNNING: 1
            ports:
                - "8080"
        cryptosvc:
            image: signbox
            restart: always
            command: /opt/bit4id/de/bin/de.exe --console cryptosvc 0
            environment:
                CRYPTOSVC_INTERFACE: cryptosvc
                DOCKER_RUNNING: 1
            volumes:
                - ./etc/tsa/:/opt/bit4id/de/etc/tsa/
                - ./etc/trusted_roots/certs/:/opt/bit4id/de/etc/trusted_roots/certs/
                - ./etc/img/:/opt/bit4id/de/etc/img/
                - ./etc/settings.ini:/opt/bit4id/de/etc/settings.ini
                - db_storage:/opt/bit4id/de/var/
            ports:
                - "4096"
        nginx:
            container_name: nginx
            depends_on:
              - api
              - cryptosvc
            image: nginx
            restart: always
            volumes:
                - ./etc/nginx/de.conf:/etc/nginx/conf.d/de.conf
            ports:
                - 80:80
    
    volumes:
        db_storage:
    ```
 9. Modificar el archivo `/opt/singbox_optimizer_docker/etc/nginx/de.conf` con el siguiente contenido:

    ```
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
    
        ###########################################
        # Proxy timeouts
        proxy_connect_timeout              7200s;
        proxy_send_timeout                 7200s;
        proxy_read_timeout                 7200s;
    
        ##
        add_header Cache-Control "no-cache";
    
        ##
        client_max_body_size 0;
        ###########################################
    
        #client_max_body_size 20M;
        location /api {
            rewrite ^/api(/.*)$ $1 break;
            proxy_pass http://api:8080;
        }
    
        location / {
            deny all;
            return 404;
        }
    }
    ```
10. Asegurar de estar en la ubicación del archivo `docker-compose.yml` y ejecutar el servicio con: ` $ docker-compose up -d --scale api=4 --scale cryptosvc=8 `
11. Verificar que el servicio esté corriendo con: `docker-compose ps`

    Esto producirá una vista con la siguiente información (13 contenedores en total ->4 de api, ->8 de cryptosvc y ->1 de nginx, que este último es el proxy que recibe todas las peticiones de firmado y las enruta a los diferentes servicios, este trabaja en el puerto 80 del servidor):

    ```
                    Name                              Command               State                     Ports                   
    --------------------------------------------------------------------------------------------------------------------------
    nginx                                  /docker-entrypoint.sh ngin ...   Up      0.0.0.0:80->80/tcp,:::80->80/tcp          
    signbox_optimizer_docker_api_1         /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32778->8080/tcp,:::32778->8080/tcp
    signbox_optimizer_docker_api_2         /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32777->8080/tcp,:::32777->8080/tcp
    signbox_optimizer_docker_api_3         /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32776->8080/tcp,:::32776->8080/tcp
    signbox_optimizer_docker_api_4         /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32771->8080/tcp,:::32771->8080/tcp
    signbox_optimizer_docker_cryptosvc_1   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32775->4096/tcp,:::32775->4096/tcp
    signbox_optimizer_docker_cryptosvc_2   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32779->4096/tcp,:::32779->4096/tcp
    signbox_optimizer_docker_cryptosvc_3   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32768->4096/tcp,:::32768->4096/tcp
    signbox_optimizer_docker_cryptosvc_4   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32772->4096/tcp,:::32772->4096/tcp
    signbox_optimizer_docker_cryptosvc_5   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32773->4096/tcp,:::32773->4096/tcp
    signbox_optimizer_docker_cryptosvc_6   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32774->4096/tcp,:::32774->4096/tcp
    signbox_optimizer_docker_cryptosvc_7   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32769->4096/tcp,:::32769->4096/tcp
    signbox_optimizer_docker_cryptosvc_8   /opt/bit4id/de/bin/de.exe  ...   Up      0.0.0.0:32770->4096/tcp,:::32770->4096/tcp
    ```
12. Verificar los logs con: `docker-compose logs -f`