import 'package:flutter/cupertino.dart'; // Import Cupertino widgets
import 'package:flutter/material.dart';
import 'dart:ui'; // For blur effect
import '../utils/bazi_calculator.dart';

// Move GlassMorphismButton outside of the BaziPage class
class GlassMorphismButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GlassMorphismButton({
    Key? key, // Added Key parameter
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur effect
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Semi-transparent white
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Light border
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class BaziPage extends StatefulWidget {
  const BaziPage({Key? key}) : super(key: key); // Added Key parameter
  @override
  _BaziPageState createState() => _BaziPageState();
}

class _BaziPageState extends State<BaziPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String baziResult = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) { // Added return type
        return CustomDatePickerDialog(
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassMorphismContainer(
            child: SizedBox(
              height: 300, // Set a fixed height for the picker
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time, // Show only time picker
                initialDateTime: DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                ),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    selectedTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                  });
                },
              ),
            ),
          ),
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _calculateBazi() {
    setState(() {
      baziResult = BaziCalculator.calculateBazi(selectedDate, selectedTime);
    });

    // Show the result in a popup
    showDialog(
      context: context,
      builder: (BuildContext context) { // Added return type
        return AlertDialog(
          backgroundColor: Colors.red.withOpacity(0.4),
          content: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'លទ្ធផលប៉ាជឺ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Dangrek',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      baziResult,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Dangrek',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Dangrek',
                ),
              ),
            ),
          ],
        );
      },
    );
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'), // Path to your bg.jpg
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity
            child: Container(
              color: Colors.black.withOpacity(0.3), // Adjust opacity for the blur effect
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 80), // Add more space to avoid overlap with HomeScreen menu
                _buildTitle(),
                SizedBox(height: 20),

                // Align the three buttons horizontally with flexible width
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: GlassMorphismButton(
                        onPressed: () => _selectDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.white, size: 14), // Reduced icon size
                            SizedBox(width: 5), // Reduced spacing
                            Text(
                              'រើសកាល',
                              style: TextStyle(fontSize: 12, fontFamily: 'Dangrek', color: Colors.white), // Reduced font size
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between buttons
                    Flexible(
                      child: GlassMorphismButton(
                        onPressed: () => _selectTime(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, color: Colors.white, size: 14), // Reduced icon size
                            SizedBox(width: 5), // Reduced spacing
                            Text(
                              'រើសម៉ោង',
                              style: TextStyle(fontSize: 12, fontFamily: 'Dangrek', color: Colors.white), // Reduced font size
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between buttons
                    Flexible(
                      child: GlassMorphismButton(
                        onPressed: _calculateBazi,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate, color: Colors.white, size: 14), // Reduced icon size
                            SizedBox(width: 5), // Reduced spacing
                            Text(
                              'គណនា',
                              style: TextStyle(fontSize: 12, fontFamily: 'Dangrek', color: Colors.white), // Reduced font size
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Traditional Chinese Almanac Table
                _buildAlmanacTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Custom Title with Blur Glass Morphism
  Widget _buildTitle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // Rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3), // Semi-transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3), // Light border
              width: 2.2,
            ),
          ),
          child: Text(
            'គណនាប៉ាជឺ ថ្លឹងឆ្អឹង ថ្លឹងវាសនា',
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

  // Build Traditional Chinese Almanac Table
  Widget _buildAlmanacTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Semi-transparent white
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3), // Light border
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Table(
        border: TableBorder.all(color: Colors.white.withOpacity(0.5)), // Add grid lines
        columnWidths: const {
          0: FixedColumnWidth(100), // First column takes a fixed width
          1: FlexColumnWidth(1), // Second column takes the remaining width
        },
        children: _buildTableRows(),
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    return [
      // First Row (Containing the rotated text and the first set of information)
      TableRow(
        children: [
          _buildRotatedTextTableCell(
            text: '农历二月初七\n乙巳蛇年 己卯月甲戌日',
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Dangrek',
              color: Colors.yellow,
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '五行 山头火',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.red),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '冲煞 冲(戊辰)龙煞北',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '彭祖 甲不开仓财物耗散, 戊不吃犬作怪上床',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '喜神 东北',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '福神 正北',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '财神 东北',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Third Row
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '宜 祭祀 动土 上梁 订盟',
                style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.black),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '忌 开光 出货财',
                style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      // Fourth Row
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '吉神 月德 天愿 六合 金堂',
                style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.yellow),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '凶神 月煞 月虚 四击 天牢',
                style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.yellow),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  TableCell _buildRotatedTextTableCell({
    required String text,
    required TextStyle textStyle,
  }) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: RotatedBox(
        quarterTurns: 3, // Rotate 270 degrees
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

// Custom Glass Morphism Container for Bazi Result
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;

  const GlassMorphismContainer({
    Key? key, // Added Key parameter
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDatePickerDialog({
    Key? key, // Added Key parameter
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  _CustomDatePickerDialogState createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassMorphismContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Date',
                style: const TextStyle(
                  fontFamily: 'Dangrek',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontFamily: 'Dangrek'),
                ),
                onPressed: () {
                  Navigator.pop(context, _selectedDate);
                },
                child: const Text('បញ្ជាក់'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}