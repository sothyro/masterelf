import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'about_screen.dart'; // Add this import
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
  OverlayEntry? _overlayEntry;
  String? _currentOpenMenu; // Track which menu is currently open

  final List<Widget> _pages = [
    PrayScreen(),
    BaziPage(),
    DateSelectionScreen(),
    LopanScreen(),
    TalismanScreen(),
    AboutScreen(),
  ];

  final Map<String, List<String>> _dropdownItems = {
    '🔥ហុងស៊ុយយុគ9': ['វីដេអូ ·Vlogs', 'សៀវភៅយុគ9','វត្ថុកែហុងស៊ុយ'],
    '🧧លាភហេងឆ្នាំថ្មី': ['រាសីឆ្នាំទាំង12', 'ចូលរួមកម្មវិធី', 'ដេគ័រកាត់ឆុង'],//['តារាសាស្ត្រ·飞星', 'ទ្វារវាសនា·奇门', 'អ៊ីជីង·易經'],
    '☯️ម៉ាស្ទ័រអេល': ['ទំនាក់ទំនង', 'ណាត់ពិភាក្សា', 'អំពីកម្មវិធីនេះ'],
  };

  final Map<String, String> _itemUrls = {
    'វីដេអូ ·Vlogs': 'https://period9.masterelf.vip/vlogs',
    'សៀវភៅយុគ9': 'https://period9.masterelf.vip/period9',
    'វត្ថុកែហុងស៊ុយ': 'https://period9.masterelf.vip/store',
    'រាសីឆ្នាំទាំង12': 'https://period9.masterelf.vip/zodiac',
    'ចូលរួមកម្មវិធី': 'https://period9.masterelf.vip/event',
    'ដេគ័រកាត់ឆុង': 'https://period9.masterelf.vip/fengshuicure',
    'ណាត់ពិភាក្សា': 'https://period9.masterelf.vip/appointment',
    //'អំពីកម្មវិធីយុគ9': 'https://masterelf.vip/contact/',
  };

  final Map<String, GlobalKey> _buttonKeys = {
    '🔥ហុងស៊ុយយុគ9': GlobalKey(),
    '🧧លាភហេងឆ្នាំថ្មី': GlobalKey(),
    '☯️ម៉ាស្ទ័រអេល': GlobalKey(),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _currentOpenMenu = null;
  }

  void _showMenuOverlay(BuildContext context, String text) {
    // If clicking the same button that's already open, close it
    if (_currentOpenMenu == text) {
      _removeOverlay();
      return;
    }

    // Otherwise, remove any existing overlay and show the new one
    _removeOverlay();
    _currentOpenMenu = text;

    final buttonKey = _buttonKeys[text]!;
    final renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + buttonSize.height + 5,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: buttonSize.width,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _dropdownItems[text]!.map((item) {
                    return InkWell(
                      onTap: () {
                        _removeOverlay();
                        // Special case for 'ទំនាក់ទំនង'
                        if (item == 'ទំនាក់ទំនង') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutScreen(),
                            ),
                          );
                        }
                        // For all other items that have URLs
                        else if (_itemUrls.containsKey(item)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebScreen(url: _itemUrls[item]!),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: _dropdownItems[text]!.last == item
                                ? BorderSide.none
                                : BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1),
                          ),
                        ),
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Dangrek',
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _pages[_selectedIndex],
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton('🔥ហុងស៊ុយយុគ9'),
                  const SizedBox(width: 10),
                  _buildMenuButton('🧧លាភហេងឆ្នាំថ្មី'),
                  const SizedBox(width: 10),
                  _buildMenuButton('☯️ម៉ាស្ទ័រអេល'),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.5),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white.withValues(alpha:0.4),
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
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
    child: Container(color: Colors.black.withValues(alpha:0.4)),
    ));
  }

  Widget _buildMenuButton(String text) {
    return ElevatedButton(
      key: _buttonKeys[text],
      onPressed: () => _showMenuOverlay(context, text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha:0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Dangrek',
        ),
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
                    color: Colors.grey.withValues(alpha:0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha:0.5),
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.white.withValues(alpha:0.5),
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                  BoxShadow(
                    color: Colors.grey.withValues(alpha:0.5),
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