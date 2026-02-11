import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class DocsWebViewPage extends ConsumerStatefulWidget {
  const DocsWebViewPage({super.key});

  @override
  ConsumerState<DocsWebViewPage> createState() => _DocsWebViewPageState();
}

class _DocsWebViewPageState extends ConsumerState<DocsWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // 初始化 WebView Controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if(request.url.startsWith('https://linu.aprilzz.com')) {
              return NavigationDecision.navigate;
            }
            
            launchUrl(Uri.parse(request.url));
            return NavigationDecision.prevent;
          },
        ),
      );

    // 延迟加载以确保 Provider 数据就绪
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUrl();
    });
  }

  void _loadUrl() {
    final token = ref.read(settingsProvider).deviceToken ?? '';
    final locale = Localizations.localeOf(context).languageCode;
    // 确保 locale 是支持的语言 (en, zh)，否则默认为 en
    final supportedLocale = ['zh'].contains(locale) ? locale : 'en';
    final platform = Platform.isIOS ? 'ios' : 'android';
    
    final path = supportedLocale == 'en' ? 'inapp-docs' : '$supportedLocale/inapp-docs';
    final uri = Uri.parse('https://linu.aprilzz.com/$path').replace(
      queryParameters: {
        if (token.isNotEmpty) 'token': token,
        'platform': platform,
      },
    );

    _controller.loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.docs),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
