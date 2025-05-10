import 'dart:math';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';

class LopanScreen extends StatefulWidget {
  const LopanScreen({super.key});

  @override
  createState() => _LopanScreenState();
}

class _LopanScreenState extends State<LopanScreen> {
  double? _heading;
  double _smoothedHeading = 0.0;
  final TransformationController _transformationController =
  TransformationController();
  final double _smoothingFactor = 0.1;
  bool _isLocked = false;
  bool _useAlternateImage = false;
  final GlobalKey _compassKey = GlobalKey(); //_compassKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startCompass();
  }

  void _startCompass() {
    FlutterCompass.events?.listen((CompassEvent? event) {
      if (event != null && event.heading != null && !_isLocked) {
        setState(() {
          _heading = event.heading;
          // Normalize to 0-360 range
          double normalizedHeading = _heading! % 360;
          if (normalizedHeading < 0) normalizedHeading += 360;
          _smoothedHeading = _applyLowPassFilter(
            _smoothedHeading,
            normalizedHeading,
          );
          // Ensure smoothed heading stays in 0-360 range
          _smoothedHeading = _smoothedHeading % 360;
          if (_smoothedHeading < 0) _smoothedHeading += 360;
        });
      }
    });
  }

  double _applyLowPassFilter(double previousValue, double newValue) {
    // Calculate shortest path difference considering circular nature
    double diff = newValue - previousValue;
    double delta = diff - 360 * (diff / 360).round();
    return previousValue + _smoothingFactor * delta;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Future<void> _takeScreenshot() async {
    try {
      // Find the render object
      final renderObject = _compassKey.currentContext?.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        throw Exception('Could not find render boundary');
      }

      // Capture the image
      final boundary = renderObject; //as RenderRepaintBoundary
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not capture image bytes');
      }

      // Save to temporary file
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/compass_screenshot.png')
          .writeAsBytes(byteData.buffer.asUint8List());

      // Share the image
      await Share.shareXFiles([XFile(imagePath.path)],
          text: 'នេះជាទិសដែលឡកែម៉ាស្ទ័រអេលបង្ហាញ!');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ថតអត់ជាប់ទេ: $e',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.transparent,
          width: 300,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
    });
  }

  void _toggleImage() {
    setState(() {
      _useAlternateImage = !_useAlternateImage;
    });
  }

  void _calibrateCompass() {
    setState(() {
      _smoothedHeading = _heading ?? _smoothedHeading;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ សារ៉េឡកែរួចហើយ ✨',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.transparent,
          width: 300,
          duration: const Duration(seconds: 2),
        ),
      );
    });
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
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: Container(color: Colors.black.withValues(alpha:0.3)),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 50),
                _buildTitle(),
                const SizedBox(height: 0),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Lopan image with inverse rotation
                        RepaintBoundary(
                          key: _compassKey,
                          child: GestureDetector(
                            onDoubleTap: _resetZoom,
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.center,
                                child: InteractiveViewer(
                                  transformationController:
                                  _transformationController,
                                  boundaryMargin: const EdgeInsets.all(
                                    double.infinity,
                                  ),
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Compass overlay (behind the image)
                                      Transform.rotate(
                                        angle: -_smoothedHeading * (pi / 180),
                                        child: SizedBox( //Container(
                                          width: 350, // Larger than image
                                          height: 350, // Larger than image
                                          child: CustomPaint(
                                            painter: CompassRosePainter(),
                                          ),
                                        ),
                                      ),
                                      // Lopan image (on top)
                                      Transform.rotate(
                                        angle: -_smoothedHeading * (pi / 180),
                                        child: Image.asset(
                                          _useAlternateImage
                                              ? 'assets/images/lopanhd2.png'
                                              : 'assets/images/lopanhd.png',
                                          width: 250,
                                          height: 250,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        // Degree and mountain display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGlassMorphismButton(
                              Text(
                                'បែទៅដឺក្រេ: ${_smoothedHeading.toStringAsFixed(2)}°',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Dangrek',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (_heading != null)
                              _buildMountainLabel(_smoothedHeading),
                          ],
                        ),
                        const SizedBox(height: 0),
                        // New buttons side by side
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _takeScreenshot,
                              child: _buildGlassMorphismButton(
                                Text(
                                  'ថត📷',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Dangrek',
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _toggleLock,
                              child: _buildGlassMorphismButton(
                                Text(
                                  _isLocked ? 'ដក🔓' : 'ចាក់🔒',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Dangrek',
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _toggleImage,
                              child: _buildGlassMorphismButton(
                                Text(
                                  'ប្តូរ🥏',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Dangrek',
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _calibrateCompass,
                              child: _buildGlassMorphismButton(
                                Text(
                                  'ជួយ♾️',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Dangrek',
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMountainLabel(double heading) {
    final mountains = [
      MountainRange('ជើងN2: Zi (子)', 352.5, 7.5),
      MountainRange('ជើងN3: Gui (癸)', 7.5, 22.5),
      MountainRange('ជើង/កើតNE1: Chou (丑)', 22.5, 37.5),
      MountainRange('ជើង/កើតNE2: Gen (艮)', 37.5, 52.5),
      MountainRange('ជើង/កើតNE3: Yin (寅)', 52.5, 67.5),
      MountainRange('កើតE1: Jia (甲)', 67.5, 82.5),
      MountainRange('កើតE2: Mao (卯)', 82.5, 97.5),
      MountainRange('កើតE3: Yi (乙)', 97.5, 112.5),
      MountainRange('ត្បូង/កើតSE1: Chen (辰)', 112.5, 127.5),
      MountainRange('ត្បូង/កើតSE2: Xun (巽)', 127.5, 142.5),
      MountainRange('ត្បូង/កើតSE3: Si (巳)', 142.5, 157.5),
      MountainRange('ត្បូងS1: Bing (丙)', 157.5, 172.5),
      MountainRange('ត្បូងS2: Wu (午)', 172.5, 187.5),
      MountainRange('ត្បូងS3: Ding (丁)', 187.5, 202.5),
      MountainRange('ត្បូង/លិចSW1: Wei (未)', 202.5, 217.5),
      MountainRange('ត្បូង/លិចSW2: Kun (坤)', 217.5, 232.5),
      MountainRange('ត្បូង/លិចSW3: Shen (申)', 232.5, 247.5),
      MountainRange('លិចW1: Geng (庚)', 247.5, 262.5),
      MountainRange('លិចW2: You (酉)', 262.5, 277.5),
      MountainRange('លិចW3: Xin (辛)', 277.5, 292.5),
      MountainRange('ជើង/លិចNW1: Xu (戌)', 292.5, 307.5),
      MountainRange('ជើង/លិចNW2: Qian (乾)', 307.5, 322.5),
      MountainRange('ជើង/លិខNW3: Hai (亥)', 322.5, 337.5),
      MountainRange('ជើងN1: Ren (壬)', 337.5, 352.5),
    ];

    final currentMountain = mountains.firstWhere(
          (mountain) =>
          _isHeadingInRange(heading, mountain.startDegree, mountain.endDegree),
      orElse: () => MountainRange('ផុតដង្ហើម', 0, 0),
    );

    return _buildGlassMorphismButton(
      Text(
        currentMountain.label,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Dangrek',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  bool _isHeadingInRange(double heading, double startDegree, double endDegree) {
    if (startDegree > endDegree) {
      return heading >= startDegree || heading <= endDegree;
    } else {
      return heading >= startDegree && heading <= endDegree;
    }
  }

  Widget _buildGlassMorphismButton(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.5)),
      ),
      child: child,
    );
  }

  Widget _buildTitle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.yellowAccent.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha:0.3),
              width: 2.2,
            ),
          ),
          child: const Text(
            'ឡកែ ដង្ហើមនាគ ម៉ាស្ទ័រអែល',
            style: TextStyle(
              fontFamily: 'Dangrek',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class MountainRange {
  final String label;
  final double startDegree;
  final double endDegree;

  MountainRange(this.label, this.startDegree, this.endDegree);
}

class CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85; // Reduced ring size

    // Draw the compass circle
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha:0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 0.9, circlePaint);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Swapped directions: N ↔ W, S ↔ E
    const cardinalDirections = ['E', 'ត្បូង', 'W', 'ជើង'];
    const intercardinalDirections = ['SE', '西南', 'NW', '東北'];

    // Draw cardinal directions (W, S, E, N)
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final direction = cardinalDirections[i];

      // Draw the main cardinal direction line
      final linePaint = Paint()
        ..color = direction == 'N'
            ? Colors.red.withValues(alpha:0.7)
            : direction == 'S'
            ? Colors.purple.withValues(alpha:0.7)
            : Colors.white.withValues(alpha:0.7)
        ..strokeWidth = 2.0;

      final x = center.dx + cos(angle) * radius * 0.7;
      final y = center.dy + sin(angle) * radius * 0.7;
      canvas.drawLine(center, Offset(x, y), linePaint);

      // Draw the cardinal direction text (outside the ring)
      textPainter.text = TextSpan(
        text: direction,
        style: TextStyle(
          color: direction == 'ជើង'
              ? Colors.redAccent
              : direction == 'ត្បូង'
              ? Colors.deepPurpleAccent
              : Colors.white,
          fontSize: 22,
          fontFamily: 'Dangrek',
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final textX = center.dx + cos(angle) * radius * 1.02 -
          textPainter.width / 2;
      final textY = center.dy + sin(angle) * radius * 1.02 -
          textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // Draw intercardinal directions (SW, SE, NE, NW)
    for (int i = 0; i < 4; i++) {
      final angle = (i * 2 + 1) * pi / 4;
      final direction = intercardinalDirections[i];

      // Draw the intercardinal direction text (outside the ring)
      textPainter.text = TextSpan(
        text: direction,
        style: TextStyle(
          color: Colors.white.withValues(alpha:0.8),
          fontSize: 14,
        ),
      );
      textPainter.layout();

      final textX = center.dx + cos(angle) * radius * 1.1 -
          textPainter.width / 2;
      final textY = center.dy + sin(angle) * radius * 1.1 -
          textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // Draw degree markings (without numbers)
    final degreePaint = Paint()
      ..color = Colors.white.withValues(alpha:0.6)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * pi / 180;
      final innerRadius = i % 15 == 0 ? radius * 0.85 : radius * 0.88;
      final outerRadius = i % 15 == 0 ? radius * 0.95 : radius * 0.92;

      final x1 = center.dx + cos(angle) * innerRadius;
      final y1 = center.dy + sin(angle) * innerRadius;
      final x2 = center.dx + cos(angle) * outerRadius;
      final y2 = center.dy + sin(angle) * outerRadius;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), degreePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}