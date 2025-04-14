import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class PrayScreen extends StatefulWidget {
  const PrayScreen({super.key});

  @override
  createState() => _PrayScreenState(); // Dart automatically infers State<PrayScreen>
}

class _PrayScreenState extends State<PrayScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isAnimationCompleted = false;
  bool _isBuffering = false; // Track buffering state
  late AnimationController _animationController;

  // Variables for playlist functionality
  bool _isPlaylistExpanded = false;
  int? _selectedIndex;
  final List<String> _playlistItems = [
    "បន់ស្រន់",
    "សូត្រគាថា",
    "ព្យាបាលចិត្ត",
    "ដេញចង្រៃ",
    "ដាស់ហេង",
  ];

  // List of video URLs corresponding to playlist items
  final List<String> _videoUrls = [
    'assets/videos/pray.mp4', // Default video (index 0)
    'https://masterelf.vip/wp-content/uploads/app/pray1.mp4',
    'https://masterelf.vip/wp-content/uploads/app/pray2.mp4',
    'https://masterelf.vip/wp-content/uploads/app/pray3.mp4',
    'https://masterelf.vip/wp-content/uploads/app/pray4.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeDefaultVideo(); // Initialize default video
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  // Initialize default video from assets
  void _initializeDefaultVideo() async {
    setState(() {
      _isLoading = true;
      _isAnimationCompleted = false;
    });

    _controller = VideoPlayerController.asset(_videoUrls[0])
      ..initialize()
          .then((_) {
            setState(() {
              _isLoading = false;
            });
            _controller.play();
            _controller.setLooping(true); // Loop the default video
          })
          .catchError((error) {
            setState(() {
              _isLoading = false;
            });
            //print("Error loading default video: $error");
          });

    // Listen for video completion
    _controller.addListener(_onVideoCompletion);

    // Listen for buffering updates
    _controller.addListener(_onBufferingUpdate);
  }

  // Handle video completion
  void _onVideoCompletion() {
    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isLooping) {
      // If the video is not looping and has finished, switch back to the default video
      _replaceVideo(_videoUrls[0]);
    }
  }

  // Handle buffering updates
  void _onBufferingUpdate() {
    if (_controller.value.isBuffering && !_isBuffering) {
      setState(() {
        _isBuffering = true; // Show Lottie animation when buffering
      });
      _playLottieAnimation(); // Play the Lottie animation when buffering starts
    } else if (!_controller.value.isBuffering && _isBuffering) {
      setState(() {
        _isBuffering =
            false; // Hide Lottie animation when buffering is complete
      });
    }
  }

  // Play the Lottie animation
  void _playLottieAnimation() {
    _animationController.reset(); // Reset the animation
    _animationController.forward(); // Play the animation
  }

  // Replace video with a new one (either asset or network)
  void _replaceVideo(String videoSource) async {
    setState(() {
      _isLoading = true;
      _isAnimationCompleted = false; // Reset animation completion state
    });

    await _controller.dispose(); // Dispose the previous controller

    if (videoSource.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoSource),
      ); // Load network video
    } else {
      _controller = VideoPlayerController.asset(
        videoSource,
      ); // Load asset video
    }

    _controller
        .initialize()
        .then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.play();
          _controller.setLooping(
            videoSource == _videoUrls[0],
          ); // Loop only the default video
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
          });
          //print("Error loading video: $error");
        });

    // Listen for video completion
    _controller.addListener(_onVideoCompletion);

    // Listen for buffering updates
    _controller.addListener(_onBufferingUpdate);

    // Play the Lottie animation once when loading a new video
    _playLottieAnimation();
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoCompletion);
    _controller.removeListener(_onBufferingUpdate);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationCompleted() {
    setState(() {
      _isAnimationCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/ybg.jpg', fit: BoxFit.cover),
          ),

          // Video Player (only shown after Lottie animation completes and not buffering)
          if (!_isLoading && _isAnimationCompleted && !_isBuffering)
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

          // Lottie Animation (shown while loading, buffering, or until animation completes)
          if (_isLoading || _isBuffering || !_isAnimationCompleted)
            Center(
              child: Lottie.asset(
                'assets/jsons/loading_animation.json',
                controller: _animationController,
                onLoaded: (composition) {
                  _animationController
                    ..duration = composition.duration
                    ..forward().whenComplete(() => _onAnimationCompleted());
                },
              ),
            ),

          // Floating Playlist with Glass Morphism
          Positioned(
            right: 16.0,
            bottom: 80.0,
            child: ClipRRect(
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
                      // Header
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPlaylistExpanded = !_isPlaylistExpanded;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
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

                      // Playlist Items (only visible when expanded)
                      if (_isPlaylistExpanded)
                        ..._playlistItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          String item = entry.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });

                              // Replace the video based on the selected index
                              _replaceVideo(_videoUrls[index]);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _selectedIndex == index
                                        ? Colors.yellow.withValues(alpha: 0.3)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontFamily: 'Dangrek',
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }),
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
