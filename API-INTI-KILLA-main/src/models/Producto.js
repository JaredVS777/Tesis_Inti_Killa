import {Schema, model} from 'mongoose'

const productoSchema = new Schema({
    codigo:{
        type:Number,
        require:true,
        trim:true,
        unique:true
    },
    nombre:{
        type:String,
        require:true,
        trim:true,
        unique:true
    },
    precio_unitario:{
        type:Number,
        require:true,
        trim:true
    },
    cantidad:{
        type:Number,
        require:true,
        trim:true
    }

},{
    timestamps:true
})

export default model('Producto', productoSchema)