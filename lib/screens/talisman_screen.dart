import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'dart:async'; // Added for Timer

class TalismanScreen extends StatefulWidget {
  const TalismanScreen({super.key});

  @override
  State<TalismanScreen> createState() => _TalismanScreenState();
}

class _TalismanScreenState extends State<TalismanScreen>
    with TickerProviderStateMixin {

  // Map of talisman descriptions
  final Map<String, String> talismanDescriptions = {
    '五路財神': 'យ័ន្តនេះជាយ័ន្តសម្រាប់ទាក់ទាញទ្រព្យសម្បត្តិពីទិសទាំង៥។ វាជួយឲ្យអ្នកមានសំបុត្រប្រាក់ច្រើន និងមានជោគជ័យក្នុងការងារ។',
    '南路財神': 'យ័ន្តសម្រាប់ទាក់ទាញទ្រព្យសម្បត្តិពីទិសខាងត្បូង។ ល្អសម្រាប់អ្នកដែលធ្វើអាជីវកម្មទាក់ទងនឹងការផ្គត់ផ្គង់។',
    '濟公賜福': 'យ័ន្តពរពីព្រះចិដ្ឋានុ។ ជួយឲ្យអ្នកជៀសវាងគ្រោះថ្នាក់ និងមានសុខភាពល្អ។',
    '西南路財神': 'យ័ន្តសម្រាប់ទាក់ទាញទ្រព្យពីទិសនិរតី។ ល្អសម្រាប់អ្នកដែលធ្វើអាជីវកម្មទាក់ទងនឹងសិល្បៈ ឬការបង្រៀន។',
    '五路關羽': 'យ័ន្តការពារពីទិសទាំង៥ដោយព្រះអង្គក្វាន់អ៊ូ។ ល្អសម្រាប់ការពារផ្ទះសម្បែង និងអាជីវកម្ម។',
    'ឡហានបង្ក្រាបនាគ': 'យ័ន្តសម្រាប់ការពារពីអារក្ស និងអំពើអាក្រក់។ ល្អសម្រាប់ការពារអ្នកដំណើរ និងអ្នកដែលធ្វើការនៅពេលយប់។',
    '東南路財神': 'យ័ន្តសម្រាប់ទាក់ទាញទ្រព្យពីទិសអាគ្នេយ៍។ ល្អសម្រាប់អ្នកដែលធ្វើអាជីវកម្មទាក់ទងនឹងបច្ចេកវិទ្យា។',
    'ឡហានបង្ក្រាបខ្លា': 'យ័ន្តសម្រាប់ការពារពីសត្វពាហនៈ និងគ្រោះថ្នាក់ផ្លូវគោក។ ល្អសម្រាប់អ្នកបើកបរ និងអ្នកដំណើរញឹកញាប់។',
    '北路財神': 'យ័ន្តសម្រាប់ទាក់ទាញទ្រព្យពីទិសខាងជើង។ ល្អសម្រាប់អ្នកដែលធ្វើអាជីវកម្មទាក់ទងនឹងអចលនទ្រព្យ។',
  };

  late AnimationController _animationController;
  int _currentPosition = 0;
  bool _showAnimation = false;
  final Random _random = Random();
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    _playRandomAnimation();
    _animationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _playRandomAnimation();
    });
  }

  void _playRandomAnimation() {
    setState(() {
      _currentPosition = _random.nextInt(9);
      _showAnimation = true;
    });

    _animationController.forward().then((_) {
      setState(() {
        _showAnimation = false;
      });
      _animationController.reset();
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showTalismanDialog(String imagePath, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.withValues(alpha: 0.4),
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

                        // Talisman title
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Dangrek',
                            ),
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Talisman image
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.4,
                            ),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Talisman description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            talismanDescriptions[label] ?? 'No description available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'Dangrek',
                            ),
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),

                        // Purchase button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withValues(alpha: 0.7),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              textStyle: TextStyle(
                                fontFamily: 'Dangrek',
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('ជាវយ័ន្តឥឡូវនេះ'),
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
        );
      },
    );
  }

  Widget _buildTalismanItem(String imagePath, String label) {
    return GestureDetector(
      onTap: () => _showTalismanDialog(imagePath, label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 4),
          _buildGlassMorphismButton(
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Dangrek',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMorphismButton(Widget child) {
    return GestureDetector(
      onTap: () {
        // Handle tap if needed (handled by parent GestureDetector)
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.5)),
        ),
        child: child,
      ),
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
            color: Colors.tealAccent.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2.2,
            ),
          ),
          child: const Text(
            'ស្តេចយ័ន្តហេង ការពារ ទេវតាស័ក្តសិទ្ធិ',
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

  Widget _buildTalismanGrid() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTalismanItem('assets/images/row1a.png', '五路財神'),
              SizedBox(width: 4),
              _buildTalismanItem('assets/images/row1b.png', '南路財神'),
              SizedBox(width: 4),
              _buildTalismanItem('assets/images/row1c.png', '濟公賜福'),
            ],
          ),
          SizedBox(height: 12),
          // Row 2
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTalismanItem('assets/images/row2a.png', '西南路財神'),
              SizedBox(width: 4),
              _buildTalismanItem('assets/images/row2b.png', '五路關羽'),
              SizedBox(width: 4),
              _buildTalismanItem('assets/images/row2c.png', '五路財神'),
            ],
          ),
          SizedBox(height: 12),
          // Row 3
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTalismanItem('assets/images/row1c.png', 'ឡហានបង្ក្រាបនាគ'),
              SizedBox(width: 4),
              _buildTalismanItem('assets/images/row1b.png', '東南路財神'),
              SizedBox(width: 4),
              _buildTalismanItem('assets/images/row1c.png', 'ឡហានបង្ក្រាបខ្លា'),
            ],
          ),
        ],
      ),
    );
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
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight + 50),
                _buildTitle(),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: _buildTalismanGrid(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lottie animation overlay
          if (_showAnimation) _buildLottieAnimation(),
        ],
      ),
    );
  }

  Widget _buildLottieAnimation() {
    // Calculate position based on _currentPosition
    final row = _currentPosition ~/ 3;
    final col = _currentPosition % 3;

    // Calculate offsets based on your grid layout
    final double topOffset = kToolbarHeight + 50 + 20 + 20 + (row * (100 + 4 + 40));
    final double leftOffset = MediaQuery.of(context).size.width / 2 - (3 * 100 + 2 * 4) / 2 + col * (100 + 4);

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: IgnorePointer(
        child: Lottie.asset(
          'assets/jsons/thunder2.json',
          controller: _animationController,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}