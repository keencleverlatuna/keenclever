import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/server_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'main_shell.dart';

class ServerConnectionScreen extends ConsumerStatefulWidget {
  const ServerConnectionScreen({super.key});

  @override
  ConsumerState<ServerConnectionScreen> createState() =>
      _ServerConnectionScreenState();
}

class _ServerConnectionScreenState
    extends ConsumerState<ServerConnectionScreen> {
  late final TextEditingController ipController;

  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController();
  }

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  Future<void> _connectToServer() async {
    final ipAddress = ipController.text.trim();

    if (ipAddress.isEmpty) {
      _showError('Please enter the server IP address.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isConnecting = true;
    });

    ref.read(serverProvider.notifier).setIpAddress(ipAddress);
    ref.read(serverProvider.notifier).setConnecting();

    try {
      final apiService = ApiService();

      final connected = await apiService.testConnection(ipAddress);

      if (!mounted) return;

      if (connected) {
        ref.read(serverProvider.notifier).setConnected();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainShell(),
          ),
        );
      } else {
        ref.read(serverProvider.notifier).setError(
          'Unable to connect to the bank server.',
        );

        _showError(
          'Unable to connect to the bank server.\n\n'
              'Please check the IP address and make sure '
              'the server is running.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ref.read(serverProvider.notifier).setError(
        'Unable to connect to the bank server.',
      );

      _showError(
        'Unable to connect to the bank server.\n\n'
            'Please make sure your server is running and '
            'your device is connected to the same network.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isConnecting = false;
        });
      }
    }
  }

  Future<void> _changeTheme(bool darkMode) async {
    await ref.read(themeProvider.notifier).setTheme(
      darkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.30),
      builder: (context) {
        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 26,
          ),
          child: _LiquidGlass(
            radius: 30,
            padding: const EdgeInsets.all(24),
            dark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GlassIcon(
                      icon: Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Connection Error',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF172554),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: _GlassActionButton(
                    icon: Icons.check_rounded,
                    text: 'OK',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    dark: isDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _LiquidGlassBackground(
            dark: isDark,
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 470,
                  ),
                  child: Column(
                    children: [
                      _LiquidGlass(
                        radius: 36,
                        padding: const EdgeInsets.fromLTRB(
                          28,
                          30,
                          28,
                          26,
                        ),
                        dark: isDark,
                        child: Column(
                          children: [
                            _GlassIcon(
                              icon:
                              Icons.account_balance_rounded,
                              color: isDark
                                  ? const Color(0xFF8CCBFF)
                                  : const Color(0xFF1976D2),
                              size: 88,
                              large: true,
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'Bank App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF172554),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Connect to the bank server',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white.withValues(
                                  alpha: 0.72,
                                )
                                    : const Color(0xFF526581),
                              ),
                            ),

                            const SizedBox(height: 28),

                            _GlassDivider(
                              dark: isDark,
                            ),

                            const SizedBox(height: 27),

                            Align(
                              alignment:
                              Alignment.centerLeft,
                              child: Text(
                                'SERVER ADDRESS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: isDark
                                      ? Colors.white.withValues(
                                    alpha: 0.68,
                                  )
                                      : const Color(0xFF526581),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            _GlassInput(
                              controller: ipController,
                              dark: isDark,
                              onSubmitted: (_) {
                                if (!isConnecting) {
                                  _connectToServer();
                                }
                              },
                            ),

                            const SizedBox(height: 18),

                            _GlassActionButton(
                              icon: isConnecting
                                  ? Icons.sync_rounded
                                  : Icons.link_rounded,
                              text: isConnecting
                                  ? 'Connecting...'
                                  : 'Connect to Server',
                              onTap: isConnecting
                                  ? null
                                  : _connectToServer,
                              dark: isDark,
                              fullWidth: true,
                              primary: true,
                            ),

                            const SizedBox(height: 23),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                    const Color(0xFF20E6A5),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        const Color(0xFF20E6A5)
                                            .withValues(
                                          alpha: 0.60,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Flexible(
                                  child: Text(
                                    'A server connection is required',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white.withValues(
                                        alpha: 0.65,
                                      )
                                          : const Color(
                                        0xFF526581,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _ThemeGlassSelector(
                        dark: isDark,
                        onChanged: _changeTheme,
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

class _LiquidGlassBackground extends StatelessWidget {
  final bool dark;

  const _LiquidGlassBackground({
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
            Color(0xFF020617),
            Color(0xFF081B3A),
            Color(0xFF172554),
            Color(0xFF0B1230),
            Color(0xFF020617),
          ]
              : const [
            Color(0xFF7CCBFF),
            Color(0xFFE8F6FF),
            Color(0xFFA7A0FF),
            Color(0xFFB8E0FF),
            Color(0xFF6EB8FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -170,
            right: -100,
            child: _BackgroundOrb(
              size: 390,
              color: dark
                  ? const Color(0xFF168BFF)
                  : const Color(0xFF38AFFF),
              opacity: dark ? 0.42 : 0.58,
            ),
          ),
          Positioned(
            top: 150,
            left: -170,
            child: _BackgroundOrb(
              size: 370,
              color: dark
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF8175FF),
              opacity: dark ? 0.36 : 0.48,
            ),
          ),
          Positioned(
            bottom: -190,
            right: -90,
            child: _BackgroundOrb(
              size: 420,
              color: dark
                  ? const Color(0xFF06B6D4)
                  : const Color(0xFF5E9CFF),
              opacity: dark ? 0.34 : 0.48,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -120,
            child: _BackgroundOrb(
              size: 300,
              color: dark
                  ? const Color(0xFFA855F7)
                  : const Color(0xFFB69CFF),
              opacity: dark ? 0.28 : 0.38,
            ),
          ),
          Positioned(
            top: 360,
            right: -80,
            child: _BackgroundOrb(
              size: 240,
              color: dark
                  ? const Color(0xFF22D3EE)
                  : const Color(0xFF60C7FF),
              opacity: dark ? 0.25 : 0.36,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _BackgroundOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 45,
        sigmaY: 45,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(
            alpha: opacity,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: opacity * 0.85,
              ),
              blurRadius: 110,
              spreadRadius: 45,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool dark;

  const _LiquidGlass({
    required this.child,
    required this.padding,
    required this.radius,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 24,
          sigmaY: 24,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.055),
                Colors.white.withValues(alpha: 0.085),
              ]
                  : [
                Colors.white.withValues(alpha: 0.23),
                Colors.white.withValues(alpha: 0.105),
                Colors.white.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: dark ? 0.34 : 0.58,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.22 : 0.10,
                ),
                blurRadius: 35,
                spreadRadius: -8,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: dark ? 0.10 : 0.24,
                ),
                blurRadius: 22,
                spreadRadius: -5,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(
                          alpha: dark ? 0.48 : 0.90,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final bool dark;
  final ValueChanged<String>? onSubmitted;

  const _GlassInput({
    required this.controller,
    required this.dark,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.045),
              ]
                  : [
                Colors.white.withValues(alpha: 0.27),
                Colors.white.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: dark ? 0.30 : 0.58,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.14 : 0.07,
                ),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: dark ? 0.08 : 0.24,
                ),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmitted,
            style: TextStyle(
              color: dark
                  ? Colors.white
                  : const Color(0xFF172554),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: primary,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.language_rounded,
                color: primary,
                size: 25,
              ),
              hintText: 'Example: 192.168.1.100',
              hintStyle: TextStyle(
                color: dark
                    ? Colors.white.withValues(alpha: 0.55)
                    : const Color(0xFF526581)
                    .withValues(alpha: 0.75),
                fontSize: 15,
              ),
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool dark;
  final bool fullWidth;
  final bool primary;

  const _GlassActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.dark,
    this.fullWidth = false,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).colorScheme.primary;

    final button = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: primary
                  ? [
                accent.withValues(
                  alpha: dark ? 0.52 : 0.55,
                ),
                accent.withValues(
                  alpha: dark ? 0.20 : 0.25,
                ),
              ]
                  : [
                Colors.white.withValues(
                  alpha: dark ? 0.12 : 0.25,
                ),
                Colors.white.withValues(
                  alpha: dark ? 0.05 : 0.12,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: primary
                    ? (dark ? 0.40 : 0.65)
                    : (dark ? 0.30 : 0.55),
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primary
                    ? accent.withValues(
                  alpha: dark ? 0.20 : 0.18,
                )
                    : Colors.black.withValues(
                  alpha: dark ? 0.12 : 0.06,
                ),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: dark ? 0.10 : 0.22,
                ),
                blurRadius: 14,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: dark
                    ? Colors.white
                    : primary
                    ? Colors.white
                    : const Color(0xFF172554),
                size: 23,
              ),
              const SizedBox(width: 11),
              Text(
                text,
                style: TextStyle(
                  color: dark
                      ? Colors.white
                      : primary
                      ? Colors.white
                      : const Color(0xFF172554),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: onTap,
          child: button,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: button,
    );
  }
}

class _GlassIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool large;

  const _GlassIcon({
    required this.icon,
    required this.color,
    required this.size,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.26),
                Colors.white.withValues(alpha: 0.07),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.52,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: large ? 0.28 : 0.12,
                ),
                blurRadius: large ? 35 : 20,
                spreadRadius: large ? 2 : 0,
              ),
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: 0.16,
                ),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: large ? 45 : 25,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  final bool dark;

  const _GlassDivider({
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(
              alpha: dark ? 0.30 : 0.70,
            ),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _ThemeGlassSelector extends StatelessWidget {
  final bool dark;
  final ValueChanged<bool> onChanged;

  const _ThemeGlassSelector({
    required this.dark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    final textColor = dark
        ? Colors.white
        : const Color(0xFF172554);

    final secondaryColor = dark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF526581);

    return _LiquidGlass(
      radius: 30,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      dark: dark,
      child: Row(
        children: [
          _GlassIcon(
            icon: dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            color: primary,
            size: 50,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  dark ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dark
                      ? 'Dark glass appearance'
                      : 'Light glass appearance',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: dark,
            onChanged: onChanged,
            activeColor: primary,
          ),
        ],
      ),
    );
  }
}