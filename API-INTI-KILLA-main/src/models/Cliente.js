import {Schema, model} from 'mongoose'

const clienteSchema = new Schema({
    nombre:{
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
        trim:true,
        default:null
    },
    tipodoc:{
        type:String,
        trim:true,
        default:null
    }

},{
    timestamps:true
})

export default model('Cliente',clienteSchema)