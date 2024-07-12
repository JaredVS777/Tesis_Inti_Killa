import {Router} from 'express'
const router = Router()
import { generateInvoiceXml, recepcionSRI, autorizacionSRI } from '../controllers/factura_controller.js';
import { detalleFactura, listarFacturas } from '../controllers/facturaListar_controller.js';
import { generatePdf } from '../controllers/facturaPDF_controller.js';
import verificarAutenticacion from "../middlewares/autenticacion.js";
import { validacionFactura } from '../middlewares/validacionFactura.js';


router.get('/facturas', verificarAutenticacion, listarFacturas)
router.get('/factura/:id', verificarAutenticacion, detalleFactura)
router.post('/factura/generate-invoice', verificarAutenticacion, validacionFactura, generateInvoiceXml)
router.post('/factura/recibir', verificarAutenticacion, recepcionSRI)
router.post('/factura/autorizacion', verificarAutenticacion, autorizacionSRI)
router.get('/factura/generate-pdf/:id', verificarAutenticacion, generatePdf)


export default router