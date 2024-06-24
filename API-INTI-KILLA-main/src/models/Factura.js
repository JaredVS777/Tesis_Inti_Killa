import {Schema, model} from 'mongoose'
import mongoose from 'mongoose'

const facturaSchema = new Schema({
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
    claveAcceso: {
        type: String,
        required: true,
        trim: true,
        unique: true
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
    },
    pagoTotal: {
        type: Number,
        required: true
    },
    formaPago: {
        type: String,
        required: true,
        trim: true
    }
    
},{
    timestamps:true
})

export default model('Factura',facturaSchema)