import mongoose from "mongoose"
import Factura from "../models/Factura.js";
import { sendMailFactura } from "../config/nodemailer.js";
import { generatePdfMail } from "./facturaPDF_controller.js";

const listarFacturas = async (req,res)=>{
  const facturas = await Factura.find().select("-createdAt -updatedAt -__v");
  res.status(200).json(facturas)
}
const detalleFactura = async(req,res)=>{
  const {id} = req.params
  if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe la Factura ${id}`});
  const factura = await Factura.findById(id).select("-createdAt -updatedAt -__v")
  res.status(200).json(factura)
}
const enviarFactura = async(nombre, mail, secuencial, claveAcceso, filePath) => {
  try {
    const facturaBDD = await Factura.findOne({ claveAcceso }).select("-createdAt -updatedAt -__v");
    if (!facturaBDD) return res.status(400).json({ msg: "Lo sentimos, la factura no se encuentra registrada" })

    const pdfPath = await generatePdfMail(facturaBDD._id);
    if (!pdfPath) {
      return { msg: "Error al generar el archivo PDF de la factura" };
    }
    
    const enviarPDF = await sendMailFactura(nombre, mail, secuencial, pdfPath, filePath);

  } catch (error) {
    console.error("Error en enviar la factura al correo:", error);
    return { msg: "Error en enviar la factura al correo" };
  }
}

export {
    listarFacturas,
    detalleFactura,
    enviarFactura
}