// Requerir los módulos
import express from 'express'
import dotenv from 'dotenv'
import cors from 'cors';
import routerUsuarios from './routers/usuario_routes.js';
import routerProductos from './routers/producto_routes.js';
import routerClientes from './routers/cliente_routes.js';
import routerEmpleados from './routers/empleado_routes.js';
import routerFactura from './routers/factura_routes.js';
import routerProforma from './routers/proforma_routes.js';



dotenv.config()
// Inicializaciones
const app = express()
app.set('port',process.env.port || 1000)

// Configuraciones 
app.use(cors())

//app.set('port',process.env.port || 3000)
//app.use(cors())
/*
app.use(cors({origin: '*', optionsSuccessStatus: 200}))
app.set('port',process.env.port || 3000)*/

// Middlewares 
app.use(express.json())


// Variables globales


// Rutas 
app.use('/api',routerUsuarios)
app.use('/api',routerProductos)
app.use('/api',routerClientes)
app.use('/api',routerEmpleados)
app.use('/api',routerProforma)
app.use('/api',routerFactura)

// Manejo de una ruta que no sea encontrada
app.use((req,res)=>res.status(404).send("Endpoint no encontrado - 404"))

// Exportar la instancia de express por medio de app
export default  app