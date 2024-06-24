import {Router} from 'express'
const router = Router()
import {
    infoProducto,
    listarProductos,
    detalleProducto,
    registrarProducto,
    actualizarProducto,
    eliminarProducto
} from "../controllers/producto_controller.js";
import verificarAutenticacion from "../middlewares/autenticacion.js";
import {
    validacionProducto
} from '../middlewares/validacionProducto.js';


router.get('/producto/informacion', verificarAutenticacion, infoProducto)
router.get('/productos', verificarAutenticacion, listarProductos)
router.get('/producto/:id', verificarAutenticacion, detalleProducto)
router.post('/producto/registro', verificarAutenticacion, validacionProducto, registrarProducto)
router.put('/producto/actualizar/:id', verificarAutenticacion, actualizarProducto)
router.delete('/producto/eliminar/:id', verificarAutenticacion, eliminarProducto)

export default router