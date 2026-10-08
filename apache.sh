#!/bin/bash

# Actualizar la lista de paquetes
apt-get update

# Instalar Apache
apt-get install -y apache2

# Obtener el hostname
HOSTNAME=$(hostname)

# Crear la página web, el EOF significa que hasta que no lea EOF no deja de ejecutarlo.
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Servidor Apache</title>
</head>
<body>
    <h1>Servidor Apache funcionando</h1>
    <p>Nombre: aitor</p>
    <p>Hostname: $HOSTNAME</p>
</body>
</html>
EOF

# Hacer que Apache se inicie automáticamente
systemctl enable apache2

# Iniciar Apache
systemctl start apache2

# Reiniciar Apache
systemctl restart apache2