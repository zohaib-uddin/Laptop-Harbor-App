// screens/user/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:line_icons/line_icons.dart';
import '../../../models/product.dart';
import '../../../models/cart_item.dart';
import '../../../models/order.dart';
import '../../../services/product_service.dart';
import '../../../services/cart_service.dart';
import '../../../services/wishlist_service.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'orders_list_screen.dart';
import 'profile_screen.dart';
import '../admin/admin_order_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentSlide = 0;
  String? _selectedCategoryId;
  String? _selectedBrandId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _wishlistIds = {};
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Notifications
  List<Order> _unreadOrders = [];

  final List<String> _sliderImages = [
    'https://cdn.store-assets.com/s/358885/f/14170792.jpeg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTirFFFY5Ii12gdOue5naQy4UDj36b2Df9WHw&s',
    'https://www.hp.com/content/dam/sites/worldwide/intel/hero-banner-desk.jpg',
  ];

  @override
  void initState() {
    super.initState();

    if (_userId != null) {
      // Wishlist listener
      _wishlistService.streamWishlistProductIds(_userId!).listen((ids) {
        if (!mounted) return;
        setState(() {
          _wishlistIds.clear();
          _wishlistIds.addAll(ids);
        });
      });

      // Orders stream to check for unread notifications
      _firestore
          .collection('orders')
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .listen((snapshot) async {
        if (!mounted) return;

        List<Order> tempUnread = [];
        for (var doc in snapshot.docs) {
          final order = Order.fromDoc(doc);

          // Get user notification doc
          final notiDoc = await doc.reference
              .collection('userNotifications')
              .doc(_userId)
              .get();

          bool isRead = notiDoc.exists && (notiDoc.data()?['isRead'] ?? false);

          // Only show unread for status != pending
          if (!isRead && order.status != 'pending') {
            tempUnread.add(order);
          }
        }

        setState(() => _unreadOrders = tempUnread);
      });
    }
  }

  Future<void> _markNotificationRead(Order order) async {
    await _firestore
        .collection('orders')
        .doc(order.id)
        .collection('userNotifications')
        .doc(_userId)
        .set({'isRead': true, 'timestamp': FieldValue.serverTimestamp()});
    setState(() => _unreadOrders.remove(order));
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToCart() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  void _goToWishlist() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
  void _goToOrders() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersListScreen()));
  void _goToProfile() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));

  void _selectCategory(String? id) {
    setState(() {
      _selectedCategoryId = (_selectedCategoryId == id) ? null : id;
      _selectedBrandId = null;
    });
  }

  void _selectBrand(String? id) {
    setState(() {
      _selectedBrandId = (_selectedBrandId == id) ? null : id;
      _selectedCategoryId = null;
    });
  }

  Widget _buildCategoriesBar() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('categories').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()));
        }
        final docs = snapshot.data!.docs;
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final id = d.id;
              final name = d['name'] ?? '';
              final selected = _selectedCategoryId == id;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected ? const Color(0xFF5B2C6F) : Colors.grey.shade200,
                    foregroundColor: selected ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: selected ? 3 : 0,
                  ),
                  onPressed: () => _selectCategory(id),
                  child: Text(name),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBrandsBar() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('brands').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()));
        }
        final docs = snapshot.data!.docs;
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              final id = d.id;
              final name = d['name'] ?? '';
              final selected = _selectedBrandId == id;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF5B2C6F)),
                    backgroundColor: selected ? Colors.deepPurple.shade50 : null,
                    foregroundColor: selected ? const Color(0xFF5B2C6F) : Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _selectBrand(id),
                  child: Text(name),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    List<Product> filtered = products;

    if (_selectedCategoryId != null) {
      filtered = filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    } else if (_selectedBrandId != null) {
      filtered = filtered.where((p) => p.brandId == _selectedBrandId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (filtered.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('No products found')),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final p = filtered[index];
            final isInWishlist = _wishlistIds.contains(p.id);

            return ProductCard(
              product: p,
              isInWishlist: isInWishlist,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
              ),
              onAddToCart: _userId == null
                  ? null
                  : () async {
                      await _cartService.addToCart(_userId!, CartItem(
                        productId: p.id,
                        name: p.name,
                        price: p.price,
                        quantity: 1,
                        thumbnail: p.imageUrls.isNotEmpty ? p.imageUrls.first : null,
                      ));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.name} added to cart'), duration: const Duration(seconds: 1)),
                      );
                    },
              onToggleWishlist: _userId == null
                  ? null
                  : () async {
                      if (isInWishlist) {
                        await _wishlistService.removeFromWishlist(_userId!, p.id);
                        _wishlistIds.remove(p.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${p.name} removed from wishlist'), duration: const Duration(seconds: 1)),
                        );
                      } else {
                        await _wishlistService.addToWishlist(_userId!, p.id);
                        _wishlistIds.add(p.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${p.name} added to wishlist'), duration: const Duration(seconds: 1)),
                        );
                      }
                      if (!mounted) return;
                      setState(() {});
                    },
            );
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        title: const Text('Laptop Harbor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(onPressed: _goToWishlist, icon: const Icon(LineIcons.heart)),
          IconButton(onPressed: _goToCart, icon: const Icon(LineIcons.shoppingCart)),

          // Notifications
          Stack(
            children: [
              PopupMenuButton<Order>(
                icon: const Icon(LineIcons.bell),
                tooltip: 'Notifications',
                onSelected: (order) async {
                  await _markNotificationRead(order);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AdminOrderDetailScreen(order: order)));
                },
                itemBuilder: (context) {
                  if (_unreadOrders.isEmpty) {
                    return [
                      const PopupMenuItem(
                        child: Text('No new notifications', style: TextStyle(color: Colors.black54)),
                        enabled: false,
                      ),
                    ];
                  }
                  return _unreadOrders.map((order) {
                    return PopupMenuItem<Order>(
                      value: order,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Order #${order.id.substring(0,6)}: ${order.status}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(LineIcons.angleRight, size: 16, color: Colors.black54),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),

              if (_unreadOrders.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      _unreadOrders.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'orders') _goToOrders();
              if (value == 'profile') _goToProfile();
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'orders',
                child: Row(children: [Icon(LineIcons.shoppingBag, size: 20, color: Colors.black54), SizedBox(width: 8), Text('My Orders')]),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(children: [Icon(LineIcons.user, size: 20, color: Colors.black54), SizedBox(width: 8), Text('Profile')]),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(LineIcons.alternateSignOut, size: 20, color: Colors.black54), SizedBox(width: 8), Text('Logout')]),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Carousel
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                CarouselSlider.builder(
                  itemCount: _sliderImages.length,
                  itemBuilder: (context, index, realIndex) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(_sliderImages[index], width: double.infinity, fit: BoxFit.cover),
                  ),
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) => setState(() => _currentSlide = index),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _sliderImages.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentSlide == index ? const Color(0xFF5B2C6F) : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search laptops, brands...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _buildCategoriesBar(),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Brands
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Brands', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _buildBrandsBar(),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Products Grid
          StreamBuilder<List<Product>>(
            stream: _productService.streamProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              return _buildProductsGrid(snapshot.data!);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
