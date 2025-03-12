import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'bazi_page.dart'; // Import the Bazi page
import 'dateselection_screen.dart'; // Import the DateSelection screen
import 'lopan_screen.dart'; // Import the Lopan screen
import 'talisman_screen.dart'; // Import the Talisman screen
import 'pray_screen.dart'; // Import the Pray screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2; // Default selected index for Date Selection
  late AnimationController _animationController;
  late Animation<double> _animation;

  // List of pages for navigation
  final List<Widget> _pages = [
    PrayScreen(), // Pray page
    BaziPage(), // Bazi page (contains the Bazi Calculator UI)
    DateSelectionScreen(), // DateSelection page
    LopanScreen(), // Lopan page
    TalismanScreen(), // Talisman page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
      _animationController.reset(); // Reset the animation
      _animationController.repeat(reverse: true); // Start the animation loop
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);

    // Start the animation for the default selected item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur Effect
          _buildBackground(),
          // Display the selected page
          _pages[_selectedIndex],
          // Centered Menu Buttons at the Top
          Align(
            alignment: Alignment.topCenter, // Align to the top center
            child: Padding(
              padding: const EdgeInsets.only(top: 50), // Adjust top padding as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: [
                  _buildMenuButton('យុគ្គ៩🔥九运', () {
                    // Add functionality for the About button
                    print('About button pressed');
                  }),
                  SizedBox(width: 10), // Add spacing between buttons
                  _buildMenuButton('ហុងស៊ុយ🧧风水', () {
                    // Add functionality for the Decor button
                    print('Decor button pressed');
                  }),
                  SizedBox(width: 10), // Add spacing between buttons
                  _buildMenuButton('☯️ ជួបម៉ាស្ទ័រ', () {
                    // Add functionality for the More button
                    print('More button pressed');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true, // Extend the body to cover the bottom navigation bar
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3), // Adjust the offset as needed
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              currentIndex: _selectedIndex, // Highlight the selected button
              onTap: _onItemTapped, // Handle button taps
              items: [
                _buildBottomNavItem('assets/icons/pray.png', 'ពិធី', 0),
                _buildBottomNavItem('assets/icons/bazi.png', 'បាជឺ', 1),
                _buildBottomNavItem('assets/icons/date.png', 'វេលា', 2),
                _buildBottomNavItem('assets/icons/lopan.png', 'ឡកែ', 3),
                _buildBottomNavItem('assets/icons/talisman.png', 'យ័ន្ត', 4),
              ],
              selectedItemColor: _getSelectedItemColor(_selectedIndex), // Dynamically select color
              unselectedItemColor: Colors.black, // Color for unselected items
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Dangrek', // Apply font family
                color: Colors.black, // Ensure labels are readable
                fontSize: 16, // Increase font size
              ),
              selectedLabelStyle: TextStyle(
                fontFamily: 'Dangrek', // Apply font family
                color: _getSelectedItemColor(_selectedIndex), // Ensure selected label matches the item color
                fontSize: 16, // Increase font size
              ),
              // Increase the height of the navigation bar
              selectedFontSize: 16,
              unselectedFontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // Build Background with Blur Effect
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.jpg'), // Add your image to assets
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(String imagePath, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _selectedIndex == index ? _animation.value : 1,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: _selectedIndex == index
                    ? [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // Adjust the offset as needed
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: Offset(0, -2), // Adjust the offset as needed
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: Offset(0, -2), // Adjust the offset as needed
                  ),
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // Adjust the offset as needed
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(imagePath, width: 32, height: 32), // Increase icon size
            ),
          );
        },
      ),
      label: label,
    );
  }

  // Function to get the selected item color based on the index
  Color _getSelectedItemColor(int index) {
    switch (index) {
      case 0:
        return Colors.yellow; // For 'បាជឺ'
      case 1:
        return Colors.red; // For 'វេលាមង្គល'
      case 2:
        return Colors.deepPurpleAccent; // For 'ឡកែ'
      case 3:
        return Colors.yellowAccent; // For 'យ័ន្ត'
      case 4:
        return Colors.tealAccent; // For 'បួងសួង'
      default:
        return Colors.red; // Default color if index is not matched
    }
  }

  // Function to build a menu button
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black, // Text color
          fontSize: 12, // Text size
          fontWeight: FontWeight.bold,
          fontFamily: 'Dangrek', // Apply font family
        ),
      ),
    );
  }
}