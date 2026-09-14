import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/server_provider.dart';
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

      final connected =
      await apiService.testConnection(ipAddress);

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
        ref
            .read(serverProvider.notifier)
            .setError(
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

      ref
          .read(serverProvider.notifier)
          .setError(
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

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Connection Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColors = isDark
        ? const [
      Color(0xFF0B1220),
      Color(0xFF172033),
      Color(0xFF0B1220),
    ]
        : const [
      Color(0xFFEAF4FF),
      Color(0xFFF7F9FC),
      Color(0xFFE8EEF7),
    ];

    final primaryText = isDark
        ? Colors.white
        : const Color(0xFF172554);

    final secondaryText = isDark
        ? Colors.white70
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                ),
                child: GlassCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                          colorScheme.primaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.18),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: 46,
                          color:
                          colorScheme.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Bank App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Connect to the bank server',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryText,
                        ),
                      ),

                      const SizedBox(height: 32),

                      TextField(
                        controller: ipController,
                        keyboardType:
                        TextInputType.number,
                        textInputAction:
                        TextInputAction.done,
                        onSubmitted: (_) {
                          if (!isConnecting) {
                            _connectToServer();
                          }
                        },
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor:
                        colorScheme.primary,
                        decoration: InputDecoration(
                          labelText: 'Server IP Address',
                          hintText:
                          'Example: 192.168.1.100',
                          labelStyle: TextStyle(
                            color: secondaryText,
                          ),
                          hintStyle: TextStyle(
                            color: secondaryText
                                .withValues(alpha: 0.7),
                          ),
                          floatingLabelStyle: TextStyle(
                            color:
                            colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.dns_outlined,
                            color:
                            colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white
                              .withValues(alpha: 0.06)
                              : Colors.white
                              .withValues(alpha: 0.55),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : const Color(
                                0xFFCBD5E1,
                              ),
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color:
                              colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton.icon(
                          onPressed: isConnecting
                              ? null
                              : _connectToServer,
                          icon: isConnecting
                              ? const SizedBox(
                            width: 21,
                            height: 21,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.link,
                          ),
                          label: Text(
                            isConnecting
                                ? 'Connecting...'
                                : 'Connect',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style:
                          FilledButton.styleFrom(
                            backgroundColor:
                            colorScheme.primary,
                            foregroundColor:
                            colorScheme.onPrimary,
                            disabledBackgroundColor:
                            colorScheme.primary
                                .withValues(
                              alpha: 0.5,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 20,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Server connection required',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryText,
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
        ),
      ),
    );
  }
}
