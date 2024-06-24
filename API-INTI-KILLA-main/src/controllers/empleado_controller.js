import Empleado from "../models/Empleado.js"
import generarJWT from "../helpers/crearJWT.js"
import mongoose from "mongoose"
import { sendMailToEmpleado, sendMailToRecoveryPasswordEmpleado, sendMailToRecoveryUsernameEmpleado } from "../config/nodemailer.js"

const loginEmpleado = async(req,res)=>{
    const {username,password} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const empleadoBDD = await Empleado.findOne({username}).select("-status -__v -token -updatedAt -createdAt")
    if(empleadoBDD?.confirmEmail===false) return res.status(403).json({msg:"Lo sentimos, debe verificar su cuenta"})
    if(!empleadoBDD) return res.status(404).json({msg:"Lo sentimos, el usuario no se encuentra registrado"})
    const verificarPassword = await empleadoBDD.matchPassword(password)
    if(!verificarPassword) return res.status(404).json({msg:"Lo sentimos, el password no es el correcto"})
    const token = generarJWT(empleadoBDD._id,"empleado")
    const {nombre,apellido,_id} = empleadoBDD
    res.status(200).json({
        token,
        nombre,
        apellido,
        username,
        _id,
        email:empleadoBDD.email
    })
}

const perfilEmpleado =(req,res)=>{
    delete req.empleadoBDD.createdAt
    delete req.empleadoBDD.updatedAt
    delete req.empleadoBDD.__v
    res.status(200).json(req.empleadoBDD)
}
const listarEmpleados = async (req,res)=>{
    const empleados = await Empleado.find({estado:true}).where('empleado').equals(req.empleadoBDD).select("-createdAt -updatedAt -__v").populate('_id nombre apellido cedula telefono direccion email usuario password token')
    res.status(200).json(empleados)
}
const detalleEmpleado = async(req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Empleado ${id}`});
    const empleado = await Empleado.findById(id).select("-createdAt -updatedAt -__v").populate('_id nombre apellido cedula telefono direccion email usuario password token')
    res.status(200).json(empleado)
}
const registrarEmpleado = async(req,res)=>{
    const {cedula,email,username,password} = req.body
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const verificarCedulaBDD = await Empleado.findOne({cedula})
    if(verificarCedulaBDD) return res.status(400).json({msg:"Lo sentimos, la cédula ya se encuentra registrada"})
    const verificarEmailBDD = await Empleado.findOne({email})
    if(verificarEmailBDD) return res.status(400).json({msg:"Lo sentimos, el correo ya se encuentra registrado"})
    const verificarUsuarioBDD = await Empleado.findOne({username})
    if(verificarUsuarioBDD) return res.status(400).json({msg:"Lo sentimos, el usuario ya se encuentra registrado"})
    const nuevoEmpleado = new Empleado(req.body)
    nuevoEmpleado.password = await nuevoEmpleado.encrypPassword(password)

    const token = nuevoEmpleado.crearToken()
    await sendMailToEmpleado(email,token)
    await nuevoEmpleado.save()
    res.status(200).json({msg:"Revisa tu correo electrónico para confirmar tu cuenta"})
}

const confirmEmailEmpleado = async (req,res)=>{
    if(!(req.params.token)) return res.status(400).json({msg:"Lo sentimos, no se puede validar la cuenta"})
    const empleadoBDD = await Empleado.findOne({token:req.params.token})
    if(!empleadoBDD?.token) return res.status(404).json({msg:"La cuenta ya ha sido confirmada"})
    // Obtener el nombre de usuario registrado
    const username = empleadoBDD.username;
    empleadoBDD.token = null
    empleadoBDD.confirmEmail=true
    await empleadoBDD.save()
    res.status(200).json({msg:"Correo confirmado, ya puedes iniciar sesión con el usuario:", username}) 
}

const actualizarPasswordEmpleado = async (req,res)=>{
    const empleadoBDD = await Empleado.findById(req.empleadoBDD._id)
    if(!empleadoBDD) return res.status(404).json({msg:`Lo sentimos, no existe el empleado ${id}`})
    const verificarPassword = await empleadoBDD.matchPassword(req.body.passwordactual)
    if(!verificarPassword) return res.status(404).json({msg:"Lo sentimos, el password actual no es el correcto"})
    empleadoBDD.password = await empleadoBDD.encrypPassword(req.body.passwordnuevo)
    await empleadoBDD.save()
    res.status(200).json({msg:"Password actualizado correctamente"})
}

const recuperarPasswordEmpleado = async(req,res)=>{
    const {email} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const empleadoBDD = await Empleado.findOne({email})
    if(!empleadoBDD) return res.status(404).json({msg:"Lo sentimos, el empleado no se encuentra registrado"})
    const token = empleadoBDD.crearTokenPassword()
    empleadoBDD.token=token
    await sendMailToRecoveryPasswordEmpleado(email,token)
    await empleadoBDD.save()
    res.status(200).json({msg:"Revisa tu correo electrónico para reestablecer tu cuenta"})
}

const nuevoPasswordEmpleado = async (req,res)=>{
    const{token,password,confirmpassword} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if(password != confirmpassword) return res.status(404).json({msg:"Lo sentimos, los passwords no coinciden"})
    const empleadoBDD = await Empleado.findOne({token})
    if(empleadoBDD?.token !== token) return res.status(404).json({msg:"Lo sentimos, el token es incorrecto"})
    empleadoBDD.token = null
    empleadoBDD.password = await empleadoBDD.encrypPassword(password)
    await empleadoBDD.save()
    res.status(200).json({msg:"Felicitaciones, ya puedes iniciar sesión con tu nuevo password"}) 
}

const recuperarUsernameEmpleado = async(req,res)=>{
    const {email} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const empleadoBDD = await Empleado.findOne({email})
    if(!empleadoBDD) return res.status(404).json({msg:"Lo sentimos, el empleado no se encuentra registrado"})
    await sendMailToRecoveryUsernameEmpleado(empleadoBDD.username, email)
    res.status(200).json({msg:"Revisa tu correo electrónico para recuperar tu nombre de usuario"})
}

const actualizarEmpleado = async (req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, debe ser un id válido`});
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const empleadoBDD = await Empleado.findById(id)
    if(!empleadoBDD) return res.status(404).json({msg:`Lo sentimos, no existe el empleado ${id}`})
    if (empleadoBDD.email !=  req.body.email)
    {
        const empleadoBDDMail = await Empleado.findOne({email:req.body.email})
        if (empleadoBDDMail)
        {
            return res.status(404).json({msg:`Lo sentimos, el correo ya se encuentra registrado`})  
        }
    }
    if (empleadoBDD.username !=  req.body.username)
    {
        const empleadoBDDUsername = await Empleado.findOne({username:req.body.username})
        if (empleadoBDDUsername)
        {
            return res.status(404).json({msg:`Lo sentimos, el username ya se encuentra registrado`})  
        }
    }
    empleadoBDD.nombre = req.body.nombre || empleadoBDD?.nombre
    empleadoBDD.apellido = req.body.apellido  || empleadoBDD?.apellido
    empleadoBDD.cedula = req.body.cedula  || empleadoBDD?.cedula
    empleadoBDD.telefono = req.body.telefono  || empleadoBDD?.telefono
    empleadoBDD.direccion = req.body.direccion  || empleadoBDD?.direccion
    empleadoBDD.email = req.body.email || empleadoBDD?.email
    empleadoBDD.username = req.body.username || empleadoBDD?.username
    await empleadoBDD.save()
    res.status(200).json({msg:"Empleado actualizado correctamente"})
}
/*
const actualizarEmpleado = async(req,res)=>{
    const {id} = req.params
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Empleado ${id}`});
    await Empleado.findByIdAndUpdate(req.params.id,req.body)
    res.status(200).json({msg:"Actualización exitosa del Empleado"})
}*/

const eliminarEmpleado = async (req,res)=>{
    const {id} = req.params
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, no existe el Empleado ${id}`})
    const {salida} = req.body
    await Empleado.findByIdAndUpdate(req.params.id,{salida:Date.parse(salida),estado:false});
    res.status(200).json({msg:"Fecha de salida del Empleado registrado exitosamente"})
}

export {
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
}