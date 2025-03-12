import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math';
import 'dart:ui';

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
          // Normalize to 0-360 range
          double normalizedHeading = _heading! % 360;
          if (normalizedHeading < 0) normalizedHeading += 360;
          _smoothedHeading = _applyLowPassFilter(_smoothedHeading, normalizedHeading);
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
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lopan image with inverse rotation
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
                                  angle: -_smoothedHeading * (pi / 180), // Inverse rotation
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
                        const SizedBox(height: 50),
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

  Widget _buildMountainLabel(double heading) {
    final mountains = [
      MountainRange('N2: Zi (子)', 352.5, 7.5),
      MountainRange('N3: Gui (癸)', 7.5, 22.5),
      MountainRange('NE1: Chou (丑)', 22.5, 37.5),
      MountainRange('NE2: Gen (艮)', 37.5, 52.5),
      MountainRange('NE3: Yin (寅)', 52.5, 67.5),
      MountainRange('E1: Jia (甲)', 67.5, 82.5),
      MountainRange('E2: Mao (卯)', 82.5, 97.5),
      MountainRange('E3: Yi (乙)', 97.5, 112.5),
      MountainRange('SE1: Chen (辰)', 112.5, 127.5),
      MountainRange('SE2: Xun (巽)', 127.5, 142.5),
      MountainRange('SE3: Si (巳)', 142.5, 157.5),
      MountainRange('S1: Bing (丙)', 157.5, 172.5),
      MountainRange('S2: Wu (午)', 172.5, 187.5),
      MountainRange('S3: Ding (丁)', 187.5, 202.5),
      MountainRange('SW1: Wei (未)', 202.5, 217.5),
      MountainRange('SW2: Kun (坤)', 217.5, 232.5),
      MountainRange('SW3: Shen (申)', 232.5, 247.5),
      MountainRange('W1: Geng (庚)', 247.5, 262.5),
      MountainRange('W2: You (酉)', 262.5, 277.5),
      MountainRange('W3: Xin (辛)', 277.5, 292.5),
      MountainRange('NW1: Xu (戌)', 292.5, 307.5),
      MountainRange('NW2: Qian (乾)', 307.5, 322.5),
      MountainRange('NW3: Hai (亥)', 322.5, 337.5),
      MountainRange('N1: Ren (壬)', 337.5, 352.5),
    ];

    final currentMountain = mountains.firstWhere(
          (mountain) => _isHeadingInRange(heading, mountain.startDegree, mountain.endDegree),
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
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.yellowAccent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
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