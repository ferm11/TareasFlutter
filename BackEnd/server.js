// server.js
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const { MongoClient } = require('mongodb'); 
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());
app.use(express.json());
app.use(cors({
  origin: '*', // Permitir todas las solicitudes de origen
}));

// CONEXIÓN DE LA BASE DE DATOS

const uri = 'mongodb+srv://fermgarcia1912:wUcs7uRYLU8nnRrr@tareas.tgork.mongodb.net/tuBaseDeDatos?retryWrites=true&w=majority';

const client = new MongoClient(uri, { 
    ssl: true,  // Activar SSL para conexiones a Atlas
    tlsInsecure: true,  // Temporalmente deshabilitar la validación de certificados (solo para pruebas)
    connectTimeoutMS: 10000,
    socketTimeoutMS: 45000
});

async function run() {
    try {
        await client.connect();
        console.log('Conectado a MongoDB Atlas');
    } catch (error) {
        console.error('Error al conectar a MongoDB Atlas:', error);
    } finally {
        await client.close();
    }
}

run().catch(console.dir);

// Conexión usando Mongoose
mongoose.connect(uri, { 
    ssl: true,
    tlsInsecure: true,  // Temporalmente deshabilitar la validación de certificados (solo para pruebas)
    connectTimeoutMS: 10000,
    socketTimeoutMS: 45000
})
    .then(() => {
        console.log('Conectado a MongoDB Atlas con Mongoose');
    })
    .catch(err => {
        console.error('Error al conectar a MongoDB Atlas con Mongoose:', err);
    });

// FIN DE LA CONEXIÓN DE LA BASE DE DATOS

// ---------------------------------------------------------------------------------------------

// Definir el esquema de usuario
const userSchema = new Schema({
    username: {
        type: String,
        required: true,
    },
    nombre: {
      type: String,
      required: true,
    },
    apellidos: {
      type: String,
      required: true,
    },
    telefono: {
      type: String,
      required: true,
    },
    correo: {
      type: String,
      required: true,
    },
    edad: {
      type: Number,
      required: true,
    },
    password: {
      type: String,
      required: true,
    }
});
  
const User = mongoose.model('User', userSchema);

// ---------------------------------------------------------------------------------------------

// RUTA DE REGISTRO

app.post('/signup', async (req, res) => {
  const { username, nombre, apellidos, telefono, correo, edad, password } = req.body;

  // Verificar si el usuario ya existe por correo o username
  const emailExists = await User.findOne({ correo });
  const usernameExists = await User.findOne({ username });

  if (emailExists) {
    return res.status(400).json({ message: 'El correo ya está registrado' });
  }
  
  if (usernameExists) {
    return res.status(400).json({ message: 'El nombre de usuario ya está registrado' });
  }

  // Hashear la contraseña
  const hashedPassword = await bcrypt.hash(password, 10);

  // Crear un nuevo usuario
  const newUser = new User({
    username,
    nombre,
    apellidos,
    telefono,
    correo,
    edad,
    password: hashedPassword
  });

  // Guardar el usuario en la base de datos
  await newUser.save();

  res.json({ message: 'Usuario registrado correctamente' });
});

// FIN DE LA RUTA DE REGISTRO

// ---------------------------------------------------------------------------------------------

// Configuración del transportador de nodemailer
const transporter = nodemailer.createTransport({
    service: 'Gmail', // Cambia esto según tu proveedor de correo
    auth: {
        user: 'bibliotecautng1975@gmail.com', // Tu dirección de correo electrónico
        pass: 'piofgmqxyiachyzs', // Tu contraseña de correo electrónico
    },
});

// FIN DE NODEMAILER

// ---------------------------------------------------------------------------------------------

// Almacenamiento temporal del token y la expiración en memoria
let tempToken = null;
let tokenExpirationTime = null;

// Ruta de inicio de sesión para generar y enviar el token
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  // Buscar el usuario por nombre de usuario
  const user = await User.findOne({ username });
  if (!user) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
  }

  // Comparar contraseñas
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
  }

  // Generar un token de 6 dígitos
  const token = generateSixDigitToken();
  console.log('Token generado:', token);

  // Establecer la expiración del token (5 minutos)
  const expirationTime = Date.now() + 5 * 60 * 1000; // 5 minutos en milisegundos

  // Almacenar el token y su expiración en variables temporales
  tempToken = token;
  tokenExpirationTime = expirationTime;

  // Imprimir para depuración
  console.log('Token temporal:', tempToken, 'Expira en:', new Date(tokenExpirationTime));

  // Enviar el token al correo electrónico
  const mailOptions = {
      from: process.env.EMAIL,
      to: user.correo,
      subject: 'Token de Inicio de Sesión',
      text: `¡Hola ${user.username}!\n\n` +
            `Has solicitado un inicio de sesión. Aquí está tu token:\n\n` +
            `Token: ${token}\n\n` +
            `Este token es válido por 5 minutos. Por favor, no lo compartas con nadie.\n\n` +
            `Si no solicitaste este inicio de sesión, por favor ignora este correo.\n\n` +
            `¡Gracias!\n` +
            `El equipo de Tasky`,
  };

  try {
      await transporter.sendMail(mailOptions);
      res.json({ message: 'Token enviado al correo electrónico' });
  } catch (error) {
      console.error('Error al enviar el correo', error);
      res.status(500).json({ message: 'Error al enviar el correo' });
  }
});

// Función para generar un token de 6 dígitos
function generateSixDigitToken() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// FIN DE LA RUTA DE INICIO DE SESION

// ---------------------------------------------------------------------------------------------

// RUTA PARA VERIFICAR TOKEN

// Ruta para validar el token
app.post('/validate_token', async (req, res) => {
  const { username, token } = req.body;

  // Verificar que el token y username llegaron correctamente
  console.log('Datos recibidos del formulario:', req.body);

  if (!username) {
      console.log('No se recibió el nombre de usuario');
      return res.status(400).json({ message: 'Nombre de usuario no proporcionado' });
  }

  if (!token) {
      console.log('No se recibió el token');
      return res.status(400).json({ message: 'Token no proporcionado' });
  }

  // Buscar el usuario por nombre de usuario (si quieres validar que el usuario existe)
  const user = await User.findOne({ username });
  if (!user) {
      console.log('Usuario no encontrado:', username);
      return res.status(401).json({ message: 'Usuario no encontrado' });
  }

  // Verificar el token temporal y su expiración
  console.log('Token recibido:', token);
  console.log('Token temporal almacenado:', tempToken);

  const isTokenValid = token === tempToken && Date.now() < tokenExpirationTime;

  if (!isTokenValid) {
      console.log('Token inválido o expirado');
      return res.status(401).json({ message: 'Token inválido o expirado' });
  }

  // Si el token es válido
  console.log('Token verificado correctamente');
  res.json({ message: 'Token verificado, inicio de sesión exitoso' });
});


// FIN DE LA RUTA DE VERIFICACIÓN DE TOKEN

// ---------------------------------------------------------------------------------------------

app.listen(3000, () => console.log('Servidor corriendo en el puerto 3000'));
