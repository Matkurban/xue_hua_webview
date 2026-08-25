import 'package:flutter/material.dart';
import 'package:abutil/abutil.dart';
import 'package:xue_hua_webview/xue_hua_webview.dart';

void main() {
  runApp(const BilibiliApp());
}

class BilibiliApp extends StatelessWidget {
  const BilibiliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilibili',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      home: const BilibiliPage(),
    );
  }
}

class BilibiliPage extends StatefulWidget {
  const BilibiliPage({super.key});

  @override
  State<BilibiliPage> createState() => _BilibiliPageState();
}

class _BilibiliPageState extends State<BilibiliPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _configureAndLoad();
  }

  Future<void> _configureAndLoad() async {
    if (!isWeb()) {
      await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            debugPrint('Loading $url');
          },
          onPageFinished: (String url) {
            debugPrint('Finished $url');
            if (mounted) {
              setState(() {
                _progress = 100;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'WebView error ${error.errorCode}: '
              '${error.description} (${error.url})',
            );
          },
        ),
      );
    }

    await _controller.loadRequest(Uri.parse('https://www.bilibili.com'));
  }

  Future<void> _onDemoSelected(String value) async {
    switch (value) {
      case 'async':
        final JavaScriptAsyncResult result = await _controller
            .runJavaScriptAsync(
              'return await Promise.resolve(document.title);',
            );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.hasError
                  ? 'Async JS error: ${result.error}'
                  : 'Title: ${result.value}',
            ),
          ),
        );
      case 'script':
        await _controller.addUserScript(
          const UserScript(
            source: 'console.log("xue_hua_webview user script");',
          ),
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User script will run on the next navigation.'),
          ),
        );
      case 'storage':
        await WebViewStorageManager().removeData();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Website data cleared.')));
      case 'headless':
        final HeadlessWebView headless = HeadlessWebView();
        await headless.controller.setJavaScriptMode(
          JavaScriptMode.unrestricted,
        );
        await headless.run();
        await headless.controller.loadHtmlString(
          '<html><body>headless</body></html>',
        );
        await headless.dispose();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Headless WebView ran and disposed.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilibili'),
        actions: isWeb()
            ? const <Widget>[]
            : <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      await _controller.goForward();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _controller.reload();
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: _onDemoSelected,
                  itemBuilder: (BuildContext context) =>
                      const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'async',
                          child: Text('Await Promise'),
                        ),
                        PopupMenuItem<String>(
                          value: 'script',
                          child: Text('Add user script'),
                        ),
                        PopupMenuItem<String>(
                          value: 'storage',
                          child: Text('Clear website data'),
                        ),
                        PopupMenuItem<String>(
                          value: 'headless',
                          child: Text('Run headless WebView'),
                        ),
                      ],
                ),
              ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: !isWeb() && _progress < 100
              ? LinearProgressIndicator(value: _progress / 100)
              : const SizedBox(height: 3),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
