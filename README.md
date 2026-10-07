# Primeros pasos con Vagrant

## 1. Introducción

En esta práctica he utilizado **Vagrant** para crear y configurar una máquina virtual con **Debian 12**.

La idea de utilizar Vagrant es poder crear una máquina virtual de una forma sencilla y que la configuración se pueda repetir en otro ordenador. Así no tenemos que configurar todo manualmente cada vez.

He creado una máquina Debian 12, le he puesto un nombre, he configurado dos interfaces de red y he instalado Apache mediante un script.

---

## 2. ¿Qué es Vagrant?

Vagrant es una herramienta que sirve para crear y configurar máquinas virtuales utilizando archivos de configuración.

Esto es útil porque la configuración queda guardada en archivos y se puede volver a utilizar. También permite borrar una máquina y volver a crearla sin tener que hacer toda la configuración manualmente.

### Conceptos principales

* **Anfitrión:** es mi ordenador físico, donde ejecuto Vagrant.
* **Proveedor:** es el programa que se encarga de ejecutar la máquina virtual. En esta práctica he utilizado VirtualBox.
* **Box:** es una imagen preparada que Vagrant utiliza como base para crear la máquina virtual. En este caso utilizo Debian 12.
* **Máquina virtual:** es el Debian que Vagrant crea dentro de VirtualBox.
* **Vagrantfile:** es el archivo donde se guarda la configuración de la máquina virtual. Está escrito utilizando Ruby.

---

## 3. Vagrantfile

El archivo `Vagrantfile` contiene la configuración principal de la máquina.

Las líneas principales que he utilizado son:

```ruby
config.vm.box = "debian/bookworm64"
```

Esta línea indica que la máquina utilizará una box de Debian 12.

```ruby
config.vm.hostname = "TU_NOMBRE"
```

Con esta línea pongo un nombre identificable a la máquina.

```ruby
config.vm.network "forwarded_port",
  guest: 80,
  host: 8080,
  host_ip: "127.0.0.1"
```

Esta configuración hace que el puerto 80 de Apache dentro de la máquina se pueda abrir desde mi ordenador usando el puerto 8080.

Además, el acceso queda limitado a `127.0.0.1`, por lo que el puerto se utiliza desde el propio ordenador anfitrión.

```ruby
config.vm.network "private_network",
  ip: "192.168.56.10",
  virtualbox__intnet: "red-laboratorio"
```

Esta parte añade una segunda interfaz de red con la dirección IP `192.168.56.10`.

En VirtualBox la he configurado como una red interna llamada `red-laboratorio`.

Por último:

```ruby
config.vm.provision "shell", path: "instalar_apache.sh"
```

Esta línea indica a Vagrant que debe ejecutar el script `instalar_apache.sh` para preparar la máquina.

---

## 4. Redes

La máquina tiene dos interfaces.

La primera es la interfaz **NAT** que Vagrant configura por defecto. Esta interfaz permite que la máquina virtual tenga conexión de red y pueda acceder a Internet.

La segunda interfaz es la **red de laboratorio**. En mi caso tiene la IP:

```text
192.168.56.10
```

Esta segunda red sirve para tener una red separada para la práctica.

La NAT y la red de laboratorio tienen funciones diferentes. La NAT se utiliza principalmente para la conexión de la máquina virtual con el exterior, mientras que la red interna se utiliza para la comunicación dentro de esa red.

### Esquema de la red

```text
                  ORDENADOR ANFITRIÓN
                         |
                         |
                    VirtualBox
                         |
                +--------+--------+
                |                 |
               NAT        Red interna
                |                 |
                |          192.168.56.10
                |                 |
                +-------- Debian 12
                              |
                           Apache
                              |
                         Puerto 80
                              |
                    Reenvío al puerto
                       8080 del PC
```

El reenvío de puertos no crea una interfaz de red nueva. Sirve para conectar un puerto del ordenador anfitrión con un puerto de la máquina virtual.

---

## 5. Aprovisionamiento

El aprovisionamiento sirve para ejecutar automáticamente tareas de configuración dentro de la máquina virtual.

En esta práctica utilizo un script Bash llamado:

```text
instalar_apache.sh
```

