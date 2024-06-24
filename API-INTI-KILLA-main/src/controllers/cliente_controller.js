import Cliente from "../models/Cliente.js"
import mongoose from "mongoose"

const perfilCliente =(req,res)=>{
    delete req.clienteBDD.createdAt
    delete req.clienteBDD.updatedAt
    delete req.clienteBDD.__v
    res.status(200).json(req.clienteBDD)
}
const listarClientes = async (req,res)=>{
    //const clientes = await Cliente.find({estado:true}).where('cliente').equals(req.clienteBDD).select("-createdAt -updatedAt -__v").populate('_id nombre cedula telefono direccion email')
    const clientes = await Cliente.find().select("-createdAt -updatedAt -__v");
    res.status(200).json(clientes)
}
const detalleCliente = async(req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Cliente ${id}`});
    //const cliente = await Cliente.findById(id).select("-createdAt -updatedAt -__v").populate('_id nombre cedula telefono direccion email')
    const cliente = await Cliente.findById(id).select("-createdAt -updatedAt -__v")
    res.status(200).json(cliente)
}
const busquedaCliente = async (req, res) => {
    const { cedula } = req.body;
    if (!cedula) return res.status(400).json({ msg: "Lo sentimos, debes llenar todos los campos" });

    try {
        const clienteBDD = await Cliente.findOne({ cedula }).select("-createdAt -updatedAt -__v");
        if (!clienteBDD) return res.status(400).json({ msg: "Lo sentimos, el cliente no se encuentra registrado" });
        res.status(200).json(clienteBDD);
    } catch (error) {
        console.error("Error buscando cliente:", error);
        res.status(500).json({ msg: "Error del servidor, por favor intenta de nuevo más tarde" });
    }
};
const registrarCliente = async(req,res)=>{
    const {cedula} = req.body
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const verificarCedulaBDD = await Cliente.findOne({cedula})
    if(verificarCedulaBDD) return res.status(400).json({msg:"Lo sentimos, la cédula ya se encuentra registrada"})
    const nuevoCliente = new Cliente(req.body)
    await nuevoCliente.save()
    res.status(200).json({msg: "Registro exitoso del Cliente", cliente: nuevoCliente})
}
const actualizarCliente = async(req,res)=>{
    const {id} = req.params
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Cliente ${id}`});
    await Cliente.findByIdAndUpdate(req.params.id,req.body)
    res.status(200).json({msg:"Actualización exitosa del Cliente"})
}
const eliminarCliente = async (req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Cliente ${id}`})
    await Cliente.findByIdAndDelete(id);
    res.status(200).json({msg:"Cliente eliminado exitosamente"})
}

export {
	perfilCliente,
    listarClientes,
    detalleCliente,
    registrarCliente,
    actualizarCliente,
    eliminarCliente,
    busquedaCliente
}