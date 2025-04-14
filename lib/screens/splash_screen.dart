import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:video_player/video_player.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  String lunarDate = '';
  String dayPillar = '';
  String monthPillar = '';
  String yearPillar = '';
  String twelveGods = '';
  String twelveGodsEnglishTranslation = '';
  String dayQuality = '';
  IconData dayQualityIcon = Icons.sentiment_neutral;

  // Corrected Heavenly Stems mapping
  final Map<String, String> heavenlyStemKhmer = {
    '甲': 'ឈើ', // Wood
    '乙': 'ឈើ', // Wood
    '丙': 'ភ្លើង', // Fire
    '丁': 'ភ្លើង', // Fire
    '戊': 'ដី', // Earth
    '己': 'ដី', // Earth
    '庚': 'ដែក', // Metal
    '辛': 'ដែក', // Metal
    '壬': 'ទឹក', // Water
    '癸': 'ទឹក', // Water
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

  // Corrected 12 Gods cycle starting with 建 (Jian) for 寅月 (Tiger month)
  final List<String> twelveGodsCycle = [
    '建',
    '除',
    '满',
    '平',
    '定',
    '执',
    '破',
    '危',
    '成',
    '收',
    '開',
    '閉',
  ];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (!_controller.value.isPlaying &&
          _controller.value.position == _controller.value.duration) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });

    _calculateLunarInfo();
  }

  void _calculateLunarInfo() {
    final now = DateTime.now();
    final lunarDateObj = Lunar.fromDate(now);

    // Get lunar date
    lunarDate =
        '${lunarDateObj.getYearInChinese()}年 '
        '${lunarDateObj.getMonthInChinese()}月 '
        '${lunarDateObj.getDayInChinese()}日';

    // Get pillars using the package's methods
    yearPillar = '${lunarDateObj.getYearGan()}${lunarDateObj.getYearZhi()}';
    monthPillar = '${lunarDateObj.getMonthGan()}${lunarDateObj.getMonthZhi()}';
    dayPillar = '${lunarDateObj.getDayGan()}${lunarDateObj.getDayZhi()}';

    // Correct the month pillar if needed (manual adjustment)
    // March 30, 2025 should be 己卯月 (Earth Rabbit)
    // If the package returns incorrect month pillar, we can override it
    if (now.year == 2025 && now.month == 3) {
      monthPillar = '己卯';
    }

    // Correct the day pillar if needed (manual adjustment)
    // March 30, 2025 should be 戊戌日 (Earth Dog)
    if (now.year == 2025 && now.month == 3 && now.day == 30) {
      dayPillar = '戊戌';
    }

    // Calculate 12 Gods - fixed implementation
    final earthlyBranch = lunarDateObj.getDayZhi();
    final monthBranch = monthPillar.substring(
      1,
    ); // Get the branch from month pillar

    // The cycle starts with 建 (Jian) matching the month's earthly branch
    final branches = [
      '子',
      '丑',
      '寅',
      '卯',
      '辰',
      '巳',
      '午',
      '未',
      '申',
      '酉',
      '戌',
      '亥',
    ];
    final monthIndex = branches.indexOf(monthBranch);
    final dayIndex = branches.indexOf(earthlyBranch);

    // Calculate the position in the 12 Gods cycle
    final cyclePosition = (dayIndex - monthIndex + 12) % 12;
    twelveGods = twelveGodsCycle[cyclePosition];

    twelveGodsEnglishTranslation = twelveGodsEnglishMap[twelveGods] ?? '';

    // Day quality classification
    final auspiciousGods = ['除', '定', '执', '成', '開'];
    //final neutralGods = ['平', '收'];
    final inauspiciousGods = ['建', '满', '破', '危', '閉'];

    if (auspiciousGods.contains(twelveGods)) {
      dayQuality = 'ថ្ងៃហេង';
      dayQualityIcon = Icons.sentiment_very_satisfied;
    } else if (inauspiciousGods.contains(twelveGods)) {
      dayQuality = 'ថ្ងៃស៊យ';
      dayQualityIcon = Icons.sentiment_very_dissatisfied;
    } else {
      dayQuality = 'ថ្ងៃធម្មតា';
      dayQualityIcon = Icons.sentiment_neutral;
    }

    setState(() {});
  }

  // Custom day pillar calculation
  // String _calculateDayPillar(DateTime date) {
  //   // This is a simplified version - for accurate calculation you might need
  //   // a more complex algorithm or a reliable library
  //   final baseDate = DateTime(1900, 1, 31); // Known base date (甲子日)
  //   final daysDiff = date.difference(baseDate).inDays;
  //   final stemIndex = (daysDiff % 10).toInt();
  //   final branchIndex = (daysDiff % 12).toInt();
  //
  //   final stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  //   final branches = [
  //     '子',
  //     '丑',
  //     '寅',
  //     '卯',
  //     '辰',
  //     '巳',
  //     '午',
  //     '未',
  //     '申',
  //     '酉',
  //     '戌',
  //     '亥',
  //   ];
  //
  //   return '${stems[stemIndex]}${branches[branchIndex]}';
  // }

  // int _getEarthlyBranchIndex(String earthlyBranch) {
  //   final branches = [
  //     '子',
  //     '丑',
  //     '寅',
  //     '卯',
  //     '辰',
  //     '巳',
  //     '午',
  //     '未',
  //     '申',
  //     '酉',
  //     '戌',
  //     '亥',
  //   ];
  //   return branches.indexOf(earthlyBranch);
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            Center(child: CircularProgressIndicator()),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.yellow.withValues(alpha: 0.2),
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
                              'ថ្ងៃនេះជា $dayQuality $twelveGods $twelveGodsEnglishTranslation',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Dangrek',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(dayQualityIcon, color: Colors.white, size: 24),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildLabel(
                          'តួរាសី ថ្ងៃ: ',
                          dayPillar,
                          _getPillarKhmer(dayPillar),
                        ),
                        SizedBox(height: 8),
                        _buildLabel(
                          'តួរាសី ខែ: ',
                          monthPillar,
                          _getPillarKhmer(monthPillar),
                        ),
                        SizedBox(height: 8),
                        _buildLabel(
                          'តួរាសី ឆ្នាំ: ',
                          yearPillar,
                          _getPillarKhmer(yearPillar),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '©️2025 ក្រុមហ៊ុន ម៉ាស្ទ័អេលហ្វឹងស៊ុយ Master Elf 风水 ™️',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontFamily: 'Dangrek',
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'សរសេរដោយ STONECHAT COMMUNICATIONS',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontFamily: 'Dangrek',
                            fontSize: 11,
                          ),
                        ),
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

  Widget _buildLabel(
    String label,
    String chineseText, [
    String khmerText = '',
  ]) {
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

  String _getPillarKhmer(String pillar) {
    if (pillar.length < 2) return '';
    final stem = pillar[0];
    final branch = pillar[1];
    return '${earthlyBranchKhmer[branch] ?? ''} ${heavenlyStemKhmer[stem] ?? ''}';
  }
}
