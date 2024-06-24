import PdfkitConstruct from 'pdfkit-construct';
import path from 'path';
import fs from 'fs';
import Cliente from '../models/Cliente.js';
import Factura from '../models/Factura.js';

const generatePdf = async (req, res) => {
  const { id } = req.params;

  try {
    const factura = await Factura.findById(id);
    if (!factura) {
      return res.status(404).json({ msg: "Factura no encontrada" });
    }

    const cliente = await Cliente.findById(factura.id_cliente);
    if (!cliente) {
      return res.status(404).json({ msg: "Cliente no encontrado" });
    }

    const __dirname = path.resolve();
    const logoPath = path.join(__dirname, 'src', 'public', 'INTI-KILLA-LOGO.png');

    const doc = new PdfkitConstruct({
      size: 'A4',
      margins: { top: 50, left: 50, right: 50, bottom: 50 },
      bufferPages: true,
    });

    doc.image(logoPath, 50, 50, { width: 100 });

    doc.setDocumentHeader({
      height: '35%'
    },() => {
      doc.fontSize(24)
        .text("INTI KILLA", 200, 60, { bold: true })
        .fontSize(12)
        .text("RUC: 1708978539001", 200, 85)
        .text("EMAIL: intikilla@gmail.com", 200, 100)
        .text("DIRECCION: RICARDO IZURIETA E20-353 Y E20F", 200, 115);

      doc.fontSize(16)
        .text(`FACTURA: ${factura.secuencial}`, 60 , 160, { bold: true })
        .moveDown(0.2)
        .fontSize(12)
        .text(`CLAVE DE ACCESO: ${factura.claveAcceso}`, { bold: true })
        .moveDown(0.2)
        .text(`FECHA: ${new Date(factura.fechaEmision).toLocaleDateString()}`)
        .moveDown(1);

      doc.fontSize(16)
        .text("DATOS DEL CLIENTE", { bold: true })
        .moveDown(0.2)
        .fontSize(12)
        .text(`Nombre: ${cliente.nombre}`)
        .text(`Cédula: ${cliente.cedula}`)
        .text(`Teléfono: ${cliente.telefono}`)
        .text(`Dirección: ${cliente.direccion}`)
        .text(`Email: ${cliente.email}`);
    });

    doc.addTable(
      [
        { key: 'codigo', label: 'CODIGO', align: 'left' },
        { key: 'nombre', label: '                      CONCEPTO                      ', align: 'left' },
        { key: 'cantidad', label: 'CANTIDAD', align: 'center' },
        { key: 'precioUnitario', label: 'PRECIO UNITARIO', align: 'center' },
        { key: 'total', label: 'TOTAL', align: 'right' }
      ],
      factura.productos.map(producto => ({
        codigo: producto.codigo,
        nombre: producto.nombre,
        cantidad: producto.cantidad,
        precioUnitario: producto.precioUnitario.toFixed(2),
        total: (producto.precioUnitario * producto.cantidad).toFixed(2)
      })),
      {
        cellsPadding: 10,
        marginLeft: 20,
        marginRight: 20,
        headAlign: 'center',
        width: 'fill_body',
      }
    );

    doc.addTable(
      [
        { key: 'label', label: '', align: 'left' },
        { key: 'value', label: '', align: 'right' }
      ],
      [
        { label: 'Subtotal', value: `${factura.totalSinImpuestos.toFixed(2)}` },
        { label: 'Descuento', value: `${factura.totalDescuento.toFixed(2)}` },
        { label: 'IVA 15%', value: `${factura.totalImpuestoValor.toFixed(2)}` },
        { label: 'Total', value: `${factura.importeTotal.toFixed(2)}` }
      ],
      {
        headBackground : '#FFFFFF',
        headColor : '#FFFFFF',
        head: false,
        marginLeft: 330,
        marginRight: 20,
        headAlign: 'center',
        width: 'fill_body',
        border: { size: 0.1, color: '#cdcdcd' },
        striped: true,
        stripedColors: ["#FFFFFF", "#FFFFFF"],
        headFontSize: 10,
        cellsFontSize: 9,
        cellsAlign: 'right',
      }
    );

    doc.render();

    // Crear un buffer en lugar de un archivo en disco
    const buffers = [];
    doc.on('data', buffers.push.bind(buffers));
    doc.on('end', () => {
      const pdfData = Buffer.concat(buffers);
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename=factura_${factura.secuencial}.pdf`);
      res.send(pdfData);
    });

    doc.end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error en el servidor' });
  }
};

const generatePdfMail = async (id) => {
  return new Promise(async (resolve, reject) => {

    try {
      const factura = await Factura.findById(id);
      if (!factura) {
        return res.status(404).json({ msg: "Factura no encontrada" });
      }

      const cliente = await Cliente.findById(factura.id_cliente);
      if (!cliente) {
        return res.status(404).json({ msg: "Cliente no encontrado" });
      }

      const __dirname = path.resolve();
      const logoPath = path.join(__dirname, 'src', 'public', 'INTI-KILLA-LOGO.png');

      const doc = new PdfkitConstruct({
        size: 'A4',
        margins: { top: 50, left: 50, right: 50, bottom: 50 },
        bufferPages: true,
      });

      doc.image(logoPath, 50, 50, { width: 100 });

      doc.setDocumentHeader({
        height: '35%'
      },() => {
        doc.fontSize(24)
          .text("INTI KILLA", 200, 60, { bold: true })
          .fontSize(12)
          .text("RUC: 1708978539001", 200, 85)
          .text("EMAIL: intikilla@gmail.com", 200, 100)
          .text("DIRECCION: RICARDO IZURIETA E20-353 Y E20F", 200, 115);

        doc.fontSize(16)
          .text(`FACTURA: ${factura.secuencial}`, 60 , 160, { bold: true })
          .moveDown(0.2)
          .fontSize(12)
          .text(`CLAVE DE ACCESO: ${factura.claveAcceso}`, { bold: true })
          .moveDown(0.2)
          .text(`FECHA: ${new Date(factura.fechaEmision).toLocaleDateString()}`)
          .moveDown(1);

        doc.fontSize(16)
          .text("DATOS DEL CLIENTE", { bold: true })
          .moveDown(0.2)
          .fontSize(12)
          .text(`Nombre: ${cliente.nombre}`)
          .text(`Cédula: ${cliente.cedula}`)
          .text(`Teléfono: ${cliente.telefono}`)
          .text(`Dirección: ${cliente.direccion}`)
          .text(`Email: ${cliente.email}`);
      });

      doc.addTable(
        [
          { key: 'codigo', label: 'CODIGO', align: 'left' },
          { key: 'nombre', label: '                      CONCEPTO                      ', align: 'left' },
          { key: 'cantidad', label: 'CANTIDAD', align: 'center' },
          { key: 'precioUnitario', label: 'PRECIO UNITARIO', align: 'center' },
          { key: 'total', label: 'TOTAL', align: 'right' }
        ],
        factura.productos.map(producto => ({
          codigo: producto.codigo,
          nombre: producto.nombre,
          cantidad: producto.cantidad,
          precioUnitario: producto.precioUnitario.toFixed(2),
          total: (producto.precioUnitario * producto.cantidad).toFixed(2)
        })),
        {
          cellsPadding: 10,
          marginLeft: 20,
          marginRight: 20,
          headAlign: 'center',
          width: 'fill_body',
        }
      );

      doc.addTable(
        [
          { key: 'label', label: '', align: 'left' },
          { key: 'value', label: '', align: 'right' }
        ],
        [
          { label: 'Subtotal', value: `${factura.totalSinImpuestos.toFixed(2)}` },
          { label: 'Descuento', value: `${factura.totalDescuento.toFixed(2)}` },
          { label: 'IVA 15%', value: `${factura.totalImpuestoValor.toFixed(2)}` },
          { label: 'Total', value: `${factura.importeTotal.toFixed(2)}` }
        ],
        {
          headBackground : '#FFFFFF',
          headColor : '#FFFFFF',
          head: false,
          marginLeft: 330,
          marginRight: 20,
          headAlign: 'center',
          width: 'fill_body',
          border: { size: 0.1, color: '#cdcdcd' },
          striped: true,
          stripedColors: ["#FFFFFF", "#FFFFFF"],
          headFontSize: 10,
          cellsFontSize: 9,
          cellsAlign: 'right',
        }
      );

      doc.render();
      
      // const pdfPath = path.join(__dirname, 'src', 'public', `invoice_${factura.secuencial}.pdf`);
      const pdfPath = path.join('/tmp', `invoice_${factura.secuencial}.pdf`);
      // Crear un buffer en lugar de un archivo en disco
      const buffers = [];
      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => {
        const pdfData = Buffer.concat(buffers);
        fs.writeFileSync(pdfPath, pdfData); // Guardar el PDF en disco

        resolve(pdfPath); // Resolver con el path del archivo PDF generado
      });

      doc.end();
    } catch (err) {
      console.error(err);
      reject({ status: 500, msg: 'Error en el pdf Factura' });
    }
  });
};

export {
  generatePdf,
  generatePdfMail
};