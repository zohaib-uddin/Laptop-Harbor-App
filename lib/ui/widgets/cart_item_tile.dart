import 'package:flutter/material.dart';
import '../../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: item.thumbnail != null
            ? Image.network(
                item.thumbnail!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.laptop, size: 40),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: ${item.price.toStringAsFixed(0)} RS"),
            Text("Total: ${item.total.toStringAsFixed(0)} RS"),
          ],
        ),

        trailing: SizedBox(
          width: 140, // extra safe width
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Control
              Row(
                children: [
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity - 1),
                    icon: const Icon(Icons.remove),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Bigger, bold quantity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18, // bigger font
                        fontWeight: FontWeight.bold, // bold
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                    icon: const Icon(Icons.add),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              // Delete Button — fixed, compact & no overflow
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
