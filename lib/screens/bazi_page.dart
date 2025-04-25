// ignore_for_file: unused_element, unnecessary_to_list_in_spreads

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/bazi_calculator.dart';
import '../utils/bazi_analysis.dart';

// Move GlassMorphismButton outside of the BaziPage class
class GlassMorphismButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GlassMorphismButton({
    super.key, // Added Key parameter
    required this.onPressed,
    required this.child,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
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
  const BaziPage({super.key});

  @override
  State<BaziPage> createState() => _BaziPageState();
}

class _BaziPageState extends State<BaziPage> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String baziResult = '';
  bool isCustomBazi = false; // Flag to track if custom Bazi is being displayed

  late AnimationController _starAnimationController;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _starAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _starAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Added return type
        return CustomDatePickerDialog(
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
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

        return Theme(
          data: ThemeData.light().copyWith(
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.light,
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Dangrek',
                  fontSize: 18,
                ),
                pickerTextStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Dangrek',
                ),
              ),
            ),
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: GlassMorphismContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ជ្រើសរើសម៉ោងកំណើត',
                      style: TextStyle(
                        fontFamily: 'Dangrek',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ),
                        onDateTimeChanged: (DateTime newDateTime) {
                          tempSelectedTime = TimeOfDay(
                            hour: newDateTime.hour,
                            minute: newDateTime.minute,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha:0.5),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontFamily: 'Dangrek'),
                      ),
                      onPressed: () {
                        Navigator.pop(context, tempSelectedTime);
                      },
                      child: Text('បញ្ជាក់'),
                    ),
                  ],
                ),
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
      // Ensure the widget is still in the tree
      if (!mounted) return;

      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the image with a higher pixel ratio for better quality
      ui.Image image = await boundary.toImage(
        pixelRatio: 4.0,
      ); // Adjust the pixel ratio as needed

      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save the screenshot to the app's private directory
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share the screenshot
      await Share.shareXFiles([XFile(filePath)], text: 'ប៉ាជឺ Screenshot');

      // Check if the widget is still mounted before showing the SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✨ បានថតហើយ! សូមផ្ញើរទៅលោកគ្រូ')),
        );
      }
    } catch (e) {
      // Check if the widget is still mounted before showing the error SnackBar
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ថតមិនជាប់ទេ មានបញ្ហារ: $e')));
      }
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
                image: AssetImage('assets/images/bg.jpg'),
                // Path to your bg.jpg
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            // Adjust blur intensity
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.3,
              ), // Adjust opacity for the blur effect
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 50),
                // Add more space to avoid overlap with HomeScreen menu
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
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 14,
                            ), // Reduced icon size
                            SizedBox(width: 5), // Reduced spacing
                            Text(
                              'រើសកាល',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Dangrek',
                                color: Colors.white,
                              ), // Reduced font size
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
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 14,
                            ), // Reduced icon size
                            SizedBox(width: 5), // Reduced spacing
                            Text(
                              'រើសម៉ោង',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Dangrek',
                                color: Colors.white,
                              ), // Reduced font size
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
                            Icon(
                              Icons.calculate,
                              color: Colors.white,
                              size: 14,
                            ), // Reduced icon size
                            SizedBox(width: 5), // Reduced spacing
                            Text(
                              'គណនា',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Dangrek',
                                color: Colors.white,
                              ), // Reduced font size
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Bazi Grid Display
                RepaintBoundary(key: _globalKey, child: _buildBaziGrid()),
                SizedBox(height: 10),

                // Buttons for Read Bazi, Interpret, and Refresh to Daily Bazi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassMorphismButton(
                      onPressed: _showExplanationDialog,
                      child: Text(
                        'អានប៉ាជឺ',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Dangrek',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GlassMorphismButton(
                      onPressed: _showInterpretationDialog,
                      child: Text(
                        'តារាកំណើត',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Dangrek',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GlassMorphismButton(
                      onPressed: _takeScreenshot,
                      child: Text(
                        'ថតទុក',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Dangrek',
                          color: Colors.white,
                        ),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Dangrek',
                          color: Colors.white,
                        ),
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
            color: Colors.red.withValues(alpha: 0.3), // Semi-transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // Light border
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

  Widget _buildTableCellWithSubtext(
    String mainText,
    String subText, {
    bool isHeader = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mainText,
            style: TextStyle(
              color:
                  isHeader ? Colors.white : Colors.white.withValues(alpha: 0.8),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Dangrek',
              fontSize: 12, // Reduced font size
            ),
          ),
          Text(
            subText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
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
    Map<String, List<String>> astroData = BaziCalculator.getAstroData(
      displayDate,
      displayTime,
    );

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
            color: Colors.white.withValues(alpha: 0.2),
            // Semi-transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // Light border
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Table(
            border: TableBorder.all(color: Colors.white.withValues(alpha: 0.5)),
            // Add grid lines
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
                  _buildTableCellWithImage('assets/images/logo.png'),
                  // Replace text with logo
                  _buildTableCellWithSubtext(
                    'ម៉ោង',
                    displayTime.format(context),
                  ),
                  _buildTableCellWithSubtext(
                    'ថ្ងៃ',
                    DateFormat('dd').format(displayDate),
                  ),
                  _buildTableCellWithSubtext(
                    'ខែ',
                    DateFormat('MM').format(displayDate),
                  ),
                  _buildTableCellWithSubtext(
                    'ឆ្នាំ',
                    DateFormat('yyyy').format(displayDate),
                  ),
                ],
              ),
              // Stem Row
              TableRow(
                children: [
                  _buildTableCell('天干', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[0] ?? 'N/A'),
                  _buildTableCellWithColor(
                    astroData['Day']?[0] ?? 'N/A',
                    backgroundColor: Colors.redAccent.shade100,
                  ),
                  _buildTableCellWithColor(astroData['Month']?[0] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[0] ?? 'N/A'),
                ],
              ),
              // Branch Row
              TableRow(
                children: [
                  _buildTableCell('地支', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[1] ?? 'N/A'),
                  _buildTableCellWithColor(
                    astroData['Day']?[1] ?? 'N/A',
                    backgroundColor: Colors.redAccent.shade100,
                  ),
                  _buildTableCellWithColor(astroData['Month']?[1] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[1] ?? 'N/A'),
                ],
              ),
              // Hidden Stem Row
              TableRow(
                children: [
                  _buildTableCell('藏干', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[2] ?? 'N/A'),
                  _buildTableCellWithColor(
                    astroData['Day']?[2] ?? 'N/A',
                    backgroundColor: Colors.redAccent.shade100,
                  ),
                  _buildTableCellWithColor(astroData['Month']?[2] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[2] ?? 'N/A'),
                ],
              ),
              // NaYin Row
              TableRow(
                children: [
                  _buildTableCell('納音', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[3] ?? 'N/A'),
                  _buildTableCellWithColor(
                    astroData['Day']?[3] ?? 'N/A',
                    backgroundColor: Colors.redAccent.shade100,
                  ),
                  _buildTableCellWithColor(astroData['Month']?[3] ?? 'N/A'),
                  _buildTableCellWithColor(astroData['Year']?[3] ?? 'N/A'),
                ],
              ),
              // Stars Row
              TableRow(
                children: [
                  _buildTableCell('干支', isHeader: true),
                  _buildTableCellWithColor(astroData['Hour']?[4] ?? 'N/A'),
                  _buildTableCellWithColor(
                    astroData['Day']?[4] ?? 'N/A',
                    backgroundColor: Colors.redAccent.shade100,
                  ),
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
        child: Image.asset(imagePath, width: 32, height: 32, fit: BoxFit.cover),
      ),
    );
  }

  // Helper function to build table cells with color based on element
  Widget _buildTableCellWithColor(
    String text, {
    bool isHeader = false,
    Color? backgroundColor,
  }) {
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
            color: color ?? Colors.white.withValues(alpha: 0.8),
            // Default to white if no color is found
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
    // Determine which date and time to use
    DateTime displayDate = isCustomBazi ? selectedDate : DateTime.now();
    TimeOfDay displayTime = isCustomBazi ? selectedTime : TimeOfDay.now();

    // Generate astrological data
    Map<String, List<String>> astroData = BaziCalculator.getAstroData(
      displayDate,
      displayTime,
    );

    // Get comprehensive analysis
    final analysis = BaziAnalysis.getBaziAnalysis(displayDate, displayTime, astroData);

    // Add Key Interactions to the analysis
    analysis['keyInteractions'] = BaziAnalysis.getKeyInteractions(
      dayMaster: analysis['dayMaster'],
      yearAnalysis: analysis['yearAnalysis'],
      monthAnalysis: analysis['monthAnalysis'],
      dayAnalysis: analysis['dayAnalysis'],
      hourAnalysis: analysis['hourAnalysis'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.4),
          content: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                        // Header with date/time
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'អានលទ្ធផលប៉ាជឺ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${analysis['date']} at ${analysis['time']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'តួរាសីថ្ងៃ DM: ${analysis['dayMaster']} (${analysis['dayMasterElement']})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForElement(analysis['dayMasterElement']),
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Year Pillar Analysis
                        _buildPillarSection(analysis['yearAnalysis'], 'តួរាសីឆ្នាំ'),
                        Divider(color: Colors.white.withValues(alpha: 0.3)),

                        // Month Pillar Analysis
                        _buildPillarSection(analysis['monthAnalysis'], 'តួរាសីខែ'),
                        Divider(color: Colors.white.withValues(alpha: 0.3)),

                        // Day Pillar Analysis
                        _buildPillarSection(analysis['dayAnalysis'], 'តួរាសីថ្ងៃ'),
                        Divider(color: Colors.white.withValues(alpha: 0.3)),

                        // Hour Pillar Analysis
                        _buildPillarSection(analysis['hourAnalysis'], 'តួរាសីម៉ោង'),
                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'អន្តរកម្មនៃធាតុ និងឆ្នាំ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              SizedBox(height: 8),
                              ...(analysis['keyInteractions'] as List<String>).map((interaction) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  interaction,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              )).toList(),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Key Takeaways
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'គន្លឹះគួរចងចាំ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              SizedBox(height: 8),
                              ...(analysis['keyTakeaways'] as List<String>).map((takeaway) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  takeaway,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              )).toList(),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Feng Shui Enhancements
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'បើក រឺ កែ ហុងស៊ុយ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              SizedBox(height: 8),
                              ...(analysis['fengShuiEnhancements'] as List<String>).map((enhancement) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  enhancement,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Siemreap',
                                  ),
                                ),
                              )).toList(),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Final Verdict
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'សាលក្រមប៉ាជឺ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                analysis['finalVerdict'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Siemreap',
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
              // Logo
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
                  backgroundColor: Colors.red.withValues(alpha: 0.5),
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

  Widget _buildPillarSection(Map<String, String> pillarData, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Dangrek',
            ),
          ),
          SizedBox(height: 8),
          Table(
            columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
            children: [
              _buildAnalysisRow('Heavenly Stem', '${pillarData['heavenlyStem']} (${pillarData['stemElement']})'),
              _buildAnalysisRow('Earthly Branch', '${pillarData['earthlyBranch']} (${pillarData['branchElement']})'),
              _buildAnalysisRow('Hidden Stems', '${pillarData['hiddenStems']} (${pillarData['hiddenElements']})'),
              _buildAnalysisRow('Nayin', '${pillarData['nayin']}: ${pillarData['nayinMeaning']}'),
              if (pillarData['specialStar'] != 'N/A')
                _buildAnalysisRow('Special Star', '${pillarData['specialStar']}: ${pillarData['starMeaning']}'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildAnalysisRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontFamily: 'Dangrek',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Siemreap',
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForElement(String? element) {
    switch (element) {
      case 'Wood': return Colors.green;
      case 'Fire': return Colors.red;
      case 'Earth': return Colors.yellow;
      case 'Metal': return Colors.white;
      case 'Water': return Colors.blue;
      default: return Colors.white;
    }
  }

// Helper method to build pillar information row
  TableRow _buildPillarRow(String title, List<String> data) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Dangrek',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.isNotEmpty && data[0].isNotEmpty)
                Text(
                  'អាកាស: ${data[0]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Dangrek',
                  ),
                ),
              if (data.length > 1 && data[1].isNotEmpty)
                Text(
                  'ដី: ${data[1]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Dangrek',
                  ),
                ),
              if (data.length > 2 && data[2].isNotEmpty)
                Text(
                  'អាកាសកំបាំង: ${data[2]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Dangrek',
                  ),
                ),
              if (data.length > 3 && data[3].isNotEmpty)
                Text(
                  'ណាយិន: ${data[3]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Dangrek',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

// Helper method to build star information
  Widget _buildStarInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Dangrek',
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Dangrek',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Interpretation Dialog
  void _showInterpretationDialog() {
    DateTime displayDate = isCustomBazi ? selectedDate : DateTime.now();
    Map<String, String> starInfo = BaziCalculator.getNineStarInfo(displayDate);
    int starNumber = int.parse(starInfo['starNumber']!);

    final starImages = {
      1: 'assets/images/star1.png',
      2: 'assets/images/star2.png',
      3: 'assets/images/star3.png',
      4: 'assets/images/star4.png',
      5: 'assets/images/star5.png',
      6: 'assets/images/star6.png',
      7: 'assets/images/star7.png',
      8: 'assets/images/star8.png',
      9: 'assets/images/star9.png',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.4),
          content: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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

                        // Star name and basic info
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                starInfo['name']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStarColor(starNumber),
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'កើត: ${DateFormat('yyyy-MM-dd').format(displayDate)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Star attributes
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              _buildAttributeRow('ធាតុ', starInfo['element']!),
                              _buildAttributeRow('ទិស', starInfo['direction']!),
                              _buildAttributeRow('ព័ណ៌', starInfo['color']!),
                              _buildAttributeRow('អ៊ីនយ៉ាង', starInfo['yinYang']!),
                              _buildAttributeRow('គ័រ', starInfo['luck']!),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Characteristics
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'តារាកំណើតលេខ $starNumber ប្រចាំខ្លួន',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                starInfo['characteristics']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Siemreap',
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Advice
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'វេលាហេង និងឆុង',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Dangrek',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                starInfo['advice']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Siemreap',
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

              // Star image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _starAnimation.value,
                        child: Image.asset(
                          starImages[starNumber]!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
          Center(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.5),
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

  Color _getStarColor(int starNumber) {
    switch (starNumber) {
      case 1: return Colors.white;
      case 2: return Colors.black;
      case 3: return Colors.green;
      case 4: return Colors.green[400]!;
      case 5: return Colors.yellow;
      case 6: return Colors.white;
      case 7: return Colors.red;
      case 8: return Colors.white;
      case 9: return Colors.purple;
      default: return Colors.white;
    }
  }

  TableRow _buildAttributeRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Dangrek',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Dangrek',
            ),
          ),
        ),
      ],
    );
  }

// Helper function to get color based on star number
  }

// Custom Glass Morphism Container for Bazi Result
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;

  const GlassMorphismContainer({
    super.key, // Added Key parameter
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
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
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
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
    return Theme(
      data: ThemeData.light().copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.light,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Dangrek',
              fontSize: 18,
            ),
            pickerTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Dangrek',
            ),
          ),
        ),
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassMorphismContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ជ្រើសរើសកាលបរិច្ឆេទ',
                  style: TextStyle(
                    fontFamily: 'Dangrek',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
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
                    backgroundColor: Colors.red.withValues(alpha:0.5),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontFamily: 'Dangrek'),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _selectedDate);
                  },
                  child: Text('បញ្ជាក់'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

