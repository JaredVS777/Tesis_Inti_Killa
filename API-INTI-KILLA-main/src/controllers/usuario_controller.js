import Usuario from "../models/Usuario.js";
import generarJWT from "../helpers/crearJWT.js"
import mongoose from "mongoose";
import { sendMailToUser, sendMailToRecoveryPassword, sendMailToRecoveryUsername } from "../config/nodemailer.js"

const login = async(req,res)=>{
    const {username,password} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const usuarioBDD = await Usuario.findOne({username}).select("-__v -token -updatedAt -createdAt")
    if(!usuarioBDD) return res.status(404).json({msg:"Lo sentimos, el usuario no se encuentra registrado"})
    if(usuarioBDD?.confirmEmail===false) return res.status(403).json({msg:"Lo sentimos, debe verificar su cuenta"})
    if(usuarioBDD?.status===false) return res.status(402).json({msg:"Lo sentimos, pero su usuario no se encuantra activado"})
    const verificarPassword = await usuarioBDD.matchPassword(password)
    if(!verificarPassword) return res.status(404).json({msg:"Lo sentimos, el password no es el correcto"})
    const token = generarJWT(usuarioBDD._id,"usuario")
    const {nombre,apellido,_id} = usuarioBDD
    res.status(200).json({
        token,
        nombre,
        apellido,
        username,
        _id,
        email:usuarioBDD.email
    })
}

const perfil =(req,res)=>{
    delete req.usuarioBDD.token
    delete req.usuarioBDD.confirmEmail
    delete req.usuarioBDD.createdAt
    delete req.usuarioBDD.updatedAt
    delete req.usuarioBDD.__v
    res.status(200).json(req.usuarioBDD)
}

const registro =async (req,res)=>{
    // Desestructura los campos
    const {email,password,username} = req.body
    // Validar todos los campos llenos
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    // Obtener el usuario de la BDD en base al email
    const verificarEmailBDD = await Usuario.findOne({email})
    // Validar que el email sea nuevo
    if(verificarEmailBDD) return res.status(400).json({msg:"Lo sentimos, el email ya se encuentra registrado"})
    // Obtener el usuario de la BDD en base al nombre de usuario
    const verificarUsernameBDD = await Usuario.findOne({username})
    // Validar que el nombre de usuario sea nuevo
    if(verificarUsernameBDD) return res.status(400).json({msg:"Lo sentimos, el nombre de usuario ya se encuentra registrado"})
    // Crear una instancia del Usuario
    const nuevoUsuario = new Usuario(req.body)
    // Encriptar el password
    nuevoUsuario.password = await nuevoUsuario.encrypPassword(password)

    const token = nuevoUsuario.crearToken()
    await sendMailToUser(email,token)
    await nuevoUsuario.save()
    res.status(200).json({msg:"Revisa tu correo electrónico para confirmar tu cuenta"})
}

const confirmEmail = async (req,res)=>{
    if(!(req.params.token)) return res.status(400).json({msg:"Lo sentimos, no se puede validar la cuenta"})
    const usuarioBDD = await Usuario.findOne({token:req.params.token})
    if(!usuarioBDD?.token) return res.status(404).json({msg:"La cuenta ya ha sido confirmada"})
    // Obtener el nombre de usuario registrado
    const username = usuarioBDD.username;
    usuarioBDD.token = null
    usuarioBDD.confirmEmail=true
    await usuarioBDD.save()
    res.status(200).json({msg:"Correo confirmado, ya puedes iniciar sesión con el usuario:", username}) 
}

