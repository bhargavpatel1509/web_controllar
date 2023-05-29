import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(WebBrowserApp());
}

class WebBrowserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Web Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebBrowserScreen(),
    );
  }
}

class WebBrowserScreen extends StatefulWidget {
  @override
  _WebBrowserScreenState createState() => _WebBrowserScreenState();
}

class _WebBrowserScreenState extends State<WebBrowserScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchUrl);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchUrl() {
    setState(() {});
  }

  Future<void> _loadUrl(String url) async {
    if (url.isNotEmpty && url.startsWith('http')) {
      _webViewController?.loadUrl(
          urlRequest:
              URLRequest(url: Uri(host: "https", scheme: "www.google.co.in")));
    }
  }

  Future<bool> _onWillPop() async {
    if (_webViewController != null) {
      if (await _webViewController!.canGoBack()) {
        _webViewController!.goBack();
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search or enter URL',
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              _loadUrl(value);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () {
                // Open bookmark manager
                // Implement your own logic here
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest:
                  URLRequest(url: Uri.parse('https://www.google.com')),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onLoadStart: (InAppWebViewController controller, Uri? url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (InAppWebViewController controller, Uri? url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                // Update progress bar
                // Implement your own progress bar logic here
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                if (navigationAction.request.url
                    .toString()
                    .startsWith('http')) {
                  // Allow loading of the URL
                  return NavigationActionPolicy.ALLOW;
                }
                // Block loading of other URLs
                return NavigationActionPolicy.CANCEL;
              },
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () async {
                  if (_webViewController != null) {
                    if (await _webViewController!.canGoBack()) {
                      _webViewController!.goBack();
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () async {
                  if (_webViewController != null) {
                    if (await _webViewController!.canGoForward()) {
                      _webViewController!.goForward();
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () async {
                  _webViewController?.reload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
