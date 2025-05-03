import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masterelf/screens/moon_blocks_screen.dart';
import 'package:masterelf/widgets/fortune_results.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PrayScreen extends StatefulWidget {
  const PrayScreen({super.key});

  @override
  createState() => _PrayScreenState();
}

class _PrayScreenState extends State<PrayScreen> with TickerProviderStateMixin {
  bool _showList = true;
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isVideoAnimationCompleted = false;
  bool _isBuffering = false;
  late AnimationController _videoAnimationController;
  bool _isPlaylistExpanded = false;
  int? _selectedIndex;

  final List<String> _playlistItems = [
    "ក្រឡុកស៊ីមស៊ី",
    "ក្រឡាប់ព្រះច័ន្ទ",
    "រៀបចំសែនព្រេន",
    "កាត់ឆុងលើករាសី",
  ];

  // Updated video URLs
  final List<String> _videoUrls = [
    'assets/videos/pray.mp4', // Default video
    'https://period9.masterelf.vip/app/period9/mindtreatment.mp4',
    'https://period9.masterelf.vip/app/period9/blessing.mp4',
  ];

  // Kau Cim game variables
  late AnimationController _gameAnimationController;
  bool _isGameAnimating = false;
  bool _showGameResult = false;
  int _resultNumber = 0;
  int _playsToday = 0;
  List<double> _accelerometerValues = [0, 0, 0];
  List<double> _previousAccelerometerValues = [0, 0, 0];
  bool _showGame = false;

  // Shake timing variables
  bool _isShaking = false;
  Duration _shakeDuration = Duration.zero;
  Timer? _shakeTimer;

  @override
  void initState() {
    super.initState();
    _videoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _gameAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initializeDefaultVideoFirst();
    _loadPlayData();
    _startAccelerometer();
  }

