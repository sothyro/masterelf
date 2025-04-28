// ignore_for_file: prefer_conditional_assignment

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoonBlocksScreen extends StatefulWidget {
  const MoonBlocksScreen({super.key});

  @override
  State<MoonBlocksScreen> createState() => _MoonBlocksScreenState();
}

class _MoonBlocksScreenState extends State<MoonBlocksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isThrowing = false;
  bool _showResult = false;
  String _resultText = '';
  String _resultInterpretation = '';
  String _resultImage1 = 'assets/images/moon_blocks.png';
  String _resultImage2 = 'assets/images/moon_blocks.png';
  int _throwsToday = 0;
  DateTime? _lastThrowDate;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _determineResult();
      }
    });

    _loadThrowData();
  }

  Future<void> _loadThrowData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastThrowTimestamp = prefs.getInt('lastThrowTimestamp');
    final throwsToday = prefs.getInt('throwsToday') ?? 0;

    setState(() {
      _throwsToday = throwsToday;
      if (lastThrowTimestamp != null) {
        _lastThrowDate = DateTime.fromMillisecondsSinceEpoch(lastThrowTimestamp);
      }
    });
  }

  Future<void> _saveThrowData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('throwsToday', _throwsToday);
    if (_lastThrowDate != null) {
      await prefs.setInt('lastThrowTimestamp', _lastThrowDate!.millisecondsSinceEpoch);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _throwBlocks() async {
    final now = DateTime.now();

    // Check if it's a new day (24 hours have passed since last throw)
    if (_lastThrowDate == null ||
        now.difference(_lastThrowDate!) >= const Duration(hours: 24)) {
      setState(() {
        _throwsToday = 0;
        _lastThrowDate = now;
      });
      await _saveThrowData();
    }

    // Check throw limit
    if (_throwsToday >= 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '១ថ្ងៃ យើងផ្សងបាន ៣ដង!\nវេលាស្អែកទើបអាចផ្សងទៀតបាន',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Siemreap',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          width: 300,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_isThrowing) return;

    setState(() {
      _isThrowing = true;
      _showResult = false;
      _throwsToday++;
      if (_lastThrowDate == null) {
        _lastThrowDate = now;
      }
      _animationController.reset();
      _animationController.forward();
    });

    await _saveThrowData();
  }

  void _determineResult() {
    int result = _random.nextInt(4);

    setState(() {
      _isThrowing = false;
      _showResult = true;

      switch (result) {
        case 0:
          _resultImage1 = 'assets/images/yin.png';
          _resultImage2 = 'assets/images/yang.png';
          _resultText = '聖筊'; // : Shèngjiǎo
          _resultInterpretation = 'បំណងព្រះ! ល្អណាស់ \nទេវតាយល់ព្រមហើយ \nសូមបានសម្រេចគ្រប់ប្រការ';
          break;
        case 1:
          _resultImage1 = 'assets/images/yang.png';
          _resultImage2 = 'assets/images/yang.png';
          _resultText = '怒筊'; // : Nùjiǎo
          _resultInterpretation = 'ទេវតាមិនពេញចិត្ត! \nមិនបានទេ! \nបំណងនេះមិនជោគជ័យឡើយ';
          break;
        case 2:
          _resultImage1 = 'assets/images/yin.png';
          _resultImage2 = 'assets/images/yin.png';
          _resultText = '笑筊'; // : Xiàojiǎo
          _resultInterpretation = 'វាសនាសើចចំអក! \nទេវតាពិតជាអស់សំណើចខ្លាំងណាស់ \nបំណងប្រាថ្នានេះគឺវាមិនអាចទៅរួចឡើយ!';
          break;
        case 3:
          if (_random.nextBool()) {
            _resultImage1 = 'assets/images/standing.png';
            _resultImage2 = 'assets/images/moon_blocks.png';
          } else {
            _resultImage1 = 'assets/images/standing.png';
            _resultImage2 = 'assets/images/standing.png';
          }
          _resultText = '立筊'; // : Lìjiǎo
          _resultInterpretation = 'មិនច្បាស់ការសោះ! \nសំនួរ និងបំណងអ្នកមិនច្បាស់ពីចិត្ត \nផ្សងម្តងទៀត';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ybg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40), // Space from top
                  const Text(
                    'បំណងយ៉ាងណា ទេវតាដឹងលឺ \nស្ថានសួគ៌ចាត់ចែង! \nផ្សងក្នុងចិត្ត ហើយបោះក្រឡាប់ព្រះច័ន្ទ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontFamily: 'Dangrek',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40), // Space between text and blocks
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isThrowing)
                        Lottie.asset(
                          'assets/jsons/lightray.json',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value * 2 * pi,
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: _throwBlocks,
                          child: Image.asset(
                            'assets/images/moon_blocks.png',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_showResult)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _resultImage1,
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: 20),
                        Image.asset(
                          _resultImage2,
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _resultText,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: 'Dangrek',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultInterpretation,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Dangrek',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle:
                      const TextStyle(fontSize: 16, fontFamily: 'Dangrek'),
                      backgroundColor: Colors.red.withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ចេញទៅវិញ'),
                  ),
                  ElevatedButton(
                    onPressed: _throwBlocks,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle:
                      const TextStyle(fontSize: 16, fontFamily: 'Dangrek'),
                      backgroundColor: Colors.black87.withValues(alpha: 0.7),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('បោះក្រឡាប់ព្រះច័ន្ទ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}