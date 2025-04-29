import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'about_screen.dart';
import 'web_screen.dart';
import 'bazi_page.dart';
import 'dateselection_screen.dart';
import 'lopan_screen.dart';
import 'pray_screen.dart';
import 'talisman_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _menuTextAnimationController;
  late Animation<Offset> _menuTextAnimation;
  late AnimationController _lottieAnimationController;
  bool _isMenuOpen = false;

  final List<Widget> _pages = [
    PrayScreen(),
    BaziPage(),
    DateSelectionScreen(),
    LopanScreen(),
    TalismanScreen(),
    AboutScreen(),
  ];

  // Simplified menu structure
  final Map<String, List<Map<String, String>>> _menuItems = {
    '🔥ហុងស៊ុយថ្មីយុគ9': [
      {'title': '     💠 វីដេអូ ·Vlogs', 'url': 'https://period9.masterelf.vip/vlogs'},
      {'title': '     💠 សៀវភៅយុគ9', 'url': 'https://period9.masterelf.vip/period9'},
    ],
    '🧧លាភហេងឆ្នាំថ្មី': [
      {'title': '     💠 រាសីឆ្នាំទាំង12', 'url': 'https://period9.masterelf.vip/zodiac'},
      {'title': '     💠 ដេគ័រកាត់ឆុង', 'url': 'https://period9.masterelf.vip/fengshuicure'},
    ],
    '☯️ម៉ាស្ទ័រអេល': [
      {'title': '     💠 EVENTSថ្មី', 'url': 'https://period9.masterelf.vip/event'},
      {'title': '     💠 ទំនាក់ទំនង', 'url': 'about'},
      {'title': '     💠 ណាត់ពិភាក្សា', 'url': 'https://period9.masterelf.vip/appointment'},
    ],
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.repeat(reverse: true);
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

    _menuTextAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _menuTextAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.1, 0),
    ).animate(CurvedAnimation(
      parent: _menuTextAnimationController,
      curve: Curves.easeInOut,
    ));

    _lottieAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _menuTextAnimationController.dispose();
    _lottieAnimationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _navigateTo(String url) {
    _closeMenu();
    if (url == 'about') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WebScreen(url: url)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _pages[_selectedIndex],
          // Positioned widget gives more precise control than Align for this case
          Positioned(
            top: MediaQuery.of(context).padding.top - 20, // Adjust this value to move up/down
            left: 0,
            right: 0,
            child: Center( // This ensures horizontal centering
              child: GestureDetector(
                onTap: _toggleMenu,
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Wave animation
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: Lottie.asset(
                          'assets/jsons/wave.json',
                          controller: _lottieAnimationController,
                          animate: true,
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Menu icon
                      Image.asset(
                        'assets/icons/menu.png',
                        width: 150,
                        height: 70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isMenuOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
              ),
            ),
            _buildSlideMenu(context, bottomNavBarHeight),
          ],
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSlideMenu(BuildContext context, double bottomNavBarHeight) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final menuHeight = screenHeight - safeAreaTop - bottomNavBarHeight;

    return Positioned(
      left: 0,
      top: safeAreaTop,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: menuHeight,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        padding: const EdgeInsets.all(14), // Reduced padding
                        onPressed: _closeMenu,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12), // Reduced padding
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24, // Slightly smaller avatar
                            backgroundImage: AssetImage('assets/images/profileicon.png'),
                          ),
                          const SizedBox(width: 12), // Reduced spacing
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ម៉ាស្ទ័រអេល',
                                style: TextStyle(
                                  fontFamily: 'Dangrek',
                                  color: Colors.white,
                                  fontSize: 18, // Slightly smaller font
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'កម្មវិធីយុគ9 (V1.8)',
                                style: TextStyle(
                                  fontFamily: 'Dangrek',
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14, // Slightly smaller font
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: _menuItems.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), // Reduced vertical padding
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontFamily: 'Dangrek',
                                    color: Colors.white,
                                    fontSize: 16, // Slightly smaller font
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...entry.value.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal padding
                                  child: ListTile(
                                    dense: true, // Makes the ListTile more compact
                                    visualDensity: const VisualDensity(vertical: -4), // Further reduces vertical space
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced internal padding
                                    title: Text(
                                      item['title']!,
                                      style: TextStyle(
                                        fontFamily: 'Dangrek',
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14, // Slightly smaller font
                                      ),
                                    ),
                                    onTap: () => _navigateTo(item['url']!),
                                  ),
                                );
                              }),
                              const Divider(
                                color: Colors.white24,
                                height: 8, // Reduced divider height
                                thickness: 0.5, // Thinner divider
                                indent: 16,
                                endIndent: 16,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20), // Reduced padding
                      child: Text(
                        'Developed by: \nStonechat Communications\n\nក្រុមហ៊ុនហុងស៊ុយ ម៉ាស្ទ័អេល\nMaster Elf Feng Shui 风水 ™️\n©️2026 - All rights reserved.',
                        style: TextStyle(
                          fontFamily: 'Dangrek',
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10, // Slightly smaller font
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white.withValues(alpha: 0.4),
            currentIndex: _selectedIndex,
            onTap: (index) {
              _closeMenu(); // Close menu when bottom nav item is tapped
              _onItemTapped(index);
            },
            items: [
              _buildBottomNavItem('assets/icons/pray.png', 'ពិធី', 0),
              _buildBottomNavItem('assets/icons/bazi.png', 'បាជឺ', 1),
              _buildBottomNavItem('assets/icons/date.png', 'វេលា', 2),
              _buildBottomNavItem('assets/icons/lopan.png', 'ឡកែ', 3),
              _buildBottomNavItem('assets/icons/talisman.png', 'យ័ន្ត', 4),
            ],
            selectedItemColor: _getSelectedItemColor(_selectedIndex),
            unselectedItemColor: Colors.black,
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Dangrek',
              color: Colors.black,
              fontSize: 16,
            ),
            selectedLabelStyle: TextStyle(
              fontFamily: 'Dangrek',
              color: _getSelectedItemColor(_selectedIndex),
              fontSize: 16,
            ),
            selectedFontSize: 16,
            unselectedFontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(color: Colors.black.withValues(alpha: 0.4)),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
      String imagePath, String label, int index) {
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
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                imagePath,
                width: 32,
                height: 32,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }

  Color _getSelectedItemColor(int index) {
    switch (index) {
      case 0:
        return Colors.yellow;
      case 1:
        return Colors.red;
      case 2:
        return Colors.deepPurpleAccent;
      case 3:
        return Colors.yellowAccent;
      case 4:
        return Colors.tealAccent;
      default:
        return Colors.red;
    }
  }
}