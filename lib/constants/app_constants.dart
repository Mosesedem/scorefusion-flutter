class AppConstants {
  static const String webUrl = 'https://www.getscorefusion.com/dashboard';
  static const String appName = 'Score Fusion';

  static const String orange = '#ff9100';
  static const int orangeValue = 0xFFFF9100;

  static const String screenBg = '#ffffff';
  static const String textPrimary = '#1a1a1a';
  static const String textSecondary = '#666666';
  static const String textMuted = '#888888';

  static const String fcmTokenKey = 'expoPushToken';
  static const String socialPopupDismissKey = '@social_popup_dismiss';
  static const String notificationPrePromptKey = '@notification_pre_prompt_handled';

  static const Duration oneDay = Duration(days: 1);
  static const Duration threeDays = Duration(days: 3);

  static const Set<String> blockedUrls = {
    'https://www.getscorefusion.com/',
    'https://getscorefusion.com/',
    'https://app.getscorefusion.com/',
  };

  static const Map<String, String> socialLinks = {
    'telegram': 'https://t.me/Donaldauthorr',
    'channel': 'https://t.me/+QysfcefOapnhAbKA',
    'email':
        'mailto:Scorefusionn@gmail.com?subject=VIP%20Subscription%20Payment&body=Hi,%0D%0A%0D%0AI%20want%20to%20subscribe%20to%20the%20',
    'whatsapp':
        'https://api.whatsapp.com/send?phone=84867084414&text=Hi%20Score%20Fusion%21%20I%20would%20like%20to%20get%20premium%20VIP%20tips.',
  };

  static String userAgentForPlatform({required bool isIOS}) {
    if (isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 ScoreFusionApp/1.0';
    }
    return 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36 ScoreFusionApp/1.0';
  }
}