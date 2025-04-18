import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lunar/lunar.dart';

void main() {
  runApp(const MaterialApp(home: DateSelectionScreen()));
}

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.reverse().then((_) {
          _lottieController.forward();
        });
      } else if (status == AnimationStatus.dismissed) {
        _lottieController.forward();
      }
    });

    _lottieController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Blur Overlay
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          // Lottie Animation
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/jsons/purplestar.json',
                controller: _lottieController,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 50),
                _buildTitle(),
                const SizedBox(height: 20),
                _buildMonthNavigation(),
                const SizedBox(height: 8),
                _buildWeekdayHeaders(),
                const SizedBox(height: 4),
                // Calendar Grid - Fixed to always show 6 rows (42 cells)
                Expanded(
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: _buildCalendarGrid(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const List<String> weekdays = ['ទ', 'ច', 'អ', 'ព', 'ព្រ', 'ស', 'ស'];

    return Row(
      children:
          weekdays.map((day) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Dangrek',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: _previousMonth,
        ),
        Text(
          '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Dangrek',
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.white,
          ),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  List<Widget> _buildCalendarGrid() {
    final int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final int firstWeekday =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;
    final DateTime today = DateTime.now();
    final bool isCurrentMonth =
        _selectedDate.year == today.year && _selectedDate.month == today.month;

    List<Widget> grid = [];

    // Empty cells for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      grid.add(const SizedBox.shrink());
    }

    // Cells for each day in the month
    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime currentDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        day,
      );
      final Lunar currentLunar = Lunar.fromDate(currentDay);
      final bool isToday = isCurrentMonth && day == today.day;

      grid.add(_buildCalendarCell(day, isToday, currentLunar));
    }

    // Add empty cells at the end if needed to complete 6 weeks (42 cells)
    while (grid.length < 42) {
      grid.add(const SizedBox.shrink());
    }

    return grid;
  }

  Widget _buildCalendarCell(int day, bool isToday, Lunar currentLunar) {
    // Only create date for valid days (1-31)
    final DateTime? currentDay =
        day <= 31
            ? DateTime(_selectedDate.year, _selectedDate.month, day)
            : null;

    return GestureDetector(
      onTap:
          currentDay != null
              ? () {
                _showDayDetails(currentLunar, currentDay);
              }
              : null,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(
            color: isToday ? Colors.amber : Colors.grey.withValues(alpha: 0.5),
            width: isToday ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
          color:
              isToday
                  ? Colors.amber.withValues(alpha: 0.1)
                  : Colors.transparent,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day <= 31 ? '$day' : '', // Only show day number if valid
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.amber : Colors.white,
                ),
              ),
              if (day <= 31) // Only show lunar date if valid day
                Text(
                  currentLunar.getDayInChinese(),
                  style: TextStyle(
                    fontSize: 12,
                    //fontWeight: FontWeight.bold,
                    color: isToday ? Colors.amber : Colors.blue,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetails(Lunar lunar, DateTime solarDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.4),
          content: Stack(
            children: [
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(decoration: BoxDecoration(color: Colors.transparent)),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),

                        // Date information
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ហុងស៊ុយថ្ងៃនេះ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '☀️ សូរិយគតិ: ${solarDate.toLocal().toString().split(' ')[0]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Text(
                                '🌙 ច័ន្ទគតិ: ${lunar.toString()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Zodiac information
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '☯️ តួរាសីហេងថ្ងៃនេះ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Text(
                                _getAuspiciousZodiacSigns(lunar).join(', '),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Siemreap',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '☯️ តួរាសីឆុងថ្ងៃនេះ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amberAccent,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Text(
                                _getConflictingZodiacSigns(lunar).join(', '),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Siemreap',
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Combined activities and fortune information
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Activities
                              Text(
                                '🧧 ថ្ងៃនេះល្អសម្រាប់',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  _getAuspiciousActivities(lunar),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '⚡ ប្រយ័ត្នស៊យ ថ្ងៃនេះហាម',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amberAccent,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  _getInauspiciousActivities(lunar),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              ),

                              // Fortune
                              const SizedBox(height: 8),
                              Text(
                                '💸 លាភថ្ងៃនេះ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  _getDailyFortune(lunar),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              ),

                              // Fetal position
                              const SizedBox(height: 8),
                              Text(
                                '👼 ទេវតារក្សាកូនអ្នកថ្ងៃខែនេះ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  '${_getMonthlyFetalPosition(lunar)} ${_getDailyFetalPosition(lunar)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Logo image (half inside, half outside)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent.withValues(
                    alpha: 0.5,
                  ),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontFamily: 'Dangrek'),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('យល់ព្រម'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Get Daily Fortune (using getDayLu)
  String _getDailyFortune(Lunar lunar) {
    // getDayLu() returns a String containing the fortunes for the day
    final String dailyFortunesString = lunar.getDayLu();

    // Split the string into a list of fortunes
    final List<String> dailyFortunes = dailyFortunesString.split(',');

    // Check if the list is empty before attempting to join
    if (dailyFortunes.isEmpty) {
      return "ថ្ងៃនេះមិនមានលាភសំណាងសោះ"; // Or some other default message
    }

    // Join the fortunes into a single string, separated by commas
    return dailyFortunes.join(', ');
  }

  String _getDailyFetalPosition(Lunar lunar) {
    //getDayPositionTai() directly returns the Chinese string representation of the daily fetal position
    // You don't need to use getDayPositionTaiDesc.
    final String dailyFetalPosition = lunar.getDayPositionTai();

    // You can translate the Chinese position into Khmer here if needed
    return _translateFetalPositionToKhmer(dailyFetalPosition);
  }

  // Get Monthly Fetal Position (using getMonthPositionTai)
  String _getMonthlyFetalPosition(Lunar lunar) {
    // getMonthPositionTai() directly returns the Chinese string representation of the monthly fetal position.
    // You don't need to use getMonthPositionTaiDesc.
    final String monthlyFetalPosition = lunar.getMonthPositionTai();

    // You can translate the Chinese position into Khmer here if needed
    return _translateFetalPositionToKhmer(monthlyFetalPosition);
  }

  // Translate Fetal Position To Khmer
  String _translateFetalPositionToKhmer(String text) {
    switch (text) {
      case "房床":
        return "បន្ទប់គ្រែ";
      case "碓磨":
        return "កិនស្រូវ";
      case "厨灶":
        return "ផ្ទះបាយ";
      case "门":
        return "ទ្វារ";
      case "厕":
        return "បង្គន់";
      case "房内东":
        return "ក្នុងបន្ទប់ទិសខាងកើត";
      case "房内南":
        return "ក្នុងបន្ទប់ទិសខាងត្បូង";
      case "房内西":
        return "ក្នុងបន្ទប់ទិសខាងលិច";
      case "房内北":
        return "ក្នុងបន្ទប់ទិសខាងជើង";
      case "房床外东":
        return "ក្រៅបន្ទប់គ្រែទិសខាងកើត";
      case "房床外南":
        return "ក្រៅបន្ទប់គ្រែទិសខាងត្បូង";
      case "房床外西":
        return "ក្រៅបន្ទប់គ្រែទិសខាងលិច";
      case "房床外北":
        return "ក្រៅបន្ទប់គ្រែទិសខាងជើង";
      case "仓库":
        return "ឃ្លាំង";
      case "门外东南":
        return "ខាងក្រៅទ្វារទិសអាគ្នេយ៍";
      case "门外正南":
        return "ខាងក្រៅទ្វារទិសខាងត្បូង";
      case "门外西南":
        return "ខាងក្រៅទ្វារទិសនិរតី";
      case "门外正东":
        return "ខាងក្រៅទ្វារទិសខាងកើត";
      case "门外正西":
        return "ខាងក្រៅទ្វារទិសខាងលិច";
      case "门外西北":
        return "ខាងក្រៅទ្វារទិសពាយព្យ";
      case "门外正北":
        return "ខាងក្រៅទ្វារទិសខាងជើង";
      case "门外东北":
        return "ខាងក្រៅទ្វារទិសឦសាន";
      case "厨灶碓磨内东":
        return "ក្នុងផ្ទះបាយ កិនស្រូវទិសខាងកើត";
      case "厨灶碓磨内南":
        return "ក្នុងផ្ទះបាយ កិនស្រូវទិសខាងត្បូង";
      case "厨灶碓磨内西":
        return "ក្នុងផ្ទះបាយ កិនស្រូវទិសខាងលិច";
      case "厨灶碓磨内北":
        return "ក្នុងផ្ទះបាយ កិនស្រូវទិសខាងជើង";
      case "厨灶碓磨外东":
        return "ក្រៅផ្ទះបាយ កិនស្រូវទិសខាងកើត";
      case "厨灶碓磨外南":
        return "ក្រៅផ្ទះបាយ កិនស្រូវទិសខាងត្បូង";
      case "厨灶碓磨外西":
        return "ក្រៅផ្ទះបាយ កិនស្រូវទិសខាងលិច";
      case "厨灶碓磨外北":
        return "Outside the kitchen stove and mortar, to the north";
      default:
        return text;
    }
  }

  // Helper method to get the zodiac sign for a lunar day
  String _getZodiacForLunarDay(Lunar lunar) {
    final String chineseDayZodiac = lunar.getDayInGanZhi();
    String dayZodiac = chineseDayZodiac.substring(
      1,
    ); // Get the branch part only
    return _translateToKhmer(dayZodiac);
  }

  // Get Auspicious Zodiac Signs (Day-Based Logic - Now Includes Combinations)
  List<String> _getAuspiciousZodiacSigns(Lunar lunar) {
    final currentZodiac = _getZodiacForLunarDay(lunar);
    final List<String> auspiciousZodiacs = [];

    switch (currentZodiac) {
      case "ជូត": // Rat
        auspiciousZodiacs.add("ឆ្លូវ 🐂"); // Ox
        auspiciousZodiacs.add("វក 🐒"); // Monkey
        auspiciousZodiacs.add("រោង 🐉"); // Dragon
        break;
      case "ឆ្លូវ": // Ox
        auspiciousZodiacs.add("ជូត 🐀"); // Rat
        auspiciousZodiacs.add("រកា 🐓"); // Rooster
        auspiciousZodiacs.add("ម្សាញ់ 🐍"); // Snake
        break;
      case "ខាល": // Tiger
        auspiciousZodiacs.add("ច 🐕"); // Dog
        auspiciousZodiacs.add("មមី 🐎"); // Horse
        break;
      case "ថោះ": // Rabbit
        auspiciousZodiacs.add("កុរ 🐖"); // Pig
        auspiciousZodiacs.add("មមែ 🐐"); // Goat
        auspiciousZodiacs.add("ច 🐕"); // Dog
        break;
      case "រោង": // Dragon
        auspiciousZodiacs.add("រកា 🐓"); // Rooster
        auspiciousZodiacs.add("វក 🐒"); // Monkey
        auspiciousZodiacs.add("ជូត 🐀"); // Rat
        break;
      case "ម្សាញ់": // Snake
        auspiciousZodiacs.add("ឆ្លូវ 🐂"); // Ox
        auspiciousZodiacs.add("រកា 🐓"); // Rooster
        auspiciousZodiacs.add("វក 🐒"); // Monkey
        break;
      case "មមី": // Horse
        auspiciousZodiacs.add("មមែ 🐐"); // Goat
        auspiciousZodiacs.add("ច 🐕"); // Dog
        auspiciousZodiacs.add("ខាល 🐅"); //Tiger
        break;
      case "មមែ": // Goat
        auspiciousZodiacs.add("មមី 🐎"); // Horse
        auspiciousZodiacs.add("កុរ 🐖"); // Pig
        auspiciousZodiacs.add("ថោះ 🐇"); //Rabbit
        break;
      case "វក": // Monkey
        auspiciousZodiacs.add("រោង 🐉"); // Dragon
        auspiciousZodiacs.add("ម្សាញ់ 🐍"); // Snake
        auspiciousZodiacs.add("ជូត 🐀"); // Rat
        break;
      case "រកា": // Rooster
        auspiciousZodiacs.add("រោង 🐉"); // Dragon
        auspiciousZodiacs.add("ម្សាញ់ 🐍"); // Snake
        auspiciousZodiacs.add("ឆ្លូវ 🐂"); // Ox
        break;
      case "ច": // Dog
        auspiciousZodiacs.add("ថោះ 🐇"); // Rabbit
        auspiciousZodiacs.add("មមី 🐎"); // Horse
        auspiciousZodiacs.add("ខាល 🐅"); //Tiger
        break;
      case "កុរ": // Pig
        auspiciousZodiacs.add("ថោះ 🐇"); // Rabbit
        auspiciousZodiacs.add("មមែ 🐐"); // Goat
        break;
    }

    return auspiciousZodiacs.toSet().toList(); // Ensure unique values
  }

  // Get Conflicting Zodiac Signs (Day-Based Logic - Now Includes Six Clashes)
  List<String> _getConflictingZodiacSigns(Lunar lunar) {
    final currentZodiac = _getZodiacForLunarDay(lunar);
    final List<String> conflictingZodiacs = [];

    switch (currentZodiac) {
      case "ជូត": // Rat
        conflictingZodiacs.add("មមី 🐎"); // Horse
        break;
      case "ឆ្លូវ": // Ox
        conflictingZodiacs.add("មមែ 🐐"); // Goat
        break;
      case "ខាល": // Tiger
        conflictingZodiacs.add("វក 🐒"); // Monkey
        break;
      case "ថោះ": // Rabbit
        conflictingZodiacs.add("រកា 🐓"); // Rooster
        break;
      case "រោង": // Dragon
        conflictingZodiacs.add("ច 🐕"); // Dog
        break;
      case "ម្សាញ់": // Snake
        conflictingZodiacs.add("កុរ 🐖"); // Pig
        break;
      case "មមី": // Horse
        conflictingZodiacs.add("ជូត 🐀"); // Rat
        break;
      case "មមែ": // Goat
        conflictingZodiacs.add("ឆ្លូវ 🐂"); // Ox
        break;
      case "វក": // Monkey
        conflictingZodiacs.add("ខាល 🐂"); // Tiger
        break;
      case "រកា": // Rooster
        conflictingZodiacs.add("ថោះ 🐇"); // Rabbit
        break;
      case "ច": // Dog
        conflictingZodiacs.add("រោង 🐉"); // Dragon
        break;
      case "កុរ": // Pig
        conflictingZodiacs.add("ម្សាញ់ 🐍"); // Snake
        break;
    }

    return conflictingZodiacs;
  }

  // Translate Chinese to Khmer
  String _translateToKhmer(String text) {
    // Updated to translate the Earthly Branches (day zodiacs)
    switch (text) {
      case "子":
        return "ជូត";
      case "丑":
        return "ឆ្លូវ";
      case "寅":
        return "ខាល";
      case "卯":
        return "ថោះ";
      case "辰":
        return "រោង";
      case "巳":
        return "ម្សាញ់";
      case "午":
        return "មមី";
      case "未":
        return "មមែ";
      case "申":
        return "វក";
      case "酉":
        return "រកា";
      case "戌":
        return "ច";
      case "亥":
        return "កុរ";
      default:
        return text;
    }
  }

  String _translateActivityToKhmer(String text) {
    // Updated to translate the Earthly Branches (day zodiacs)
    switch (text) {
      //activity
      case "开光":
        return "បើកការដ្ឋាន";
      case "塑绘":
        return "សមាធិ";
      case "斋醮":
        return "តមអាហារ";
      case "嫁娶":
        return "រៀបការ";
      case "入殓":
        return "បញ្ចុះសព";
      case "移柩":
        return "លើកមឈូស";
      case "谢土":
        return "អរគុណទឹកដី";
      case "入学":
        return "រកអ្នកស្នងមរតក";
      case "伐木":
        return "កាត់សក់";
      case "赴任 ":
        return "ចូលកាន់តំណែង";
      case "修造":
        return "ជួសជុល";
      case "祭祀":
        return "សែនទេវតា កុងម៉ា";
      case "祈福":
        return "បួងសួងសុំលាភ សុំក្តីសុខ";
      case "求嗣":
        return "សុំកូន ដាក់កូន";
      case "解除":
        return "រំដោះគ្រោះ ដោះអំពើ";
      case "纳采":
        return "រើសពេលារៀបការ រឺកម្មវិធី";
      case "冠笄":
        return "ឲ្យកូនស្រីចូលម្លប់";
      case "出火":
        return "ធ្វើគម្រោងថ្មី";
      case "拆卸":
        return "រុះរើផ្ទះ កន្លែងរកសុី";
      case "进人口":
        return "រើចូលផ្ទះ កន្លែងធ្វើការរកសុីថ្មី";
      case "安床":
        return "រៀបហុងស៊ុយក្បាលដំណេក បន្ទប់គេង";
      case "动土":
        return "បុកគ្រឹះ បើកការដ្ឋាន";
      case "上梁":
        return "ដំឡើងសរសររឺចាក់ផ្លង់សេ";
      case "造庙":
        return "សង់ទីដ្ឋានសក្ការៈដូចជាវិហ៊ា";
      case "掘井":
        return "ជីកអណ្តូង តទឹក រកប្រភពទឹក";
      case "安葬":
        return "ដង្ហែរសព";
      case "会亲友":
        return "ជួបជុំសាច់ញាតិ";
      case "订盟":
        return "ចុះកុងត្រា ចងសម្ព័ន្ធមេត្រី";
      case "裁衣":
        return "កាត់សម្លៀកបំពាក់";
      case "合帐":
        return "រៀបបន្ចប់គូរស្រករថ្មី";
      case "安机械":
        return "តម្លើងគ្រឿងចក្រ";
      case "安门":
        return "ដាក់ទ្វារបង្អូច";
      case "起基":
        return "សូត្រមន្តបញ្ចុះសីម៉ា";
      case "定磉":
        return "បុកគ្រឹះ";
      case "竖柱":
        return "ដំឡើងសរសរ";
      case "启钻":
        return "ខួងរឺស្វានសំណង់";
      case "除服":
        return "បញ្ចប់ការកាន់ទុក្ខ";
      case "成服":
        return "ស្លៀកពាក់កាន់ទុក្ខ";
      case "立碑":
        return "រៀបម៉ុង";
      case "破土":
        return "ជីករណ្តៅ";
      case "出行":
        return "ធ្វើដំណើរ";
      case "移徙":
        return "ប្តូរទីតាំង";
      case "入宅":
        return "ចូលផ្ទះថ្មី";
      case "立券":
        return "ចុះកុងត្រា";
      case "开市":
        return "បើកហាង";
      case "放水":
        return "ធ្វើអាងចិញ្ចឹមត្រី";
      case "理发":
        return "កាត់សក់";
      case "置产":
        return "ទិញអចលនទ្រព្យ";
      case "纳畜":
        return "ទិញសត្វចិញ្ចឹម";
      case "造畜稠":
        return "បង្កាត់ពូជសត្វ";
      case "作梁":
        return "ដំឡើងគ្រោងសំណង់";
      case "作灶":
        return "រៀបចង្ក្រានបាយ";
      case "开生坟":
        return "ជីកផ្នូរ";
      case "沐浴":
        return "មុជទឹកកាត់ឆុង";
      case "扫舍":
        return "សំអាតផ្ទះរឺទីតាំង";
      case "破屋":
        return "ជួសជុលកន្លែងរឺផ្ទះ";
      case "坏垣":
        return "រុះរបង";
      case "馀事勿取":
        return "កុំធ្វើអ្វីដែលមិនទំនង";
      case "安香":
        return "អុជធូបបន់ស្រន់";
      case "造仓":
        return "សង់ឃ្លាំង";
      case "赴任":
        return "ទទួលតំណែងផ្លូវការ";
      case "纳婿":
        return "ទទួលសាច់ថ្លៃ";
      case "出货财":
        return "លក់ចេញ";
      default:
        return text;
    }
  }

  // Get Auspicious Activities
  String _getAuspiciousActivities(Lunar lunar) {
    final List<String> auspiciousActivities = lunar.getDayYi();
    final List<String> translatedActivities =
        auspiciousActivities
            .map((activity) => _translateActivityToKhmer(activity))
            .toList();
    return translatedActivities.join(', ');
  }

  // Get Inauspicious Activities
  String _getInauspiciousActivities(Lunar lunar) {
    final List<String> inauspiciousActivities = lunar.getDayJi();
    final List<String> translatedActivities =
        inauspiciousActivities
            .map((activity) => _translateActivityToKhmer(activity))
            .toList();
    return translatedActivities.join(', ');
  }

  // Navigate to the previous month
  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  // Navigate to the next month
  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  // Helper method to get the month name
  String _getMonthName(int month) {
    const List<String> monthNames = [
      'មករា',
      'កុម្ភះ',
      'មីនា',
      'មេសា',
      'ឧសភា',
      'មិថុនា',
      'កក្កដា',
      'សីហា',
      'កញ្ញា',
      'តុលា',
      'វិច្ឆិកា',
      'ធ្នូ',
    ];
    return monthNames[month - 1];
  }

  // Build Custom Title with Blur Glass Morphism
  Widget _buildTitle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // Rounded corners
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent.withValues(
              alpha: 0.3,
            ), // Semi-transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // Light border
              width: 2.2,
            ),
          ),
          child: const Text(
            'មើលវេលាសិរី វេលាមង្គល',
            style: TextStyle(
              fontFamily: 'Dangrek',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
