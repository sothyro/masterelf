import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lottie/lottie.dart';

class TalismanScreen extends StatefulWidget {
  const TalismanScreen({Key? key}) : super(key: key);

  @override
  _TalismanScreenState createState() => _TalismanScreenState();
}

class _TalismanScreenState extends State<TalismanScreen> {
  bool _isLoading = true;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://masterelf.vip/talisman')); // Updated URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ybg.jpg'), // Path to your background image
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _webViewController),

            // Transparent Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.transparent, // Transparent background
                child: Center(
                  child: Lottie.asset(
                    'assets/jsons/loading_animation.json', // Replace with your Lottie file path
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}