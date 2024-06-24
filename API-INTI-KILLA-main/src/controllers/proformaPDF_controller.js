import PdfkitConstruct from 'pdfkit-construct';
import path from 'path';
import fs from 'fs';
import Proforma from '../models/Proforma.js';
import Cliente from '../models/Cliente.js';

export const generatePdf = async (req, res) => {
  const { id } = req.params;

  try {
    const proforma = await Proforma.findById(id);
    if (!proforma) {
      return res.status(404).json({ msg: "Proforma no encontrada" });
    }

    // Obtener los datos del cliente desde la base de datos
    const cliente = await Cliente.findById(proforma.id_cliente);
    if (!cliente) {
      return res.status(404).json({ msg: "Cliente no encontrado" });
    }

    const __dirname = path.resolve();

    // Ruta del logo de la empresa
    const logoPath = path.join(__dirname, 'src', 'public', 'INTI-KILLA-LOGO.png');

    // Crear un nuevo documento PDF
    const doc = new PdfkitConstruct({
      size: 'A4',
      margins: { top: 50, left: 50, right: 50, bottom: 50 },
      bufferPages: true, // Habilitar buffer de páginas para encabezado y pie de página en todas las páginas
    });

    // Agregar el logo de la empresa en la esquina superior izquierda
    doc.image(logoPath, 50, 50, { width: 100 });

    doc.setDocumentHeader({
      height: '33%'
    },() => {
      /*
      doc.fontSize(15).text('INTI KILLA', {
        width: 420,
        align: 'center'
      });*/

      // Agregar información de la empresa
      doc.fontSize(24)
      .text("INTI KILLA", 200, 60, { bold: true })
      .fontSize(12)
      .text("RUC: 1708978539001", 200, 85)
      .text("EMAIL: intikilla@gmail.com", 200, 100)
      .text("DIRECCION: RICARDO IZURIETA E20-353 Y E20F", 200, 115);

      // PROFORMA NUMERO
      doc.fontSize(16)
        .text(`PROFORMA: ${proforma.secuencial}`, 60 , 160, { bold: true })
        .moveDown(0.2)
        .fontSize(12)
        .text(`FECHA: ${new Date(proforma.fechaEmision).toLocaleDateString()}`)
        .moveDown(1);

      // DATOS DEL CLIENTE
      doc.fontSize(16)
      .text("DATOS DEL CLIENTE", { bold: true })
      .moveDown(0.2)
      .fontSize(12)
      .text(`Nombre: ${cliente.nombre}`)
      .text(`Cédula: ${cliente.cedula}`)
      .text(`Teléfono: ${cliente.telefono}`)
      .text(`Dirección: ${cliente.direccion}`)
      .text(`Email: ${cliente.email}`)
    })


    // Agregar una tabla para los productos
    doc.addTable(
      [
        { key: 'codigo', label: 'CODIGO', align: 'left' },
        { key: 'nombre', label: '                      CONCEPTO                      ', align: 'left' },
        { key: 'cantidad', label: 'CANTIDAD', align: 'center' },
        { key: 'precioUnitario', label: 'PRECIO UNITARIO', align: 'center' },
        { key: 'total', label: 'TOTAL', align: 'right' }
      ],
      proforma.productos.map(producto => ({
        codigo: producto.codigo,
        nombre: producto.nombre,
        cantidad: producto.cantidad,
        precioUnitario: producto.precioUnitario.toFixed(2),
        total: (producto.precioUnitario * producto.cantidad).toFixed(2)
      })),
      {
        cellsPadding:10,
        marginLeft: 20,
        marginRight: 20,
        headAlign: 'center',
        width: 'fill_body', // Cambiar el ancho de la tabla a automático
      }
    );

     // Agregar una tabla para los totales
     doc.addTable(
      [
        { key: 'label', label: '', align: 'left' },
        { key: 'value', label: '', align: 'right' }
      ],
      [
        { label: 'Subtotal', value: `${proforma.totalSinImpuestos.toFixed(2)}` },
        { label: 'Descuento', value: `${proforma.totalDescuento.toFixed(2)}` },
        { label: 'IVA 15%', value: `${proforma.totalImpuestoValor.toFixed(2)}` },
        { label: 'Total', value: `${proforma.importeTotal.toFixed(2)}` }
      ],
      {
        headBackground : '#FFFFFF',
        headColor : '#FFFFFF',
        head: false,
        marginLeft: 330,
        marginRight: 20,
        headAlign: 'center',
        width: 'fill_body',
        border: {size: 0.1, color: '#cdcdcd'},
        striped: true,
        stripedColors: ["#FFFFFF", "#FFFFFF"],
        //headFont: "Helvetica-Bold",
        headFontSize: 10,
        //cellsFont: "Helvetica",
        cellsFontSize: 9,
        cellsAlign: 'right',
      }
    );

    // Renderizar tablas
    doc.render();

    // Crear un buffer en lugar de un archivo en disco
    const buffers = [];
    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {
      const pdfData = Buffer.concat(buffers);
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename=proforma_${proforma.secuencial}.pdf`);
      res.send(pdfData);
    });
    doc.end();

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error en el servidor' });
  }
};
