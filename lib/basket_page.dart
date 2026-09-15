import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasketPage extends StatelessWidget {
  const BasketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top App Bar Area
          Container(
            color: const Color(0xFF5A2A82),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF2C1E4A)),
                        const SizedBox(width: 4),
                        Text(
                          'Go back',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF2C1E4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'My Basket',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Invisible box to balance the row for centering the title
                const SizedBox(width: 80),
              ],
            ),
          ),
          
          // List of items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                _buildBasketItem(
                  title: 'Caramel Macchiato',
                  quantity: '2 cups',
                  price: 'Rp 70.000',
                  iconColor: Colors.brown.shade100,
                ),
                Divider(color: Colors.grey.shade100, thickness: 1, height: 1),
                _buildBasketItem(
                  title: 'Vanilla Latte',
                  quantity: '1 cup',
                  price: 'Rp 30.000',
                  iconColor: Colors.orange.shade100,
                ),
                Divider(color: Colors.grey.shade100, thickness: 1, height: 1),
                _buildBasketItem(
                  title: 'Espresso Arabica',
                  quantity: '3 cups',
                  price: 'Rp 75.000',
                  iconColor: Colors.brown.shade200,
                ),
              ],
            ),
          ),
          
          // Bottom Checkout Area
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2C1E4A),
                      ),
                    ),
                    Text(
                      'Rp 175.000',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C1E4A),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A2A82),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Checkout',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketItem({
    required String title,
    required String quantity,
    required String price,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Image placeholder
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.coffee, color: Colors.brown, size: 30),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C1E4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantity,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C1E4A),
            ),
          ),
        ],
      ),
    );
  }
}
