import {Router} from 'express'
const router = Router()
import { validacionProforma } from '../middlewares/validacionProforma.js';
import {
    listarProformas,
    detalleProforma,
    registrarProforma,
    actualizarProforma,
    eliminarProforma
} from "../controllers/proforma_controller.js";
import { generatePdf } from '../controllers/proformaPDF_controller.js';
import verificarAutenticacion from "../middlewares/autenticacion.js";


router.get('/proformas', verificarAutenticacion, listarProformas)
router.get('/proforma/:id', verificarAutenticacion, detalleProforma)
router.post('/proforma/registro', verificarAutenticacion, validacionProforma, registrarProforma)
router.put('/proforma/actualizar/:id', verificarAutenticacion, actualizarProforma)
router.delete('/proforma/eliminar/:id', verificarAutenticacion, eliminarProforma)
router.get('/proforma/generate-pdf/:id', verificarAutenticacion, generatePdf);

export default router