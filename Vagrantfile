Vagrant.configure("2") do |config|

  # Debian 12
  config.vm.box = "debian/bookworm64"

  # Nombre de la máquina
  config.vm.hostname = "aitordebian"

  # Redirección del puerto 80 de la máquina al 8080 del PC
  config.vm.network "forwarded_port",
    guest: 80,
    host: 8080,
    host_ip: "127.0.0.1"

  # Segunda interfaz de red
  config.vm.network "private_network",
    ip: "192.168.56.10",
    virtualbox__intnet: "red-laboratorio"

  # Ejecutar el script de instalación
  config.vm.provision "shell", path: "apache.sh"

end