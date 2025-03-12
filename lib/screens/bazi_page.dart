import 'package:flutter/cupertino.dart'; // Import Cupertino widgets
import 'package:flutter/material.dart';
import 'dart:ui'; // For blur effect
import '../utils/bazi_calculator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui; // For screenshot functionality
import 'dart:typed_data';
import 'dart:io'; // For File and Directory
import 'package:path_provider/path_provider.dart'; // For getting the app's directory
import 'package:share_plus/share_plus.dart'; // For sharing the screenshot

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
  bool isCustomBazi = false; // Flag to track if custom Bazi is being displayed

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
        TimeOfDay tempSelectedTime = selectedTime;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassMorphismContainer(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ជ្រើសរើសម៉ោងកំណើត',
                    style: const TextStyle(
                      fontFamily: 'Dangrek',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200, // Set a fixed height for the picker
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
                        tempSelectedTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontFamily: 'Dangrek'),
                    ),
                    onPressed: () {
                      Navigator.pop(context, tempSelectedTime);
                    },
                    child: const Text('បញ្ជាក់'),
                  ),
                ],
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
      isCustomBazi = true; // Set the flag to true to show custom Bazi grid
    });
  }

  Future<void> _takeScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the image with a higher pixel ratio for better quality
      ui.Image image = await boundary.toImage(pixelRatio: 4.0); // Adjust the pixel ratio as needed

      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the screenshot to the app's private directory
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share the screenshot
      await Share.shareFiles([filePath], text: 'ប៉ាជឺ Screenshot');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✨ បានថតហើយ! សូមមើលនៅអាល់ប៊ុម 🖼️')),
      );
    } catch (e) {
      print('ថតមិនជាប់ទេ មានបញ្ហារ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ថតមិនជាប់ទេ មានបញ្ហារ: $e')),
      );
    }
  }



  final GlobalKey _globalKey = GlobalKey();

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
                SizedBox(height: kToolbarHeight + 50), // Add more space to avoid overlap with HomeScreen menu
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

                // Bazi Grid Display
                RepaintBoundary(
                  key: _globalKey,
                  child: _buildBaziGrid(),
                ),
                SizedBox(height: 10),

                // Buttons for Read Bazi, Interpret, and Refresh to Daily Bazi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassMorphismButton(
                      onPressed: _showExplanationDialog,
                      child: Text(
                        'អានប៉ាជឺ',
                        style: TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    GlassMorphismButton(
                      onPressed: _showInterpretationDialog,
                      child: Text(
                        'បកស្រាយ',
                        style: TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    GlassMorphismButton(
                      onPressed: _takeScreenshot,
                      child: Text(
                        'ថតទុក',
                        style: TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    GlassMorphismButton(
                      onPressed: () {
                        setState(() {
                          isCustomBazi = false; // Reset to daily Bazi grid
                        });
                      },
                      child: Text(
                        '🔄',
                        style: TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildTableCellWithSubtext(String mainText, String subText, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mainText,
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.white.withOpacity(0.8),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Dangrek',
              fontSize: 12, // Reduced font size
            ),
          ),
          Text(
            subText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10, // Reduced font size
              fontFamily: 'Dangrek',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaziGrid() {
    // Determine which date and time to use
    DateTime displayDate = isCustomBazi ? selectedDate : DateTime.now();
    TimeOfDay displayTime = isCustomBazi ? selectedTime : TimeOfDay.now();

    // Generate astrological data based on the selected date and time
    Map<String, List<String>> astroData = BaziCalculator.getAstroData(displayDate, displayTime);

    // Format the date and time
    String formattedDate = DateFormat('yyyy-MM-dd').format(displayDate);
    String formattedTime = displayTime.format(context);

    return Column(
      children: [
        // Title with selected date and time
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            isCustomBazi
                ? 'តារាងប៉ាជឺកំណើតអ្នក 📅 $formattedDate ⏰ $formattedTime'
                : 'តារាងប៉ាជឺវេលានេះ 📅 $formattedDate ⏰ $formattedTime',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Dangrek',
            ),
          ),
        ),
        // Bazi Grid
        Container(
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
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              // Header Row
              TableRow(
                children: [
                  _buildTableCellWithImage('assets/images/logo.png'), // Replace text with logo
                  _buildTableCellWithSubtext('ម៉ោង', displayTime.format(context)),
                  _buildTableCellWithSubtext('ថ្ងៃ', DateFormat('dd').format(displayDate)),
                  _buildTableCellWithSubtext('ខែ', DateFormat('MM').format(displayDate)),
                  _buildTableCellWithSubtext('ឆ្នាំ', DateFormat('yyyy').format(displayDate)),
                ],
              ),
              // Stem Row
              TableRow(
                children: [
                  _buildTableCell('天干', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[0] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Day']?[0] ?? 'N/A', backgroundColor: Colors.redAccent.shade100),
                  _buildTableCellWithColor(astroData['Month']?[0] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[0] ?? 'N/A'),
                ],
              ),
              // Branch Row
              TableRow(
                children: [
                  _buildTableCell('地支', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[1] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Day']?[1] ?? 'N/A', backgroundColor: Colors.redAccent.shade100),
                  _buildTableCellWithColor(astroData['Month']?[1] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[1] ?? 'N/A'),
                ],
              ),
              // Hidden Stem Row
              TableRow(
                children: [
                  _buildTableCell('藏干', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[2] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Day']?[2] ?? 'N/A', backgroundColor: Colors.redAccent.shade100),
                  _buildTableCellWithColor(astroData['Month']?[2] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[2] ?? 'N/A'),
                ],
              ),
              // NaYin Row
              TableRow(
                children: [
                  _buildTableCell('納音', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[3] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Day']?[3] ?? 'N/A', backgroundColor: Colors.redAccent.shade100),
                  _buildTableCellWithColor(astroData['Month']?[3] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[3] ?? 'N/A'),
                ],
              ),
              // Stars Row
              TableRow(
                children: [
                  _buildTableCell('干支', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[4] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Day']?[4] ?? 'N/A', backgroundColor: Colors.redAccent.shade100),
                  _buildTableCellWithColor(astroData['Month']?[4] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[4] ?? 'N/A'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableCellWithImage(String imagePath) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

// Helper function to build table cells with color based on element
  Widget _buildTableCellWithColor(String text, {bool isHeader = false, Color? backgroundColor}) {
    // Define color mappings for Heavenly Stems and Earthly Branches
    final Map<String, Color> stemColorMap = {
      '甲': Colors.green, // Wood
      '乙': Colors.green, // Wood
      '丙': Colors.red, // Fire
      '丁': Colors.red, // Fire
      '戊': Colors.yellow, // Earth
      '己': Colors.yellow, // Earth
      '庚': Colors.white, // Metal
      '辛': Colors.white, // Metal
      '壬': Colors.blue, // Water
      '癸': Colors.blue, // Water
    };

    final Map<String, Color> branchColorMap = {
      '子': Colors.blue, // Water
      '丑': Colors.yellow, // Earth
      '寅': Colors.green, // Wood
      '卯': Colors.green, // Wood
      '辰': Colors.yellow, // Earth
      '巳': Colors.red, // Fire
      '午': Colors.red, // Fire
      '未': Colors.yellow, // Earth
      '申': Colors.white, // Metal
      '酉': Colors.white, // Metal
      '戌': Colors.yellow, // Earth
      '亥': Colors.blue, // Water
    };

    // Determine the color based on the text
    Color? color = stemColorMap[text] ?? branchColorMap[text];

    return Container(
      padding: const EdgeInsets.all(8),
      color: backgroundColor, // Apply the background color if provided
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color ?? Colors.white.withOpacity(0.8), // Default to white if no color is found
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Dangrek',
            fontSize: 12, // Reduced font size
          ),
        ),
      ),
    );
  }

// Helper function to build a table cell with centered and smaller text
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return TableCell(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isHeader ? 14 : 12, // Reduced text size
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


// Show Explanation Dialog
  void _showExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'អានប៉ាជឺ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Dangrek',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This is a text-based explanation of the Bazi result.',
                      style: TextStyle(
                        fontSize: 14,
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.5),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontFamily: 'Dangrek'),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('យល់ព្រម'),
            ),
          ],
        );
      },
    );
  }

  // Show Interpretation Dialog
  void _showInterpretationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'បកស្រាយ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Dangrek',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      'assets/images/intepretation.png', // Path to your interpretative image
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.5),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontFamily: 'Dangrek'),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('យល់ព្រម'),
            ),
          ],
        );
      },
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
                'ជ្រើសរើសកាលបរិច្ឆេទ',
                style: const TextStyle(
                  fontFamily: 'Dangrek',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200, // Set a fixed height for the picker
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: widget.firstDate,
                  maximumDate: widget.lastDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
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