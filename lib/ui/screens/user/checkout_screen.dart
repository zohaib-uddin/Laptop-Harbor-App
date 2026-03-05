import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:line_icons/line_icons.dart';
import '../../../models/cart_item.dart';
import '../../../models/order_item.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../screens/auth/login_screen.dart';
import '../user/cart_screen.dart';
import '../user/orders_list_screen.dart';
import '../user/profile_screen.dart';
import '../user/wishlist_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping Info
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _shippingAddress = TextEditingController();
  final _city = TextEditingController();

  // Billing Info
  final _billingName = TextEditingController();
  final _billingAddress = TextEditingController();

  String _paymentMethod = "COD"; // default
  bool _isPlacing = false;

  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // ---------- Amount Calculation ----------
  double get shippingFee => 200;
  double get tax => widget.total * 0.05; // 5% GST
  double get grandTotal => widget.total + tax + shippingFee;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _shippingAddress.dispose();
    _city.dispose();
    _billingName.dispose();
    _billingAddress.dispose();
    super.dispose();
  }

  // ---------- Place Order ----------
  Future<void> _placeOrder() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);

    try {
      final items = widget.items
          .map(
            (c) => OrderItem(
              productId: c.productId,
              name: c.name,
              price: c.price,
              quantity: c.quantity,
              thumbnail: c.thumbnail,
            ),
          )
          .toList();

      final orderId = await _orderService.createOrder(
       userId: _userId,
        //  email: userEmail,               // NEW

  fullName: _name.text.trim(),
  address: _shippingAddress.text.trim(),
  items: items,
  totalAmount: grandTotal,
  paymentMethod: _paymentMethod,
  phone: _phone.text.trim(),
  city: _city.text.trim(),
  billingName: _billingName.text.trim(),
  billingAddress: _billingAddress.text.trim(),
userEmail: FirebaseAuth.instance.currentUser!.email
      );

      await _cartService.clearCart(_userId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order failed. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,

        actions: [
          IconButton(onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()));
          }, icon: const Icon(LineIcons.heart)),

          IconButton(onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen()));
          }, icon: const Icon(LineIcons.shoppingCart)),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------- SHIPPING INFO ----------
              const Text("Shipping Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _shippingAddress,
                decoration: const InputDecoration(labelText: "Shipping Address"),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 25),

              // ---------- BILLING INFO ----------
              const Text("Billing Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              TextFormField(
                controller: _billingName,
                decoration: const InputDecoration(labelText: "Billing Name"),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _billingAddress,
                decoration: const InputDecoration(labelText: "Billing Address"),
                maxLines: 2,
              ),

              const SizedBox(height: 25),

              // ---------- PAYMENT METHOD ----------
              const Text("Payment Method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              RadioListTile(
                value: "COD",
                groupValue: _paymentMethod,
                title: const Text("Cash on Delivery"),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),

              RadioListTile(
                value: "Card",
                groupValue: _paymentMethod,
                title: const Text("Credit / Debit Card"),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),

              RadioListTile(
                value: "JazzCash",
                groupValue: _paymentMethod,
                title: const Text("JazzCash"),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),

              RadioListTile(
                value: "EasyPaisa",
                groupValue: _paymentMethod,
                title: const Text("EasyPaisa"),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),

              const SizedBox(height: 25),

              // ---------- ORDER SUMMARY ----------
              const Text("Order Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _summaryRow("Subtotal", "${widget.total.toStringAsFixed(0)} RS"),
              _summaryRow("Tax (5%)", "${tax.toStringAsFixed(0)} RS"),
              _summaryRow("Shipping Fee", "$shippingFee RS"),
              const Divider(),
              _summaryRow("Total", "${grandTotal.toStringAsFixed(0)} RS",
                  isBold: true, fontSize: 18),

              const SizedBox(height: 25),

              // ---------- ORDER BUTTON ----------
              ElevatedButton(
                onPressed: _isPlacing ? null : _placeOrder,
                child: _isPlacing
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text("Place Order"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),

    );
  }

  Widget _summaryRow(String title, String value,
      {bool isBold = false, double fontSize = 15}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
        ],
      ),
    );
  }
}
