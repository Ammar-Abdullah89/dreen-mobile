import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../splash/splash_screen.dart';

class OdooWebScreen extends StatefulWidget {
  final String url;

  const OdooWebScreen({super.key, required this.url});
  @override
  State<OdooWebScreen> createState() => _OdooWebScreenState();
}

class _OdooWebScreenState extends State<OdooWebScreen> {
  late WebViewController _controller;
  bool _loading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
        onWebResourceError: (error) {
          debugPrint('WebView error: ${error.description} (code: ${error.errorCode})');
        },
      ));

    if (_controller.platform is AndroidWebViewController) {
      final android = _controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(true);
      await android.setOnPlatformPermissionRequest((request) {
        request.grant();
      });
    }

    await _controller.loadRequest(Uri.parse(widget.url));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ServerInputScreen()),
        (_) => false,
      );
    }
  }

  void _reload() => _controller.reload();
  Future<void> _goBack() async {
    if (await _controller.canGoBack()) _controller.goBack();
  }
  Future<void> _goForward() async {
    if (await _controller.canGoForward()) _controller.goForward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navBtn(Icons.arrow_back_ios, _goBack),
              _navBtn(Icons.arrow_forward_ios, _goForward),
              _navBtn(Icons.refresh, _reload),
              _navBtn(Icons.home_outlined, () => _controller.loadRequest(Uri.parse(widget.url))),
              _navBtn(Icons.logout, _logout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 56,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[700],
          shape: const RoundedRectangleBorder(),
          minimumSize: const Size(48, 56),
        ),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