  void _initializeDefaultVideoFirst() async {
    setState(() {
      _isLoading = true;
      _isVideoAnimationCompleted = false;
    });

    // First load the default asset video
    _controller = VideoPlayerController.asset(_videoUrls[0])
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
        _controller.setLooping(true);

        // Now try to load the updated network video
        _tryLoadNetworkVideo();
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
      });

    _controller.addListener(_onVideoCompletion);
    _controller.addListener(_onBufferingUpdate);
  }

  void _tryLoadNetworkVideo() async {
    try {
      final updatedController = VideoPlayerController.networkUrl(
        Uri.parse('https://period9.masterelf.vip/app/period9/pray_update.mp4'),
      );

      await updatedController.initialize();

      // If successful, replace with the updated video
      if (mounted) {
        setState(() {
          _controller.dispose();
          _controller = updatedController;
          _isLoading = false;
        });
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      // If failed, keep playing the default video
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _handleShake() {
    if (!_isGameAnimating) return;

    if (!_isShaking) {
      setState(() {
        _isShaking = true;
        _shakeDuration = Duration.zero;
      });
      _gameAnimationController.repeat();

      _shakeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isShaking) {
          setState(() {
            _shakeDuration += const Duration(seconds: 1);
          });

          if (_shakeDuration.inSeconds >= 5) {
            _finishGameAnimation();
            timer.cancel();
          }
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _startGame() {
    if (_playsToday >= 30) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '១ថ្ងៃ យើងផ្សងបាន ៣ដង!\nវេលាស្អែកទើបអាចផ្សងទៀតបាន',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
            width: 300,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ ក្រឡុកទូរស័ព្ទ ✨',
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

    if (mounted) {
      setState(() {
        _isPlaylistExpanded = false;
        _showGame = true;
        _isGameAnimating = true;
        _showGameResult = false;
        _isShaking = false;
        _gameAnimationController.stop();
        _showList = false;
      });
    }
  }


  void _startAccelerometer() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      final newValues = [event.x, event.y, event.z];

      if ((newValues[0] - _accelerometerValues[0]).abs() > 0.1 ||
          (newValues[1] - _accelerometerValues[1]).abs() > 0.1 ||
          (newValues[2] - _accelerometerValues[2]).abs() > 0.1) {
        setState(() {
          _previousAccelerometerValues = _accelerometerValues;
          _accelerometerValues = newValues;
        });

        if (_isGameAnimating) {
          _detectShake();
        } else if (_isShaking) {
          setState(() {
            _isShaking = false;
          });
          _gameAnimationController.stop();
        }
      }
    });
  }

  void _finishGameAnimation() {
    _shakeTimer?.cancel();
    setState(() {
      _isGameAnimating = false;
      _isShaking = false;
      _gameAnimationController.stop();
      _resultNumber = 1 + (DateTime.now().millisecond % 100);
      _showGameResult = true;
      _playsToday++;
      _savePlayData();
    });
  }

  void _onVideoCompletion() {
    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isLooping) {
      _replaceVideo(_videoUrls[0]);
    }
  }

  void _onBufferingUpdate() {
    if (_controller.value.isBuffering && !_isBuffering) {
      setState(() {
        _isBuffering = true;
      });
      _playLottieAnimation();
    } else if (!_controller.value.isBuffering && _isBuffering) {
      setState(() {
        _isBuffering = false;
      });
    }
  }

  void _playLottieAnimation() {
    _videoAnimationController.reset();
    _videoAnimationController.forward();
  }

  void _onVideoAnimationCompleted() {
    setState(() {
      _isVideoAnimationCompleted = true;
    });
  }

  void _replaceVideo(String videoSource) async {
    setState(() {
      _isLoading = true;
      _isVideoAnimationCompleted = false;
    });

    await _controller.dispose();

    if (videoSource.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoSource));
    } else {
      _controller = VideoPlayerController.asset(videoSource);
    }

    _controller
        .initialize()
        .then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.play();
          _controller.setLooping(videoSource == _videoUrls[0]);
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
          });
        });

    _controller.addListener(_onVideoCompletion);
    _controller.addListener(_onBufferingUpdate);
    _playLottieAnimation();
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoCompletion);
    _controller.removeListener(_onBufferingUpdate);
    _controller.dispose();
    _videoAnimationController.dispose();
    _gameAnimationController.dispose();
    _shakeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPlayData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastPlayDate');
    final today = DateTime.now();

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      if (DateFormat('yyyy-MM-dd').format(lastDate) ==
          DateFormat('yyyy-MM-dd').format(today)) {
        setState(() {
          _playsToday = prefs.getInt('playsToday') ?? 0;
        });
      }
    }
  }

  Future<void> _savePlayData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    await prefs.setString('lastPlayDate', today.toString());
    await prefs.setInt('playsToday', _playsToday);
  }

  void _detectShake() {
    double deltaX =
        (_accelerometerValues[0] - _previousAccelerometerValues[0]).abs();
    double deltaY =
        (_accelerometerValues[1] - _previousAccelerometerValues[1]).abs();
    double deltaZ =
        (_accelerometerValues[2] - _previousAccelerometerValues[2]).abs();

    const shakeThreshold = 2.5;
    if (deltaX > shakeThreshold ||
        deltaY > shakeThreshold ||
        deltaZ > shakeThreshold) {
      _handleShake();
    }
  }

  void _closeGame() {
    setState(() {
      _showGame = false;
      _showGameResult = false;
      _isGameAnimating = false;
      _showList = true;
    });
  }

  void _showFortuneDialog() {
    // Get the fortune result for the current number
    final result = fortuneResults[_resultNumber] ?? fortuneResults[100]!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.4),
          content: Stack(
            children: [
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
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
                        const SizedBox(height: 40),
                        // Fortune content
                        Text(
                          result.khmerTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Dangrek',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          result.fortuneType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.yellow,
                            fontFamily: 'Dangrek',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "${result.chineseTitle} (${result.pinyin})",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Dangrek',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '"${result.englishTitle}"',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontFamily: 'Siemreap',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "ប្រាស្នាចារថា",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontFamily: 'Dangrek',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '"${result.keyLine}"',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Dangrek',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '"${result.keyLineTranslation}"',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontFamily: 'Siemreap',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "ទំនាយទាយថា",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                            fontFamily: 'Dangrek',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        ...result.prophecy.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              2.0,
                              8.0,
                              2.0,
                            ), // Left padding of 16, right of 8
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${entry.key}: ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Dangrek',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontFamily: 'Siemreap',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/ybg.jpg', fit: BoxFit.cover),
          ),

          if (!_isLoading && _isVideoAnimationCompleted && !_isBuffering)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

          if (_isLoading || _isBuffering || !_isVideoAnimationCompleted)
            Center(
              child: Lottie.asset(
                'assets/jsons/loading_animation.json',
                controller: _videoAnimationController,
                onLoaded: (composition) {
                  _videoAnimationController
                    ..duration = composition.duration
                    ..forward().whenComplete(_onVideoAnimationCompleted);
                },
              ),
            ),

          if (_showGame) ...[
            Container(color: Colors.black54),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  if (!_showGameResult)
                    GestureDetector(
                      onTap: _startGame,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.asset(
                            'assets/jsons/lightray.json',
                            controller: _gameAnimationController,
                            width: 350,
                            height: 350,
                            fit: BoxFit.contain,
                            animate: _isShaking,
                          ),
                          Image.asset(
                            'assets/images/kaucim.png',
                            width: 300,
                            height: 300,
                          ),
                        ],
                      ),
                    ),
                  if (_showGameResult)
                    GestureDetector(
                      onTap: _showFortuneDialog,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/kaucim_stick.png',
                            width: 350,
                            height: 350,
                          ),
                          Text(
                            '$_resultNumber',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Dangrek',
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 0),
                  if (!_isGameAnimating && !_showGameResult)
                    ElevatedButton(
                      onPressed: _startGame,
                      child: const Text('ក្រឡុកផ្សងស៊ីមស៊ី'),
                    ),
                  const SizedBox(height: 00),
                  const SizedBox(height: 00),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: ElevatedButton(
                        onPressed: _closeGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontFamily: 'Dangrek'),
                        ),
                        child: const Text('ចេញទៅវិញ'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Positioned(
            right: 16.0,
            bottom: 80.0,
            child:
                (_isLoading ||
                        _isBuffering ||
                        !_isVideoAnimationCompleted ||
                        !_showList)
                    ? Container()
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: 120.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPlaylistExpanded = !_isPlaylistExpanded;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'រៀបពិធី',
                                    style: TextStyle(
                                      fontFamily: 'Dangrek',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              if (_isPlaylistExpanded)
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _playlistItems.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (index == 0) {
                                          _startGame(); // First item - Kau Cim game
                                        } else if (index == 1) {
                                          // Second item - Moon Blocks game
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const MoonBlocksScreen(),
                                            ),
                                          );
                                        } else {
                                          // Handle special videos for index 2 and 3
                                          try {
                                            String videoUrl;
                                            if (index == 2) {
                                              videoUrl =
                                                  'https://period9.masterelf.vip/app/period9/mindtreatment.mp4';
                                            } else {
                                              videoUrl =
                                                  'https://period9.masterelf.vip/app/period9/blessing.mp4';
                                            }

                                            final newController =
                                                VideoPlayerController.networkUrl(
                                                  Uri.parse(videoUrl),
                                                );
                                            await newController.initialize();

                                            _controller.dispose();
                                            _controller = newController;
                                            setState(() {
                                              _selectedIndex = index;
                                              _showGame = false;
                                              _isPlaylistExpanded = false;
                                            });
                                            _controller.play();
                                            _controller.setLooping(true);
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Nothing can be done at the moment',
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            // Continue playing default video
                                            _replaceVideo(_videoUrls[0]);
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 12.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedIndex == index
                                                  ? Colors.yellow.withValues(
                                                    alpha: 0.3,
                                                  )
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            4.0,
                                          ),
                                        ),
                                        child: Text(
                                          _playlistItems[index],
                                          style: const TextStyle(
                                            fontFamily: 'Dangrek',
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    // Add divider after the second item (index 1)
                                    return index == 1
                                        ? Divider(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          height: 1,
                                          thickness: 1,
                                          indent: 16,
                                          endIndent: 16,
                                        )
                                        : const SizedBox.shrink();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
