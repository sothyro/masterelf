import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math';
import 'dart:ui'; // For blur effect

class LopanScreen extends StatefulWidget {
  const LopanScreen({Key? key}) : super(key: key);

  @override
  _LopanScreenState createState() => _LopanScreenState();
}

class _LopanScreenState extends State<LopanScreen> {
  double? _heading;
  double _smoothedHeading = 0.0;
  final TransformationController _transformationController = TransformationController();
  final double _smoothingFactor = 0.1;

  @override
  void initState() {
    super.initState();
    _startCompass();
  }

  void _startCompass() {
    FlutterCompass.events?.listen((CompassEvent? event) {
      if (event != null && event.heading != null) {
        setState(() {
          _heading = event.heading;
          _smoothedHeading = _applyLowPassFilter(_smoothedHeading, _heading! % 360);
        });
      }
    });
  }

  double _applyLowPassFilter(double previousValue, double newValue) {
    double delta = newValue - previousValue;
    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }
    return previousValue + _smoothingFactor * delta;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
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
              color: Colors.black.withValues(alpha: 0.3), // Adjust opacity for the blur effect
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Zoomable Lopan Image with Double-Tap-to-Reset
                        GestureDetector(
                          onDoubleTap: _resetZoom,
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.center,
                              child: InteractiveViewer(
                                transformationController: _transformationController,
                                boundaryMargin: const EdgeInsets.all(double.infinity),
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: Transform.rotate(
                                  angle: (_smoothedHeading) * (pi / 180),
                                  child: Image.asset(
                                    'assets/images/lopanhd.png',
                                    width: 300,
                                    height: 300,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Align the two text widgets horizontally
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGlassMorphismButton(
                              Text(
                                'បែទៅដឺក្រេ: ${_smoothedHeading.toStringAsFixed(2)}°',
                                style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10), // Add spacing between the two text widgets
                            if (_heading != null) _buildMountainLabel(_smoothedHeading),
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

  // Helper method to build the mountain label
  Widget _buildMountainLabel(double heading) {
    final mountains = [
      MountainRange('ជើង1: Ren (壬)', 337.6, 352.5),
      MountainRange('ជើង2: Zi (子)', 352.6, 7.5),
      MountainRange('ជើង3: Gui (癸)', 7.6, 22.5),
      MountainRange('ត្បូង1: Bing (丙)', 157.6, 172.5),
      MountainRange('ត្បូង2: Wu (午)', 172.6, 187.5),
      MountainRange('ត្បូង3: Ding (丁)', 187.6, 202.5),
      MountainRange('កើត1: Jia (甲)', 67.6, 82.5),
      MountainRange('កើត2: Mao (卯)', 82.6, 97.5),
      MountainRange('កើត3: Yi (乙)', 97.6, 112.5),
      MountainRange('លិច1: Geng (庚)', 247.6, 262.5),
      MountainRange('លិច2: You (酉)', 262.6, 277.5),
      MountainRange('លិច3: Xin (辛)', 277.6, 292.5),
      MountainRange('ជើងឈាងកើត1: Zhen (震)', 22.6, 37.5),
      MountainRange('ជើងឈាងកើត2: Gen (艮)', 37.6, 52.5),
      MountainRange('ជើងឈាងកើត3: Chen (辰)', 52.6, 67.5),
      MountainRange('ត្បូងឈាងកើត1: Si (巳)', 112.6, 127.5),
      MountainRange('ត្បូងឈាងកើត2: Xun (巽)', 127.6, 142.5),
      MountainRange('ត្បូងឈាងកើត3: Wu (午)', 142.6, 157.5),
      MountainRange('ត្បូងឈាងលិច1: Kun (坤)', 202.6, 217.5),
      MountainRange('ត្បូងឈាងលិច2: Kun (坤)', 217.6, 232.5),
      MountainRange('ត្បូងឈាងលិច3: Wei (未)', 232.6, 247.5),
      MountainRange('ជើងឈាងលិច1: Qian (乾)', 292.6, 307.5),
      MountainRange('ជើងឈាងលិច2: Qian (乾)', 307.6, 322.5),
      MountainRange('ជើងឈាងលិច3: Xu (戌)', 322.6, 337.5),
    ];

    // Find the mountain corresponding to the current heading
    final currentMountain = mountains.firstWhere(
          (mountain) => _isHeadingInRange(heading, mountain.startDegree, mountain.endDegree),
      orElse: () => MountainRange('ផុតដង្ហើម', 0, 0), // Default if no mountain is found
    );

    return _buildGlassMorphismButton(
      Text(
        currentMountain.label,
        style: const TextStyle(fontSize: 14, fontFamily: 'Dangrek', fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // Helper method to check if the heading is within a range
  bool _isHeadingInRange(double heading, double startDegree, double endDegree) {
    if (startDegree > endDegree) {
      // Handle wrap-around ranges (e.g., 352.6° to 7.5°)
      return heading >= startDegree || heading <= endDegree;
    } else {
      return heading >= startDegree && heading <= endDegree;
    }
  }

  // Helper method to create a glass morphism button
  Widget _buildGlassMorphismButton(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduced padding
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.5)),
      ),
      child: child,
    );
  }

  // Build Custom Title with Blur Glass Morphism
  Widget _buildTitle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // Rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.yellowAccent.withValues(alpha: 0.3), // Semi-transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // Light border
              width: 2.2,
            ),
          ),
          child: const Text(
            'ឡកែ ដង្ហើមនាគ ម៉ាស្ទ័រអែល',
            style: TextStyle(
              fontFamily: 'Dangrek',
              fontSize: 20, // Reduced font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class to represent a mountain range
class MountainRange {
  final String label;
  final double startDegree;
  final double endDegree;

  MountainRange(this.label, this.startDegree, this.endDegree);
}