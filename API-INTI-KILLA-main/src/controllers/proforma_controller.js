import Cliente from "../models/Cliente.js"
import mongoose from "mongoose"
import Empleado from "../models/Empleado.js";
import Proforma from "../models/Proforma.js";

const listarProformas = async (req,res)=>{
    const proformas = await Proforma.find().select("-createdAt -updatedAt -__v");
    res.status(200).json(proformas)
}
const detalleProforma = async(req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe la Proforma ${id}`});
    const proforma = await Proforma.findById(id).select("-createdAt -updatedAt -__v")
    res.status(200).json(proforma)
}
const registrarProforma = async(req,res)=>{
    const {
        id_cliente,
        id_empleado,
        products,
        totalSinImpuestos,
        totalDescuento,
        totalImpuestoValor,
        importeTotal
      } = req.body;

    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const clienteBDD = await Cliente.findById(id_cliente);
    if (!clienteBDD) return res.status(400).json({ msg: "Lo sentimos, el cliente no se encuentra registrado" });
    const empleadoBDD = await Empleado.findById(id_empleado);
    if (!empleadoBDD) return res.status(400).json({ msg: "Lo sentimos, el empleado no se encuentra registrado" });

    

    // Obtener el último secuencial de factura
    const lastProforma = await Proforma.findOne().sort({ _id: -1 }).limit(1);
    let secuencial = lastProforma ? parseInt(lastProforma.secuencial) + 1 : 1;
    secuencial = secuencial.toString().padStart(9, '0'); // Asegurar que tenga 9 dígitos

    const fechaActual = new Date();

    const totalSinImpuestosFixed = parseFloat(totalSinImpuestos).toFixed(2);
    const totalDescuentoFixed = parseFloat(totalDescuento).toFixed(2);
    const totalImpuestoValorFixed = parseFloat(totalImpuestoValor).toFixed(2);
    const importeTotalFixed = parseFloat(importeTotal).toFixed(2);

    // Crear un nuevo objeto de la factura
    const nuevaProforma = new Proforma({
        id_cliente,
        id_empleado,
        secuencial,
        fechaEmision: fechaActual,
        productos: products,
        totalSinImpuestos: totalSinImpuestosFixed,
        totalDescuento: totalDescuentoFixed,
        totalImpuestoValor: totalImpuestoValorFixed,
        importeTotal: importeTotalFixed
      });

    await nuevaProforma.save()
    res.status(200).json({msg:"Registro exitoso de la Proforma"})
}
const actualizarProforma = async(req,res)=>{
    const {id} = req.params
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe la Proforma ${id}`});
    await Proforma.findByIdAndUpdate(req.params.id,req.body)
    res.status(200).json({msg:"Actualización exitosa de la Proforma"})
}
const eliminarProforma = async (req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe la Proforma ${id}`})
    await Proforma.findByIdAndDelete(id);
    res.status(200).json({msg:"Proforma eliminada exitosamente"})
}

export {
	listarProformas,
    detalleProforma,
    registrarProforma,
    actualizarProforma,
    eliminarProforma
}