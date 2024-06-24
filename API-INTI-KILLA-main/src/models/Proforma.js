import {Schema, model} from 'mongoose'
import mongoose from 'mongoose'

const proformaSchema = new Schema({
    id_cliente:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'Cliente'
    },
    id_empleado:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'Empleado'
    },
    secuencial: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    fechaEmision: {
        type: Date,
        required: true
    },
    productos: [{
        codigo: String,
        nombre: String,
        cantidad: Number,
        precioUnitario: Number
    }],
    totalSinImpuestos: {
        type: Number,
        required: true
    },
    totalDescuento: {
        type: Number,
        required: true
    },
    totalImpuestoValor: {
        type: Number,
        required: true
    },
    importeTotal: {
        type: Number,
        required: true
    }
    
},{
    timestamps:true
})

export default model('Proforma',proformaSchema)