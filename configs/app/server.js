const express = require('express');
const os = require('os');

const app = express();
const port = 3000;

// Endpoint principal que muestra el nombre del host
app.get('/', (req, res) => {
  res.send(`Hola! Soy el servidor: ${os.hostname()}`);
});

// Endpoint para el chequeo de salud de Consul
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`Servidor web corriendo en http://localhost:${port}`);
});