El script se ejecuta dentro de la máquina Debian, no directamente en mi ordenador.

En el `Vagrantfile` utilizo:

```ruby
config.vm.provision "shell", path: "instalar_apache.sh"
```

Con `path` indico el archivo que Vagrant tiene que ejecutar.

También existe la opción `inline`, que permite escribir directamente los comandos dentro del `Vagrantfile`, pero en esta práctica he utilizado `path` porque el script está guardado en un archivo separado.

Si modifico el script después de haber creado la máquina, puedo volver a ejecutar solamente el aprovisionamiento utilizando:

```bash
vagrant provision
```

---

## 6. Script de Apache

El script primero actualiza la lista de paquetes:

```bash
apt-get update
```

Después instala Apache:

```bash
apt-get install -y apache2
```

Después obtengo el hostname de la máquina:

```bash
HOSTNAME=$(hostname)
```

A continuación creo el archivo `index.html` dentro de la carpeta de Apache:

```text
/var/www/html/index.html
```

En la página aparece mi nombre y el hostname de la máquina.

Finalmente utilizo:

```bash
systemctl enable apache2
```

para hacer que Apache se inicie automáticamente.

Después:

```bash
systemctl start apache2
```

para iniciar el servicio.

Y:

```bash
systemctl restart apache2
```

para reiniciarlo y aplicar los cambios.

---

## 7. Comandos de Vagrant

Estos son los comandos principales que he utilizado durante la práctica:

| Comando             | Para qué sirve                        | Lo he ejecutado |
| ------------------- | ------------------------------------- | --------------- |
| `vagrant up`        | Crea y arranca la máquina             | Sí              |
| `vagrant status`    | Muestra el estado de la máquina       | Sí              |
| `vagrant ssh`       | Entra en la máquina por SSH           | Sí              |
| `vagrant reload`    | Reinicia la máquina aplicando cambios | Sí              |
| `vagrant provision` | Ejecuta de nuevo el aprovisionamiento | Sí              |
| `vagrant halt`      | Apaga la máquina                      | Sí              |
| `vagrant destroy`   | Elimina la máquina virtual            | No              |

---

## 8. Carpeta compartida `/vagrant`

Vagrant comparte automáticamente la carpeta del proyecto con la máquina virtual.

Dentro de Debian esta carpeta se encuentra normalmente en:

```text
/vagrant
```

En ella puedo encontrar los archivos del proyecto, como por ejemplo:

```text
Vagrantfile
instalar_apache.sh
README.md
```

Esto permite trabajar con los archivos del proyecto desde el ordenador anfitrión y acceder a ellos desde la máquina virtual.

---

## 9. Comprobaciones

Después de arrancar la máquina he comprobado que el hostname es correcto:

```bash
hostname
```

También he comprobado las interfaces de red:

```bash
ip addr
```

Y las rutas:

```bash
ip route
```

Para comprobar Apache he utilizado:

```bash
systemctl status apache2
```

El servicio debe aparecer como activo.

También puedo comprobar que Apache responde utilizando:

```bash
curl http://localhost
```

Finalmente, desde el ordenador anfitrión puedo abrir en el navegador:

```text
http://127.0.0.1:8080
```

Ahí debería aparecer la página que he creado.

---

## 10. Capturas

### Apache funcionando

En esta captura se puede ver que el servicio Apache está funcionando correctamente.

![Apache funcionando](imagenes/apache-funcionando.png)

### Página web

En esta captura se puede ver la página de Apache desde el navegador del ordenador anfitrión.

![Página web](imagenes/pagina-web.png)

### Interfaces y rutas

En esta captura se pueden ver las interfaces y las rutas de red de la máquina virtual.

![Interfaces y rutas](imagenes/red.png)

---

## 11. Resultado final

Al terminar la práctica tengo una máquina Debian 12 creada con Vagrant.

La máquina tiene dos interfaces de red: una NAT y otra de laboratorio con una IP fija.

También tiene Apache instalado mediante un script Bash y puedo acceder a la página web desde mi ordenador utilizando el puerto 8080.

De esta forma, la configuración queda guardada en archivos y se puede volver a crear el entorno utilizando Vagrant.
