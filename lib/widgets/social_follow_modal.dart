import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class SocialFollowModal extends StatefulWidget {
  const SocialFollowModal({super.key, StorageService? storage})
      : _storage = storage;

  final StorageService? _storage;

  @override
  State<SocialFollowModal> createState() => _SocialFollowModalState();
}

class _SocialFollowModalState extends State<SocialFollowModal>
    with SingleTickerProviderStateMixin {
  late final StorageService _storage = widget._storage ?? StorageService();
  late final AnimationController _controller;
  bool _visible = false;

  static const _channels = [
    _ContactChannel(
      label: 'WhatsApp',
      subtitle: 'Chat with us',
      color: Color(0xFF25D366),
      icon: Icons.chat_rounded,
      linkKey: 'whatsapp',
    ),
    _ContactChannel(
      label: 'Telegram',
      subtitle: 'Direct message',
      color: Color(0xFF0088CC),
      icon: Icons.send_rounded,
      linkKey: 'telegram',
    ),
    _ContactChannel(
      label: 'Channel',
      subtitle: 'Join updates',
      color: Color(0xFF229ED9),
      icon: Icons.campaign_rounded,
      linkKey: 'channel',
    ),
    _ContactChannel(
      label: 'Email',
      subtitle: 'Send a message',
      color: Color(0xFFEA4335),
      icon: Icons.mail_rounded,
      linkKey: 'email',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _checkShouldShow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkShouldShow() async {
    final dismissUntil =
        await _storage.getDismissUntil(AppConstants.socialPopupDismissKey);
    if (!mounted) return;

    if (dismissUntil == null || DateTime.now().isAfter(dismissUntil)) {
      setState(() => _visible = true);
      _controller.forward();
    }
  }

  Future<void> _handleDismiss(Duration duration) async {
    final dismissUntil = DateTime.now().add(duration);
    await _storage.saveDismissUntil(
      AppConstants.socialPopupDismissKey,
      dismissUntil,
    );
    await _controller.reverse();
    if (mounted) setState(() => _visible = false);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final dialogWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = dialogWidth * 0.9 > 420 ? 420.0 : dialogWidth * 0.9;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          SafeArea(
            child: Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Container(
                  width: maxWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.orangeValue)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          size: 28,
                          color: Color(AppConstants.orangeValue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Reach out on your preferred channel for support, updates, and VIP subscriptions.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5F6368),
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                        itemCount: _channels.length,
                        itemBuilder: (context, index) {
                          final channel = _channels[index];
                          return _ContactGridTile(
                            channel: channel,
                            onTap: () => _openLink(
                              AppConstants.socialLinks[channel.linkKey]!,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _handleDismiss(AppConstants.oneDay),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF3C4043),
                                side: const BorderSide(color: Color(0xFFDADCE0)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Later',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () =>
                                  _handleDismiss(AppConstants.threeDays),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF5F6368),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Dismiss',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _ContactChannel {
  const _ContactChannel({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.linkKey,
  });

  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String linkKey;
}

class _ContactGridTile extends StatelessWidget {
  const _ContactGridTile({
    required this.channel,
    required this.onTap,
  });

  final _ContactChannel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: channel.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(channel.icon, size: 22, color: channel.color),
              ),
              const Spacer(),
              Text(
                channel.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                channel.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5F6368),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}