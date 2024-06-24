import { check, validationResult } from 'express-validator'

const validacionFactura =[
    check("id_cliente")
        .exists().withMessage('El campo "id_cliente" es obligatorio')
        .notEmpty().withMessage('El campo "id_cliente" no puede estar vacío')
        .isMongoId().withMessage('El campo "id_cliente" debe ser un ID de MongoDB válido'),

    check("id_empleado")
        .exists().withMessage('El campo "id_empleado" es obligatorio')
        .notEmpty().withMessage('El campo "id_empleado" no puede estar vacío')
        .isMongoId().withMessage('El campo "id_empleado" debe ser un ID de MongoDB válido'),

    check("products")
        .isArray({ min: 1 }).withMessage('El campo "products" debe ser un arreglo con al menos un producto'),

    check("products.*.codigo")
        .exists().withMessage('El campo "codigo" es obligatorio')
        .notEmpty().withMessage('El campo "codigo" no puede estar vacío')
        .isString().withMessage('El campo "codigo" debe ser una cadena de texto'),

    check("products.*.nombre")
        .exists().withMessage('El campo "nombre" es obligatorio')
        .notEmpty().withMessage('El campo "nombre" no puede estar vacío')
        .isString().withMessage('El campo "nombre" debe ser una cadena de texto'),

    check("products.*.cantidad")
        .exists().withMessage('El campo "cantidad" es obligatorio')
        .notEmpty().withMessage('El campo "cantidad" no puede estar vacío')
        .isInt({ min: 1 }).withMessage('El campo "cantidad" debe ser un número entero mayor a 0'),

    check("products.*.precioUnitario")
        .exists().withMessage('El campo "precioUnitario" es obligatorio')
        .notEmpty().withMessage('El campo "precioUnitario" no puede estar vacío')
        .isFloat({ min: 0 }).withMessage('El campo "precioUnitario" debe ser un número decimal mayor o igual a 0'),

    check("totalSinImpuestos")
        .exists().withMessage('El campo "totalSinImpuestos" es obligatorio')
        .notEmpty().withMessage('El campo "totalSinImpuestos" no puede estar vacío')
        .isFloat({ min: 0 }).withMessage('El campo "totalSinImpuestos" debe ser un número decimal mayor o igual a 0'),

    check("totalDescuento")
        .exists().withMessage('El campo "totalDescuento" es obligatorio')
        .notEmpty().withMessage('El campo "totalDescuento" no puede estar vacío')
        .isFloat({ min: 0 }).withMessage('El campo "totalDescuento" debe ser un número decimal mayor o igual a 0'),

    check("totalImpuestoValor")
        .exists().withMessage('El campo "totalImpuestoValor" es obligatorio')
        .notEmpty().withMessage('El campo "totalImpuestoValor" no puede estar vacío')
        .isFloat({ min: 0 }).withMessage('El campo "totalImpuestoValor" debe ser un número decimal mayor o igual a 0'),

    check("importeTotal")
        .exists().withMessage('El campo "importeTotal" es obligatorio')
        .notEmpty().withMessage('El campo "importeTotal" no puede estar vacío')
        .isFloat({ min: 0 }).withMessage('El campo "importeTotal" debe ser un número decimal mayor o igual a 0'),

    check("pagoTotal")
        .exists().withMessage('El campo "pagoTotal" es obligatorio')
        .notEmpty().withMessage('El campo "pagoTotal" no puede estar vacío')
        .isFloat({ min: 0 }).withMessage('El campo "pagoTotal" debe ser un número decimal mayor o igual a 0'),

    check("formaPago")
        .exists().withMessage('El campo "formaPago" es obligatorio')
        .notEmpty().withMessage('El campo "formaPago" no puede estar vacío')
        .isString().withMessage('El campo "formaPago" debe ser una cadena de texto'),


    (req,res,next)=>{
        const errors = validationResult(req);
        if (errors.isEmpty()) {
            return next();
        } else {
            return res.status(400).send({ errors: errors.array() });
        }
    }
]

export {
    validacionFactura
}