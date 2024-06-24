import {Router} from 'express'
import verificarAutenticacion from '../middlewares/autenticacion.js'
import { 
    validacionEmail, 
    validacionUsuario,
    validacionNuevoPassword,
    validacionLogin,
    validacionActualizarPassword
} from '../middlewares/validacionUsuario.js';

const router = Router()
import{
    login,
    perfil,
    registro,
    confirmEmail,
    detalleUsuario,
    actualizarPassword,
    recuperarPassword,
    recuperarUsername,
    comprobarTokenPasword,
    nuevoPassword,
    actualizarPerfil
} from "../controllers/usuario_controller.js";

router.post("/login", validacionLogin, login)

router.post("/registro", verificarAutenticacion, validacionUsuario, registro)

router.get("/confirmar/:token", confirmEmail);

router.post("/recuperar-password", validacionEmail, recuperarPassword);

router.post("/recuperar-username", validacionEmail, recuperarUsername);

router.get("/recuperar-password/:token", comprobarTokenPasword);

router.post("/nuevo-password/:token", validacionNuevoPassword, nuevoPassword);

router.get("/perfil", verificarAutenticacion, perfil)

router.put('/usuario/actualizarpassword', verificarAutenticacion, validacionActualizarPassword, actualizarPassword)

router.get('/usuario/:id', verificarAutenticacion, detalleUsuario)

router.put("/usuario/:id", verificarAutenticacion, actualizarPerfil);

export default router