const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure email transport using Gmail or any SMTP service
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "sonryan82@gmail.com",       // Gmail account
    pass: "@Aptech123",          // App password (Google recommended)
  },
});

exports.sendOrderConfirmationEmail = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();
    if (!order) return;

    const email = order.userEmail; // user email
    const orderId = context.params.orderId;

    const mailOptions = {
      from: '"LaptopHarbor" <sonryan82@gmail.com>',
      to: email,
      subject: `Order Confirmation - ${orderId}`,
      html: `
        <h3>Thank you for your order!</h3>
        <p>Order ID: <b>${orderId}</b></p>
        <p>Total Amount: <b>${order.totalAmount} RS</b></p>
        <p>We will notify you once your order is shipped.</p>
        <p>Regards,<br>LaptopHarbor Team</p>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log("Order confirmation email sent to:", email);
    } catch (error) {
      console.error("Error sending email:", error);
    }
  });