const detalleUsuario = async(req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, debe ser un id válido`});
    const usuarioBDD = await Usuario.findById(id).select("-password")
    if(!usuarioBDD) return res.status(404).json({msg:`Lo sentimos, no existe el Usuario ${id}`})
    res.status(200).json({msg:usuarioBDD})
}

const actualizarPassword = async (req,res)=>{
    const usuarioBDD = await Usuario.findById(req.usuarioBDD._id)
    if(!usuarioBDD) return res.status(404).json({msg:`Lo sentimos, no existe el usuario ${id}`})
    const verificarPassword = await usuarioBDD.matchPassword(req.body.passwordactual)
    if(!verificarPassword) return res.status(404).json({msg:"Lo sentimos, el password actual no es el correcto"})
    usuarioBDD.password = await usuarioBDD.encrypPassword(req.body.passwordnuevo)
    await usuarioBDD.save()
    res.status(200).json({msg:"Password actualizado correctamente"})
}
const recuperarPassword = async(req,res)=>{
    const {email} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const usuarioBDD = await Usuario.findOne({email})
    if(!usuarioBDD) return res.status(404).json({msg:"Lo sentimos, el usuario no se encuentra registrado"})
    const token = usuarioBDD.crearToken()
    usuarioBDD.token=token
    await sendMailToRecoveryPassword(email,token)
    await usuarioBDD.save()
    res.status(200).json({msg:"Revisa tu correo electrónico para reestablecer tu cuenta"})
}


const comprobarTokenPasword = async (req,res)=>{
    if(!(req.params.token)) return res.status(404).json({msg:"Lo sentimos, no se puede validar la cuenta"})
    const usuarioBDD = await Usuario.findOne({token:req.params.token})
    if(usuarioBDD?.token !== req.params.token) return res.status(404).json({msg:"Lo sentimos, no se puede validar la cuenta"})
    await usuarioBDD.save()
    res.status(200).json({msg:"Token confirmado, ya puedes crear tu nuevo password"}) 
}


const nuevoPassword = async (req,res)=>{
    const{password,confirmpassword} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    if(password != confirmpassword) return res.status(404).json({msg:"Lo sentimos, los passwords no coinciden"})
    const usuarioBDD = await Usuario.findOne({token:req.params.token})
    if(usuarioBDD?.token !== req.params.token) return res.status(404).json({msg:"Lo sentimos, no se puede validar la cuenta"})
    usuarioBDD.token = null
    usuarioBDD.password = await usuarioBDD.encrypPassword(password)
    await usuarioBDD.save()
    res.status(200).json({msg:"Felicitaciones, ya puedes iniciar sesión con tu nuevo password"}) 
}

const recuperarUsername = async(req,res)=>{
    const {email} = req.body
    if (Object.values(req.body).includes("")) return res.status(404).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const usuarioBDD = await Usuario.findOne({email})
    if(!usuarioBDD) return res.status(404).json({msg:"Lo sentimos, el usuario no se encuentra registrado"})
    await sendMailToRecoveryUsername(usuarioBDD.username, email)
    res.status(200).json({msg:"Revisa tu correo electrónico para recuperar tu nombre de usuario"})
}

const actualizarPerfil = async (req,res)=>{
    const {id} = req.params
    if( !mongoose.Types.ObjectId.isValid(id) ) return res.status(404).json({msg:`Lo sentimos, debe ser un id válido`});
    if (Object.values(req.body).includes("")) return res.status(400).json({msg:"Lo sentimos, debes llenar todos los campos"})
    const usuarioBDD = await Usuario.findById(id)
    if(!usuarioBDD) return res.status(404).json({msg:`Lo sentimos, no existe el usuario ${id}`})
    if (usuarioBDD.email !=  req.body.email)
    {
        const usuarioBDDMail = await Usuario.findOne({email:req.body.email})
        if (usuarioBDDMail)
        {
            return res.status(404).json({msg:`Lo sentimos, el correo ya se encuentra registrado`})  
        }
    }
    if (usuarioBDD.username !=  req.body.username)
    {
        const usuarioBDDUsername = await Usuario.findOne({username:req.body.username})
        if (usuarioBDDUsername)
        {
            return res.status(404).json({msg:`Lo sentimos, el username ya se encuentra registrado`})  
        }
    }
		usuarioBDD.nombre = req.body.nombre || usuarioBDD?.nombre
    usuarioBDD.apellido = req.body.apellido  || usuarioBDD?.apellido
    usuarioBDD.email = req.body.email || usuarioBDD?.email
    usuarioBDD.username = req.body.username || usuarioBDD?.username
    await usuarioBDD.save()
    res.status(200).json({msg:"Perfil actualizado correctamente"})
}

export{
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
}