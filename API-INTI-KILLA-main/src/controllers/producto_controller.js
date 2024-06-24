import Producto from "../models/Producto.js"
import mongoose from "mongoose"

const infoProducto =(req,res)=>{
    delete req.productoBDD.createdAt
    delete req.productoBDD.updatedAt
    delete req.productoBDD.__v
    res.status(200).json(req.productoBDD)
}
const listarProductos = async (req,res)=>{
    //const productos = await Producto.find({estado:true}).where('producto').equals(req.productoBDD).select("-createdAt -updatedAt -__v").populate('_id codigo nombre precio_unitario cantidad')
    const productos = await Producto.find().select("-createdAt -updatedAt -__v");
    res.status(200).json(productos)
}
const detalleProducto = async(req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Producto ${id}`});
    //const producto = await Producto.findById(id).select("-createdAt -updatedAt -__v").populate('_id codigo nombre precio_unitario cantidad')
    const producto = await Producto.findById(id).select("-createdAt -updatedAt -__v")
    res.status(200).json(producto)
}
const registrarProducto = async(req,res)=>{
    const {nombre,codigo} = req.body
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const verificarNombreBDD = await Producto.findOne({nombre})
    if(verificarNombreBDD) return res.status(400).json({msg:"Lo sentimos, el Producto ya se encuentra registrado"})
    const verificarCodigoBDD = await Producto.findOne({codigo})
    if(verificarCodigoBDD) return res.status(400).json({msg:"Lo sentimos, el código ya se encuentra registrado"})
    const nuevoProducto = new Producto(req.body)
    await nuevoProducto.save()
    res.status(200).json({msg:"Registro exitoso del Producto"})
}
const actualizarProducto = async(req,res)=>{
    const {id} = req.params
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Producto ${id}`});
    await Producto.findByIdAndUpdate(req.params.id,req.body)
    res.status(200).json({msg:"Actualización exitosa del Producto"})
}
const eliminarProducto = async (req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Producto ${id}`})
    await Producto.findByIdAndDelete(id);
    res.status(200).json({msg:"Producto eliminado exitosamente"})
}

export {
	infoProducto,
    listarProductos,
    detalleProducto,
    registrarProducto,
    actualizarProducto,
    eliminarProducto
}