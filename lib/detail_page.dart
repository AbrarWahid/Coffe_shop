import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'basket_page.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String price;

  const DetailPage({
    super.key,
    required this.title,
    required this.price,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A2A82), // Primary theme color for the top half
      body: Column(
        children: [
          // Top Half (Image and Back Button)
          Expanded(
            flex: 2,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Back Button
                  Positioned(
                    top: 16,
                    left: 24,
                    child: GestureDetector(
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
                  ),
                  // Product Image Placeholder
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(Icons.coffee, size: 100, color: Colors.brown.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Half (Details)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C1E4A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Icon(Icons.remove, size: 20, color: Color(0xFF2C1E4A)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$quantity',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2C1E4A),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0E6), // A light peach/orange background
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 20, color: Color(0xFF5A2A82)),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.price,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C1E4A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Ingredients Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One Cup Contains:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C1E4A),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 16),
                        height: 2,
                        width: 150,
                        color: const Color(0xFF5A2A82),
                      ),
                      Text(
                        'Premium Arabica Espresso, Steamed Milk, Vanilla Syrup, Caramel Drizzle.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2C1E4A),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'If you are looking for a perfect coffee to start your day, this ${widget.title.toLowerCase()} is the best choice for you. Freshly brewed.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  // Bottom Actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border, color: Color(0xFF5A2A82)),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BasketPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A2A82), // Primary Theme color
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Add to basket',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
