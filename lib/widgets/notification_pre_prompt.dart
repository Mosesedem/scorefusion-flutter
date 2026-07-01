import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class NotificationPrePrompt extends StatefulWidget {
  const NotificationPrePrompt({
    super.key,
    required this.visible,
    required this.onAllow,
    required this.onSkip,
  });

  final bool visible;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  @override
  State<NotificationPrePrompt> createState() => _NotificationPrePromptState();
}

class _NotificationPrePromptState extends State<NotificationPrePrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
    );
    if (widget.visible) _controller.forward();
  }

  @override
  void didUpdateWidget(NotificationPrePrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward();
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    final dialogWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = dialogWidth * 0.9 > 400 ? 400.0 : dialogWidth * 0.9;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onSkip,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
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
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _NotificationHero(),
                      const SizedBox(height: 20),
                      const Text(
                        'Stay on top of every match',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202124),
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enable push alerts for live scores, final results, and breaking news — delivered the moment they happen.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5F6368),
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const _NotificationPreviewList(),
                      const SizedBox(height: 16),
                      const _BenefitChips(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: widget.onAllow,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color(AppConstants.orangeValue),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Enable notifications',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: widget.onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5F6368),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Not now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

class _NotificationHero extends StatelessWidget {
  const _NotificationHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(AppConstants.orangeValue).withValues(alpha: 0.18),
            const Color(AppConstants.orangeValue).withValues(alpha: 0.06),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 34,
            color: const Color(AppConstants.orangeValue).withValues(alpha: 0.85),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(AppConstants.orangeValue),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPreviewList extends StatelessWidget {
  const _NotificationPreviewList();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _PreviewNotificationCard(
              appName: 'Score Fusion',
              title: 'Goal! Man Utd 2–1 Liverpool',
              body: '78\' · Premier League · Live',
              time: 'now',
              accentColor: Color(AppConstants.orangeValue),
            ),
            SizedBox(height: 8),
            _PreviewNotificationCard(
              appName: 'Score Fusion',
              title: 'Full time: Arsenal 3–0 Chelsea',
              body: 'Match finished · See stats',
              time: '2m',
              accentColor: Color(0xFF34A853),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewNotificationCard extends StatelessWidget {
  const _PreviewNotificationCard({
    required this.appName,
    required this.title,
    required this.body,
    required this.time,
    required this.accentColor,
  });

  final String appName;
  final String title;
  final String body;
  final String time;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sports_soccer_rounded,
                size: 20,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202124),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F6368),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitChips extends StatelessWidget {
  const _BenefitChips();

  @override
  Widget build(BuildContext context) {
    const chips = ['Live scores', 'Final results', 'Breaking news'];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1967D2),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}