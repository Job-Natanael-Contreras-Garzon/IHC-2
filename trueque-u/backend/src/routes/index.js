const { Router } = require('express');
const usuariosRutas = require('./usuarios.rutas');
const sesionesRutas = require('./sesiones.rutas');
const recuperacionesRutas = require('./recuperaciones.rutas');
const publicacionesRutas = require('./publicaciones.rutas');

const rutas = Router();

rutas.use('/usuarios', usuariosRutas);
rutas.use('/sesiones', sesionesRutas);
rutas.use('/recuperaciones', recuperacionesRutas);
rutas.use('/publicaciones', publicacionesRutas);

module.exports = rutas;
