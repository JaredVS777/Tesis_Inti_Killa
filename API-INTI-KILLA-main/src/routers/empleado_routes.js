import {Router} from 'express'
const router = Router()
import {
    loginEmpleado,
	perfilEmpleado,
    listarEmpleados,
    detalleEmpleado,
    registrarEmpleado,
    confirmEmailEmpleado,
    actualizarPasswordEmpleado,
    recuperarPasswordEmpleado,
    nuevoPasswordEmpleado,
    recuperarUsernameEmpleado,
    actualizarEmpleado,
    eliminarEmpleado
} from "../controllers/empleado_controller.js";
import verificarAutenticacion from "../middlewares/autenticacion.js";
import { 
    validacionEmail, 
    validacionEmpleado,
    validacionNuevoPassword,
    validacionLogin,
    validacionActualizarPassword
} from '../middlewares/validacionEmpleado.js';

router.post("/empleado/login", validacionLogin, loginEmpleado)

router.get("/empleado/confirmar/:token", confirmEmailEmpleado);

router.post("/empleado/recuperar-password", validacionEmail , recuperarPasswordEmpleado);

router.post("/empleado/recuperar-username", validacionEmail, recuperarUsernameEmpleado);

router.post("/empleado/nuevo-password", validacionNuevoPassword , nuevoPasswordEmpleado);

router.post('/empleado/registro', verificarAutenticacion, validacionEmpleado, registrarEmpleado)

router.get('/empleado/informacion', verificarAutenticacion, perfilEmpleado)

router.put('/empleado/actualizarpassword', verificarAutenticacion, validacionActualizarPassword , actualizarPasswordEmpleado)

router.get('/empleados', verificarAutenticacion, listarEmpleados)

router.get('/empleado/:id', verificarAutenticacion, detalleEmpleado)

router.put('/empleado/actualizar/:id', verificarAutenticacion, actualizarEmpleado)

router.put('/empleado/eliminar/:id', verificarAutenticacion, eliminarEmpleado)

export default router