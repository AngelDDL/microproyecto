#!/bin/bash

# --- Instalar Node.js y npm ---
echo "Instalando Node.js y npm..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
NODE_MAJOR=18
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update -y
apt-get install nodejs -y

# --- Configurar la aplicacion web ---
echo "Configurando la aplicacion Node.js..."
# Copiar codigo de la app a /opt/app
mkdir -p /opt/app
cp -r /vagrant_configs/app/* /opt/app/

# Instalar dependencias
cd /opt/app
npm install

# --- Crear y configurar el servicio systemd ---
echo "Creando el servicio systemd para la webapp..."

cat <<EOF > /etc/systemd/system/webapp.service
[Unit]
Description=Servidor de la aplicacion web (Node.js)
After=network.target

[Service]
User=vagrant
Group=vagrant
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar el servicio
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service

echo "Aprovisionamiento del nodo web completado!"