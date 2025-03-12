import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lunar/lunar.dart'; // Import the lunar package
import 'dart:ui' as ui; // Import for BackdropFilter
import 'home_screen.dart'; // Import the HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key); // Add named 'key' parameter

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  String lunarDate = ''; // Today's lunar date
  String dayPillar = ''; // Day Pillar
  String monthPillar = ''; // Month Pillar
  String yearPillar = ''; // Year Pillar
  String twelveGods = ''; // Today's 12 Gods
  String twelveGodsEnglishTranslation = ''; // English translation of the 12 Gods
  String dayQuality = ''; // Quality of the day (good, normal, bad)
  IconData dayQualityIcon = Icons.sentiment_neutral; // Default icon

  // Khmer translations for Heavenly Stems and Earthly Branches
  final Map<String, String> heavenlyStemKhmer = {
    '甲': 'ភ្លើង',
    '乙': 'ឈើ',
    '丙': 'ភ្លើង',
    '丁': 'ដី',
    '戊': 'ដែក',
    '己': 'ទឹក',
    '庚': 'ឈើ',
    '辛': 'ដែក',
    '壬': 'ភ្លើង',
    '癸': 'ដី',
  };

  final Map<String, String> earthlyBranchKhmer = {
    '子': 'កណ្តុរ',
    '丑': 'គោ',
    '寅': 'ខ្លា',
    '卯': 'ទន្សាយ',
    '辰': 'នាគ',
    '巳': 'ពស់',
    '午': 'សេះ',
    '未': 'ពពែ',
    '申': 'ស្វា',
    '酉': 'មាន់',
    '戌': 'ឆ្កែ',
    '亥': 'ជ្រូក',
  };

  // 12 Gods and their English translations
  final Map<String, String> twelveGodsEnglishMap = {
    '建': 'បង្កើត (Jian)',
    '除': 'ផ្លាស់ប្តូរ (Chu)',
    '满': 'បរិបូរណ៍ (Man)',
    '平': 'តុល្យភាព (Ping)',
    '定': 'លំនឹង (Ding)',
    '执': 'រៀបក្បួន (Zhi)',
    '破': 'បំផ្លាញ (Po)',
    '危': 'គ្រោះថ្នាក់ (Wei)',
    '成': 'ជោគជ័យ (Cheng)',
    '收': 'ទទួល (Shou)',
    '開': 'បើក (Kai)',
    '閉': 'បិទ (Bi)',
  };

  // 12 Gods cycle based on Earthly Branches
  final List<String> twelveGodsCycle = [
    '建', '除', '满', '平', '定', '执', '破', '危', '成', '收', '開', '閉',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the video controller
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown and start playing
        setState(() {});
        _controller.play();
      });

    // Navigate to the HomeScreen after the video ends
    _controller.addListener(() {
      if (!_controller.value.isPlaying && _controller.value.position == _controller.value.duration) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()), // Use HomeScreen here
        );
      }
    });

    // Calculate lunar information and 12 Gods
    _calculateLunarInfo();
  }

  // Function to calculate lunar information and 12 Gods
  void _calculateLunarInfo() {
    final now = DateTime.now();
    final lunarDateObj = Lunar.fromDate(now); // Convert Gregorian date to lunar date

    // Get lunar date
    lunarDate = '${lunarDateObj.getYearInChinese()}年 '
        '${lunarDateObj.getMonthInChinese()}月 '
        '${lunarDateObj.getDayInChinese()}日';

    // Get Day Pillar, Month Pillar, and Year Pillar
    dayPillar = '${lunarDateObj.getDayGan()}${lunarDateObj.getDayZhi()}'; // Day Pillar
    monthPillar = '${lunarDateObj.getMonthGan()}${lunarDateObj.getMonthZhi()}'; // Month Pillar
    yearPillar = '${lunarDateObj.getYearGan()}${lunarDateObj.getYearZhi()}'; // Year Pillar

    // Get today's 12 Gods based on the Earthly Branch of the day
    final earthlyBranch = lunarDateObj.getDayZhi(); // Get the Earthly Branch of the day
    final index = _getEarthlyBranchIndex(earthlyBranch); // Get the index of the Earthly Branch
    twelveGods = twelveGodsCycle[index]; // Get the 12 Gods for today
    twelveGodsEnglishTranslation = twelveGodsEnglishMap[twelveGods] ?? 'ទេវតាបិតភ្នែក'; // Get the English translation

    // Determine day quality based on 12 Gods
    final goodGods = ['建', '除', '满', '平', '定', '执', '成', '收', '開'];
    final badGods = ['破', '危', '閉'];

    if (goodGods.contains(twelveGods)) {
      dayQuality = 'ថ្ងៃហេង';
      dayQualityIcon = Icons.sentiment_very_satisfied; // Smiley icon
    } else if (badGods.contains(twelveGods)) {
      dayQuality = 'ថ្ងៃស៊យ';
      dayQualityIcon = Icons.sentiment_very_dissatisfied; // Sad icon
    } else {
      dayQuality = 'អ្នកសំងំសិន';
      dayQualityIcon = Icons.sentiment_neutral; // Indifferent icon
    }

    setState(() {});
  }

  // Helper function to get the index of the Earthly Branch
  int _getEarthlyBranchIndex(String earthlyBranch) {
    final branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return branches.indexOf(earthlyBranch);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: Stack(
        children: [
          // Full-screen video player
          if (_controller.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio, // Preserve the video's aspect ratio
                child: VideoPlayer(_controller),
              ),
            )
          else
            Center(child: CircularProgressIndicator()), // Show a loader while initializing

          // Glass morphism text label at the bottom
          Positioned(
            bottom: 20, // Position the label at the bottom
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2), // Semi-transparent white
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      border: Border.all(
                        color: Colors.yellow.withValues(alpha: 0.2), // Light border
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ថ្ងៃនេះជា $dayQuality',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Dangrek',
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              dayQualityIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildLabel('តួរាសី ថ្ងៃ: ', dayPillar, _getPillarKhmer(dayPillar)),
                        SizedBox(height: 8),
                        _buildLabel('តួរាសី ខែ: ', monthPillar, _getPillarKhmer(monthPillar)),
                        SizedBox(height: 8),
                        _buildLabel('តួរាសី ឆ្នាំ: ', yearPillar, _getPillarKhmer(yearPillar)),
                        SizedBox(height: 8),
                        _buildLabel('ដំណឹងទេវតា១២: ', twelveGods, twelveGodsEnglishTranslation),
                        SizedBox(height: 8),
                        _buildLabel('ថ្ងៃច័ន្ទគតិ: ', lunarDate),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build a label with Chinese and Khmer text
  Widget _buildLabel(String label, String chineseText, [String khmerText = '']) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Dangrek',
            fontSize: 16,
          ),
        ),
        Text(
          chineseText,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Dangrek',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (khmerText.isNotEmpty) ...[
          SizedBox(width: 8),
          Text(
            '($khmerText)',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Dangrek',
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // Helper function to get Khmer translation for a pillar (reversed order)
  String _getPillarKhmer(String pillar) {
    if (pillar.length < 2) return '';
    final stem = pillar[0];
    final branch = pillar[1];
    // Reverse the order: Earthly Branch first, then Heavenly Stem
    return '${earthlyBranchKhmer[branch] ?? ''} ${heavenlyStemKhmer[stem] ?? ''}';
  }
}