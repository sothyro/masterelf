import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'dart:ui' as ui;

void main() {
  runApp(
    const MaterialApp(
      home: DateSelectionScreen(),
    ),
  );
}

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime _selectedDate = DateTime.now(); // Default to the current date

  // Function to generate the lunar calendar grid for the current month
  List<Widget> _buildCalendarGrid() {
    final int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final int firstWeekday = DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;

    List<Widget> grid = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      grid.add(const SizedBox.shrink()); // Empty cell
    }

    // Add cells for each day in the month
    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime currentDay = DateTime(_selectedDate.year, _selectedDate.month, day);
      final Lunar currentLunar = Lunar.fromDate(currentDay);

      grid.add(
        GestureDetector(
          onTap: () => _showDayDetails(currentLunar, currentDay),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day', // Solar day
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Numerical text in white
                    ),
                  ),
                  Text(
                    currentLunar.getDayInChinese(), // Lunar day in Chinese
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return grid;
  }

  // Function to show details in a scrollable popup
  void _showDayDetails(Lunar lunar, DateTime solarDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.4), // Red background with opacity
          content: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5), // Semi-transparent white
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), // Light border
                  width: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Solar and Lunar Date
                    Text(
                      'សូរិយគតិ: ${solarDate.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Dangrek' // Apply font here
                      ),
                    ),
                    Text(
                      'ច័ន្ទគតិ: ${lunar.toString()}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Dangrek'// Apply font here
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chinese Zodiac Signs
                    Text(
                      'តួរាសីឆ្នាំហេង:',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Dangrek' // Apply font here
                      ),
                    ),
                    Text(
                      _getAuspiciousZodiacSigns(lunar).join(', '), // Show zodiac names
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Siemreap' // Apply font here
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'តួរាសីឆ្នាំឆុង:',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Dangrek' // Apply font here
                      ),
                    ),
                    Text(
                      _getConflictingZodiacSigns(lunar).join(', '), // Show zodiac names
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Siemreap' // Apply font here
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Daily Activities
                    Text(
                      'កិច្ចការដែរធ្វើហើយហេង:',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Dangrek' // Apply font here
                      ),
                    ),
                    Text(
                        _getAuspiciousActivities(lunar),
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Siemreap' // Apply font here
                        )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ប្រយ័ត្នស៊យ ហាម:',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Dangrek' // Apply font here
                      ),
                    ),
                    Text(
                        _getInauspiciousActivities(lunar),
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Siemreap' // Apply font here
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                  'យល់ព្រម',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Dangrek' // Apply font here
                  )
              ),
            ),
          ],
        );
      },
    );
  }

  // Get Auspicious Zodiac Signs
  List<String> _getAuspiciousZodiacSigns(Lunar lunar) {
    return lunar.getDayYi().map((sign) => _translateToKhmer(sign)).toList();
  }

  // Get Conflicting Zodiac Signs
  List<String> _getConflictingZodiacSigns(Lunar lunar) {
    return lunar.getDayJi().map((sign) => _translateToKhmer(sign)).toList();
  }

  // Translate Chinese to Khmer
  String _translateToKhmer(String text) {
    switch (text) {
      case "鼠":
        return "ជូត";
      case "牛":
        return "ឆ្លូវ";
      case "虎":
        return "ខាល";
      case "兔":
        return "ថោះ";
      case "龙":
        return "រោង";
      case "蛇":
        return "ម្សាញ់";
      case "马":
        return "មមី";
      case "羊":
        return "មមែ";
      case "猴":
        return "វក";
      case "鸡":
        return "រកា";
      case "狗":
        return "ច";
      case "猪":
        return "កុរ";
      case "开光":
        return "បើកការដ្ឋាន";
      case "塑绘":
        return "ឆ្លាក់រឺសូនរូប";
      case "祈福":
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
      default:
        return text;
    }
  }

  // Get Auspicious Activities
  String _getAuspiciousActivities(Lunar lunar) {
    final List<String> auspiciousActivities = lunar.getDayYi();
    return auspiciousActivities.join(', ');
  }

  // Get Inauspicious Activities
  String _getInauspiciousActivities(Lunar lunar) {
    final List<String> inauspiciousActivities = lunar.getDayJi();
    return inauspiciousActivities.join(', ');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null, // Remove the title from here. It will be added to the body
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Full-screen background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Blur overlay
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 80), // Add more space to avoid overlap with HomeScreen menu
                _buildTitle(),
                const SizedBox(height: 20),
                // Month and Year Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Dangrek', // Apply font here
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Lunar Calendar Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 7,
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

  // Helper method to get the month name
  String _getMonthName(int month) {
    const List<String> monthNames = [
      'មករា', 'កុម្ភះ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
      'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'
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
            color: Colors.deepPurpleAccent.withValues(alpha: 0.3), // Semi-transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // Light border
              width: 2.2,
            ),
          ),
          child: const Text(
            'មើលវេលាសិរីមង្គល',
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