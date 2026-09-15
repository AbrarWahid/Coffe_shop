import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_page.dart';
import 'basket_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Custom Menu Icon
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1E4A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1E4A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    // Basket Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BasketPage()),
                        );
                      },
                      child: Column(
                        children: [
                          const FaIcon(FontAwesomeIcons.basketShopping, color: Color(0xFF5A2A82), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'My basket',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF2C1E4A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Greeting Text
                Text(
                  'Hello Tony, What coffee\ndo you want today?',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C1E4A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                // Search Bar and Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for coffee',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                            icon: Icon(Icons.search, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const FaIcon(FontAwesomeIcons.sliders, color: Color(0xFF2C1E4A), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Recommended Section
                Text(
                  'Recommended Coffee',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C1E4A),
                  ),
                ),
                const SizedBox(height: 24),
                // Recommended List
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildCoffeeCard(
                        title: index == 0 ? 'Caramel Macchiato' : 'Vanilla Latte',
                        price: index == 0 ? 'Rp 35.000' : 'Rp 30.000',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTab(title: 'Hottest', index: 0),
                    _buildTab(title: 'Popular', index: 1),
                    _buildTab(title: 'New coffee', index: 2),
                    _buildTab(title: 'Top', index: 3),
                  ],
                ),
                const SizedBox(height: 24),
                // Bottom List
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildCoffeeCard(
                        title: index == 0 ? 'Espresso Arabica' : 'Cappuccino',
                        price: index == 0 ? 'Rp 25.000' : 'Rp 32.000',
                        bgColor: const Color(0xFFFFF9EE),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required int index}) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF2C1E4A) : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF5A2A82),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (!isSelected) const SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _buildCoffeeCard({required String title, required String price, Color bgColor = Colors.white}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(title: title, price: price),
          ),
        );
      },
      child: Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: bgColor == Colors.white
            ? [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 20),
          ),
          const SizedBox(height: 8),
          // Placeholder for Coffee Image
          Center(
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.coffee, color: Colors.brown.shade400, size: 40),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C1E4A),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A2A82),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Color(0xFF5A2A82), size: 16),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
