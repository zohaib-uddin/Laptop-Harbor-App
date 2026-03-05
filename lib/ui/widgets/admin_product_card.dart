import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/widgets/rating_stars.dart';
import '../../../models/product.dart';

class AdminProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : null;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.laptop, size: 50),
                ),
              ),

              // PRODUCT INFO
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                      // Rating
                  RatingStars(rating: product.rating),
                  const SizedBox(height: 4),
                  
                    Text(
                      "${product.price.toStringAsFixed(0)} RS",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // EDIT BUTTON TOP RIGHT
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onEdit,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
