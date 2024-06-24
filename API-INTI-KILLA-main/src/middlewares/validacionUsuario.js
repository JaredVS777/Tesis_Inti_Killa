import { check, validationResult } from 'express-validator'

const validacionUsuario =[
    check(["nombre","apellido","email","password", "username"])
        .exists()
            .withMessage('Los campos "nombre" "apellido" "email" "username" y/o "password" son obligatorios')
        .notEmpty()
            .withMessage('Los campos "nombre" "apellido" "email" "username" y/o "password" no pueden estar vacíos')
        .customSanitizer(value => value?.trim()),

    check(["nombre","apellido"])
        .isLength({ min: 3, max: 12 })
            .withMessage('El campo "nombre" y/o "apellido" debe(n) tener entre 3 y 12 caracteres')
        .isAlpha('es-ES', { ignore: 'áéíóúÁÉÍÓÚñÑ' })
            .withMessage('El campo "nombre" y/o "apellido" debe(n) contener solo letras')
        .customSanitizer(value => value?.trim()),

    check("email")
        .isEmail()
            .withMessage('El campo "email" no es correcto')
        .customSanitizer(value => value?.trim()),

    check("password")
        .isLength({ min: 5 })
            .withMessage('El campo "password" debe tener al menos 5 caracteres')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*).*$/)
            .withMessage('El campo "password" debe contener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial')
        .customSanitizer(value => value?.trim()),


    (req,res,next)=>{
        const errors = validationResult(req);
        if (errors.isEmpty()) {
            return next();
        } else {
            return res.status(400).send({ errors: errors.array() });
        }
    }
]

const validacionEmail =[
    check(["email"])
        .exists()
            .withMessage('El campo de "email" es obligatorio')
        .notEmpty()
            .withMessage('El campo de "email" no puede estar vacío')
        .isEmail()
            .withMessage('El campo "email" no es correcto')
        .customSanitizer(value => value?.trim()),

    (req,res,next)=>{
        const errors = validationResult(req);
        if (errors.isEmpty()) {
            return next();
        } else {
            return res.status(400).send({ errors: errors.array() });
        }
    }
]

const validacionNuevoPassword =[
    check(["password", "confirmpassword"])
        .exists()
            .withMessage('Los campos "password" y/o "confirmpassword" son obligatorios')
        .notEmpty()
            .withMessage('Los campos "password" y/o "confirmpassword" no pueden estar vacíos')
        .isLength({ min: 5 })
            .withMessage('El campo "password" debe tener al menos 5 caracteres')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*).*$/)
            .withMessage('El campo "password" debe contener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial')
        .customSanitizer(value => value?.trim()),

    (req,res,next)=>{
        const errors = validationResult(req);
        if (errors.isEmpty()) {
            return next();
        } else {
            return res.status(400).send({ errors: errors.array() });
        }
    }
]

const validacionLogin =[
    check(["username", "password"])
        .exists()
            .withMessage('Los campos "username" y/o "password" son obligatorios')
        .notEmpty()
            .withMessage('Los campos "username" y/o "password" no pueden estar vacíos')
        .customSanitizer(value => value?.trim()),

    (req,res,next)=>{
        const errors = validationResult(req);
        if (errors.isEmpty()) {
            return next();
        } else {
            return res.status(400).send({ errors: errors.array() });
        }
    }
]

const validacionActualizarPassword =[
    check(["passwordactual", "passwordnuevo"])
        .exists()
            .withMessage('Los campos "passwordactual" y/o "passwordnuevo" son obligatorios')
        .notEmpty()
            .withMessage('Los campos "passwordactual" y/o "passwordnuevo" no pueden estar vacíos')
        .customSanitizer(value => value?.trim()),

    check(["passwordnuevo"])
        .isLength({ min: 5 })
            .withMessage('El campo "passwordnuevo" debe tener al menos 5 caracteres')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*).*$/)
            .withMessage('El campo "passwordnuevo" debe contener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial')
        .customSanitizer(value => value?.trim()),

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
    validacionUsuario,
    validacionEmail,
    validacionNuevoPassword,
    validacionLogin,
    validacionActualizarPassword
}