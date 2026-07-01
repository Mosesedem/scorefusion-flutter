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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

    final width = MediaQuery.sizeOf(context).width;

    return FadeTransition(
      opacity: _controller,
      child: Material(
        color: const Color(0x99000000),
        child: Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: Container(
              width: width * 0.85 > 400 ? 400 : width * 0.85,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Connect With Us',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Follow and connect with us for updates, tips, and exclusive content!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SocialButton(
                        label: 'Whatsapp',
                        color: const Color(0xFF25D366),
                        icon: Icons.chat_bubble_outline,
                        onTap: () => _openLink(AppConstants.socialLinks['whatsapp']!),
                      ),
                      _SocialButton(
                        label: 'Telegram',
                        color: const Color(0xFF0088CC),
                        icon: Icons.send_outlined,
                        onTap: () => _openLink(AppConstants.socialLinks['telegram']!),
                      ),
                      _SocialButton(
                        label: 'Telegram Channel',
                        color: const Color(0xFF0088CC),
                        icon: Icons.groups_outlined,
                        onTap: () => _openLink(AppConstants.socialLinks['channel']!),
                      ),
                      _SocialButton(
                        label: 'Email',
                        color: Colors.black,
                        icon: Icons.mail_outline,
                        onTap: () => _openLink(AppConstants.socialLinks['email']!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _handleDismiss(AppConstants.oneDay),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Remind me later',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _handleDismiss(AppConstants.threeDays),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE8E8E8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Don't show for now",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemWidth = (MediaQuery.sizeOf(context).width * 0.85 > 400
            ? 400
            : MediaQuery.sizeOf(context).width * 0.85) *
        0.45;

    return SizedBox(
      width: itemWidth,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}