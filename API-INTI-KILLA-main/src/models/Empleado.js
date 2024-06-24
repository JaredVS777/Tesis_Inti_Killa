import {Schema, model} from 'mongoose'
import bcrypt from "bcryptjs"

const empleadoSchema = new Schema({
    nombre:{
        type:String,
        require:true,
        trim:true
    },
    apellido:{
        type:String,
        require:true,
        trim:true
    },
    cedula:{
        type:String,
        require:true,
        trim:true,
        unique:true
    },
    telefono:{
        type:String,
        trim:true,
        default:null
    },
    direccion:{
        type:String,
        trim:true,
        default:null
    },
    email:{
        type:String,
        require:true,
        trim:true
    },
    username:{
        type:String,
        require:true,
        trim:true
    },
    password:{
        type:String,
        require:true,
        trim:true
    },
    rol:{
        type:String,
        default: "empleado"
    },
    status:{
        type:Boolean,
        default:true
    },
    token:{
        type:String,
        trim:true,
        default:null
    },
    confirmEmail:{
        type:Boolean,
        default:false
    }

},{
    timestamps:true
})

// Método para cifrar el password
empleadoSchema.methods.encrypPassword = async function(password){
    const salt = await bcrypt.genSalt(10)
    const passwordEncryp = await bcrypt.hash(password,salt)
    return passwordEncryp
}

// Método para verificar si el password ingresado es el mismo de la BDD
empleadoSchema.methods.matchPassword = async function(password){
    const response = await bcrypt.compare(password,this.password)
    return response
}

// Método para crear un token 
empleadoSchema.methods.crearToken = function(){
    const tokenGenerado = this.token = Math.random().toString(36).slice(2)
    return tokenGenerado
}

// Método para crear el token para recuperar el password
empleadoSchema.methods.crearTokenPassword = function() {
    const tokenGenerado = Math.floor(100000 + Math.random() * 900000).toString();
    this.token = tokenGenerado;
    return tokenGenerado;
}

export default model('Empleado',empleadoSchema)