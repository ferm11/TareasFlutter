// server.js
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise'); // Importar mysql2/promise para usar promesas
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(express.json());
app.use(cors({
  origin: '*', // Permitir todas las solicitudes de origen
}));

// Configuración de la conexión a la base de datos
const dbPool = mysql.createPool({
  host: 'bfiduy2yfdfeqqrvvy53-mysql.services.clever-cloud.com',
  user: 'udzpqpkz56rqznmw',
  password: 'qJcX3gKiZJGQ64yXLaov',
  database: 'bfiduy2yfdfeqqrvvy53',
  port: 3306
});

// Comprobación de conexión inicial
dbPool.getConnection()
  .then(connection => {
    console.log('Conectado a la base de datos MySQL');
    connection.release(); // Liberar la conexión inmediatamente si no se usa
  })
  .catch(err => {
    console.error('Error al conectar a la base de datos:', err);
  });


// ---------------------------------------------------------------------------------------------

// RUTA DE REGISTRO
app.post('/signup', async (req, res) => {
  const { username, nombre, apellidos, telefono, correo, edad, password } = req.body;

  try {
    const connection = await dbPool.getConnection();

    // Verificar si el usuario ya existe por correo o username
    const [existingUser] = await connection.execute('SELECT * FROM Users WHERE correo = ? OR username = ?', [correo, username]);

    if (existingUser.length > 0) {
      return res.status(400).json({ message: 'El correo o nombre de usuario ya está registrado' });
    }

    // Hashear la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear un nuevo usuario
    await connection.execute(
      'INSERT INTO Users (username, nombre, apellidos, telefono, correo, edad, password) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [username, nombre, apellidos, telefono, correo, edad, hashedPassword]
    );

    connection.release(); // Liberar la conexión de vuelta al pool
    res.json({ message: 'Usuario registrado correctamente' });
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).json({ message: 'Error al registrar usuario' });
  }
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

// Función para generar un token de 6 dígitos
function generateSixDigitToken() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// -----------------------------------------------------------------------

// RUTA DE INICIO DE SESIÓN
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const connection = await dbPool.getConnection();
    try {
      // Buscar el usuario por nombre de usuario
      const [rows] = await connection.execute('SELECT * FROM Users WHERE username = ?', [username]);
      const user = rows[0];
      if (!user) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      // Comparar contraseñas
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      // Generar un token de 6 dígitos y asignarlo globalmente
      const token = generateSixDigitToken();
      tempToken = token; // Asigna el token globalmente
      tokenExpirationTime = Date.now() + 5 * 60 * 1000; // 5 minutos en milisegundos
      console.log('Token temporal asignado:', tempToken);

      // Enviar el token al correo electrónico
      const mailOptions = {
        from: transporter.options.auth.user,
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
        res.status(500).json({ message: 'Error al enviar el correo', error: error.message });
      }
    } finally {
      connection.release(); // Liberar la conexión de vuelta al pool
    }
  } catch (error) {
    console.error('Error al iniciar sesión:', error);
    res.status(500).json({ message: 'Error al iniciar sesión', error: error.message });
  }
});

// FIN DE LOGIN --------------------------------------------------------

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

  try {
    // Conectar a la base de datos
    const connection = await dbPool.getConnection();

    // Buscar el usuario por nombre de usuario
    const [rows] = await connection.execute('SELECT * FROM Users WHERE username = ?', [username]);
    const user = rows[0];

    // Liberar la conexión de vuelta al pool
    connection.release();

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

  } catch (error) {
    console.error('Error al validar token:', error);
    res.status(500).json({ message: 'Error al validar token' });
  }
});

// INICIO DE SESION CON GOOGLE ------------

// const { OAuth2Client } = require('google-auth-library');
// const client = new OAuth2Client('965610149476-ieqvfaarut56ujsev3g905q47tof2ogm.apps.googleusercontent.com');

// async function verifyToken(idToken) {
//   const ticket = await client.verifyIdToken({
//     idToken: idToken,
//     audience: '965610149476-ieqvfaarut56ujsev3g905q47tof2ogm.apps.googleusercontent.com',
//   });
//   const payload = ticket.getPayload();
//   return payload;
// }

// app.post('/login_with_google', async (req, res) => {
//   const { idToken } = req.body;

//   try {
//     const payload = await verifyToken(idToken);
//     // Aquí puedes buscar o crear un usuario en tu base de datos basado en la información del token
//     res.status(200).send({ message: 'Login exitoso' });
//   } catch (error) {
//     res.status(401).send({ message: 'Token inválido' });
//   }
// });

// Ruta para verificar el correo si existe cuando accede por Google
app.post('/google-login', async (req, res) => {
  const { email } = req.body;

  try {
    const connection = await dbPool.getConnection();

    // Verificar si el correo está registrado en la base de datos
    const [rows] = await connection.execute('SELECT * FROM Users WHERE correo = ?', [email]);
    const user = rows[0]; // Asegúrate de que 'user' está bien definido

    // Liberar la conexión de vuelta al pool
    connection.release();

    // Si el usuario no existe, se retorna un error
    if (!user) {
      return res.status(404).json({ message: 'Correo no registrado' });
    }

    // Si el usuario existe, envía la respuesta de éxito
    res.status(200).json({ message: 'Inicio de sesión exitoso', user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});



// Iniciar el servidor
app.listen(3000, () => console.log('Servidor corriendo en el puerto 3000'));
