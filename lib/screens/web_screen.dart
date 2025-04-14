import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' as ui;
import 'package:lottie/lottie.dart';

class WebScreen extends StatefulWidget {
  final String url;

  const WebScreen({super.key, required this.url});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  late final WebViewController controller;
  static const shadowColor = Color(0x4D000000); // Black with 30% opacity
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Hide loading when page finishes loading
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // WebView as the main content
          WebViewWidget(controller: controller),

          // Loading overlay (shown only while loading)
          if (_isLoading)
            Container(
              color: Colors.black, // Optional: add a background color
              child: Stack(
                children: [
                  // Full-screen background image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/ybg.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Lottie animation centered on top of the image
                  Center(
                    child: Lottie.asset(
                      'assets/jsons/loading_animation.json',
                      width: 350,
                      height: 350,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ],
              ),
            ),

          // Bottom center close button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // Close the screen when tapped
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'ត្រលប់ទៅវិញ',
                        style: TextStyle(
                          fontFamily: 'Dangrek',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: shadowColor,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
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