import 'package:flutter/material.dart';
import 'package:abutil/abutil.dart';
import 'package:xue_hua_webview/xue_hua_webview.dart';

enum ExampleDemo { fileChooser, bilibili }

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xue_hua_webview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择测试')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _DemoTile(
            icon: Icons.folder_open,
            title: '本地 HTML（文件选择）',
            subtitle: '加载 assets/file_chooser.html，手测各平台选文件、相册和拍照',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const ExampleWebViewPage(demo: ExampleDemo.fileChooser),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DemoTile(
            icon: Icons.public,
            title: '哔哩哔哩',
            subtitle: '打开 bilibili.com，手测 H5 打开 App 等在线行为',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const ExampleWebViewPage(demo: ExampleDemo.bilibili),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ExampleWebViewPage extends StatefulWidget {
  const ExampleWebViewPage({super.key, required this.demo});

  final ExampleDemo demo;

  @override
  State<ExampleWebViewPage> createState() => _ExampleWebViewPageState();
}

class _ExampleWebViewPageState extends State<ExampleWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _configureAndLoad();
  }

  String get _title {
    return switch (widget.demo) {
      ExampleDemo.fileChooser => '文件选择',
      ExampleDemo.bilibili => '哔哩哔哩',
    };
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

    switch (widget.demo) {
      case ExampleDemo.fileChooser:
        await _controller.loadFlutterAsset('assets/file_chooser.html');
      case ExampleDemo.bilibili:
        await _controller.loadRequest(Uri.parse('https://www.bilibili.com'));
    }
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
        title: Text(_title),
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
