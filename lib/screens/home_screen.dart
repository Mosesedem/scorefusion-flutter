import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';
import '../utils/url_utils.dart';
import '../widgets/error_screen.dart';
import '../widgets/notification_denied_banner.dart';
import '../widgets/notification_pre_prompt.dart';
import '../widgets/preloader.dart';
import '../widgets/social_follow_modal.dart';
import '../widgets/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    ConnectivityService? connectivityService,
    NotificationService? notificationService,
  })  : _connectivityService = connectivityService,
        _notificationService = notificationService;

  final ConnectivityService? _connectivityService;
  final NotificationService? _notificationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final ConnectivityService _connectivity =
      widget._connectivityService ?? ConnectivityService();
  late final NotificationService _notifications =
      widget._notificationService ?? NotificationService();

  InAppWebViewController? _webViewController;
  StreamSubscription<bool>? _connectivitySub;

  bool _isConnected = true;
  bool _isLoading = true;
  bool _showSplash = true;
  bool _webViewError = false;
  bool _webViewLoading = false;
  int _webViewKey = 0;
  bool _canGoBack = false;

  String? _fcmToken;
  bool _showPrePrompt = false;
  bool _notificationDenied = false;

  PullToRefreshController? _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: const Color(AppConstants.orangeValue)),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await _webViewController?.reload();
        }
      },
    );
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notifications.clearBadge();
      _refreshPermissionStatus();
    }
  }

  Future<void> _initialize() async {
    try {
      await _notifications.initialize();

      final connected = await _connectivity.hasConnection();
      _isConnected = connected;

      final savedToken = await _notifications.restoreSavedToken();
      if (savedToken != null) _fcmToken = savedToken;

      final status = await _notifications.permissionStatus();
      if (status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional) {
        final token = await _notifications.getFcmToken();
        if (token != null) {
          _fcmToken = token;
          _notificationDenied = false;
        }
      } else if (status == AuthorizationStatus.denied) {
        _notificationDenied = true;
      } else {
        Future<void>.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) setState(() => _showPrePrompt = true);
        });
      }

      _notifications.onTokenRefresh((token) {
        if (!mounted) return;
        setState(() => _fcmToken = token);
        _sendTokenToWebView(token, 'granted');
      });

      _notifications.onMessageOpenedApp(_handleNotificationNavigation);
      final initialMessage = await _notifications.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationNavigation(initialMessage);
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Init error: $e');
    } finally {
      if (mounted) {
        Future<void>.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() {
            _showSplash = false;
            _isLoading = false;
          });
          _startConnectivityListener();
        });
      }
    }
  }

  void _startConnectivityListener() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged().listen((connected) {
      if (!mounted) return;
      setState(() => _isConnected = connected);
    });
  }

  Future<void> _refreshPermissionStatus() async {
    final status = await _notifications.permissionStatus();
    if (!mounted) return;

    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      if (_fcmToken == null) {
        final token = await _notifications.getFcmToken();
        if (token != null && mounted) {
          setState(() {
            _fcmToken = token;
            _notificationDenied = false;
          });
          _sendTokenToWebView(token, 'granted');
        }
      }
    } else if (status == AuthorizationStatus.denied) {
      setState(() => _notificationDenied = true);
    }
  }

  Future<void> _requestSystemPermission() async {
    final status = await _notifications.requestPermission();
    if (!mounted) return;

    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      final token = await _notifications.getFcmToken();
      setState(() {
        _fcmToken = token;
        _notificationDenied = false;
      });
      if (token != null) _sendTokenToWebView(token, 'granted');
    } else {
      setState(() => _notificationDenied = true);
    }
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final url = message.data['url'];
    if (url is String && url.isNotEmpty) {
      _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    }
  }

  Future<void> _sendTokenToWebView(String token, String status) async {
    if (_webViewController == null || token.isEmpty) return;

    final escapedToken = token.replaceAll("'", r"\'");
    await _webViewController?.evaluateJavascript(source: '''
      (function() {
        window.__fcmToken = '$escapedToken';
        window.__notificationStatus = '$status';
        window.dispatchEvent(new CustomEvent('fcmToken', {
          detail: { token: '$escapedToken', status: '$status' }
        }));
      })();
    ''');
  }

  Future<void> _handleRetry() async {
    setState(() {
      _webViewError = false;
      _isLoading = true;
    });

    final connected = await _connectivity.hasConnection();
    if (!mounted) return;

    setState(() {
      _isConnected = connected;
      _isLoading = false;
    });

    if (connected) {
      await _webViewController?.reload();
    }
  }

  void _handleLoginRedirect() {
    setState(() {
      _webViewKey++;
      _webViewLoading = true;
      _webViewError = false;
    });
  }

  Future<NavigationActionPolicy?> _handleNavigation(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url?.toString();

    if (isUtilityUrl(url)) {
      return NavigationActionPolicy.ALLOW;
    }

    if (shouldBlockUrl(url)) {
      _handleLoginRedirect();
      return NavigationActionPolicy.CANCEL;
    }

    if (isExternalDomain(url) && url != null && url.startsWith('http')) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<bool> _onWillPop() async {
    if (_canGoBack) {
      await _webViewController?.goBack();
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Score Fusion?'),
        content: const Text('Are you sure you want to leave the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
      return false;
    }
    return false;
  }

  void _openNotificationSettings() {
    if (Platform.isIOS) {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    } else {
      AppSettings.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    if (!_isConnected) {
      return ErrorScreen(
        message:
            'No internet connection. Please check your network settings and try again.',
        onRetry: _handleRetry,
        showSettings: true,
      );
    }

    if (_webViewError) {
      return ErrorScreen(
        message:
            'Unable to load Score Fusion. Please check your connection and try again.',
        onRetry: _handleRetry,
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(AppConstants.orangeValue),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Initializing your experience…',
                  style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isIOS = Platform.isIOS;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.paddingOf(context).top,
                child: const ColoredBox(color: Colors.white),
              ),
              SafeArea(
                child: Column(
                  children: [
                    if (_notificationDenied)
                      NotificationDeniedBanner(
                        onOpenSettings: _openNotificationSettings,
                        onDismiss: () =>
                            setState(() => _notificationDenied = false),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          InAppWebView(
                            key: ValueKey<int>(_webViewKey),
                            initialUrlRequest: URLRequest(
                              url: WebUri(AppConstants.webUrl),
                            ),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              domStorageEnabled: true,
                              databaseEnabled: true,
                              cacheEnabled: true,
                              allowsInlineMediaPlayback: true,
                              mediaPlaybackRequiresUserGesture: false,
                              useHybridComposition: true,
                              userAgent:
                                  AppConstants.userAgentForPlatform(isIOS: isIOS),
                              transparentBackground: true,
                              supportZoom: false,
                              verticalScrollBarEnabled: true,
                              horizontalScrollBarEnabled: false,
                              allowsBackForwardNavigationGestures: isIOS,
                            ),
                            pullToRefreshController: Platform.isAndroid
                                ? _pullToRefreshController
                                : null,
                            onWebViewCreated: (controller) {
                              _webViewController = controller;
                            },
                            onLoadStart: (controller, url) {
                              if (!mounted) return;
                              setState(() {
                                _webViewLoading = true;
                                _webViewError = false;
                              });
                            },
                            onLoadStop: (controller, _) async {
                              if (!mounted) return;
                              setState(() => _webViewLoading = false);
                              _pullToRefreshController?.endRefreshing();

                              if (_fcmToken != null) {
                                final status =
                                    await _notifications.permissionStatus();
                                final statusLabel =
                                    status == AuthorizationStatus.authorized ||
                                            status ==
                                                AuthorizationStatus.provisional
                                        ? 'granted'
                                        : status.name;
                                await _sendTokenToWebView(_fcmToken!, statusLabel);
                              }
                            },
                            onReceivedError: (controller, request, error) {
                              if (!mounted) return;
                              setState(() {
                                _webViewError = true;
                                _webViewLoading = false;
                              });
                            },
                            onUpdateVisitedHistory:
                                (controller, url, isReload) async {
                              final canGoBack = await controller.canGoBack();
                              if (mounted) {
                                setState(() => _canGoBack = canGoBack);
                              }
                              if (shouldBlockUrl(url?.toString())) {
                                _handleLoginRedirect();
                              }
                            },
                            shouldOverrideUrlLoading: _handleNavigation,
                            onProgressChanged: (controller, progress) {
                              if (progress == 100) {
                                _pullToRefreshController?.endRefreshing();
                              }
                            },
                          ),
                          if (_webViewLoading)
                            Preloader(
                              onAutoHide: () {
                                if (mounted) {
                                  setState(() => _webViewLoading = false);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SocialFollowModal(),
              NotificationPrePrompt(
                visible: _showPrePrompt,
                onAllow: () {
                  setState(() => _showPrePrompt = false);
                  Future<void>.delayed(
                    const Duration(milliseconds: 400),
                    _requestSystemPermission,
                  );
                },
                onSkip: () => setState(() => _showPrePrompt = false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}