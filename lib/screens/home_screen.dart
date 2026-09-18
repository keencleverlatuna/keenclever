import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _GlassBackground(),
          ),

          accountsState.when(
            loading: () {
              return const Center(
                child: _GlassLoading(),
              );
            },
            error: (error, stackTrace) {
              return _GlassError(
                error: error.toString(),
                onRetry: () {
                  ref
                      .read(accountsProvider.notifier)
                      .refreshAccounts();
                },
              );
            },
            data: (accounts) {
              if (accounts.isEmpty) {
                return SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () {
                      return ref
                          .read(accountsProvider.notifier)
                          .refreshAccounts();
                    },
                    child: ListView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        24,
                        16,
                        140,
                      ),
                      children: [
                        const SizedBox(height: 70),
                        const _GlassEmptyState(),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () {
                  return ref
                      .read(accountsProvider.notifier)
                      .refreshAccounts();
                },
                child: ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),

                  // Increased top spacing so the first
                  // account card does not touch the header.
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    115,
                    16,
                    150,
                  ),

                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 18,
                      ),
                      child: _AccountCard(
                        account: account,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const Positioned(
            top: -4,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  2,
                  16,
                  8,
                ),
                child: _GlassHeader(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackground extends StatelessWidget {
  const _GlassBackground();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
            Color(0xFF080B25),
            Color(0xFF111B4A),
            Color(0xFF20145A),
            Color(0xFF071A42),
          ]
              : const [
            Color(0xFF21C7F3),
            Color(0xFF168FE8),
            Color(0xFF566CF2),
            Color(0xFF9C7CF7),
          ],
        ),
      ),
      child: Stack(
        children: [
          _GlowOrb(
            alignment: const Alignment(-1.15, -0.75),
            size: 270,
            color: isDark
                ? const Color(0xFF3159FF)
                : const Color(0xFF8FE9FF),
          ),
          _GlowOrb(
            alignment: const Alignment(1.15, -0.25),
            size: 300,
            color: isDark
                ? const Color(0xFF8A45FF)
                : const Color(0xFF5D8CFF),
          ),
          _GlowOrb(
            alignment: const Alignment(-0.9, 0.45),
            size: 280,
            color: isDark
                ? const Color(0xFF234DFF)
                : const Color(0xFF7B6DFF),
          ),
          _GlowOrb(
            alignment: const Alignment(0.9, 0.85),
            size: 330,
            color: isDark
                ? const Color(0xFF7438C8)
                : const Color(0xFFB78CFF),
          ),
          _GlowOrb(
            alignment: const Alignment(0.0, 0.05),
            size: 240,
            color: isDark
                ? const Color(0xFF126FAF)
                : const Color(0xFF28D6EE),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;

  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 55,
          sigmaY: 55,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.60),
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30,
          sigmaY: 30,
        ),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            color: Colors.white.withValues(alpha: 0.16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 25,
                offset: const Offset(0, 12),
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
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  const _HeaderIcon(
                    icon: Icons.account_balance_rounded,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank Accounts',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Your accounts',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _HeaderIcon(
                    icon: Icons.person_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.13),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.38),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 23,
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final dynamic account;

  const _AccountCard({
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 22,
          sigmaY: 22,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            24,
            22,
            24,
            25,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.42),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 18,
                right: 18,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _GlassInfoRow(
                    icon: Icons.person_outline_rounded,
                    text:
                    '${account.firstName} ${account.lastName}',
                  ),
                  const SizedBox(height: 15),
                  _GlassInfoRow(
                    icon: Icons.credit_card_outlined,
                    text: account.accountNumber,
                  ),
                  const SizedBox(height: 15),
                  _GlassInfoRow(
                    icon: Icons.email_outlined,
                    text: account.email,
                  ),
                  const SizedBox(height: 15),
                  _GlassInfoRow(
                    icon: Icons.phone_outlined,
                    text: account.phone,
                  ),
                  const SizedBox(height: 21),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withValues(
                      alpha: 0.25,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'CURRENT BALANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '₱${account.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.white.withValues(alpha: 0.78),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassLoading extends StatelessWidget {
  const _GlassLoading();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 22,
          sigmaY: 22,
        ),
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _GlassError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load accounts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(18),
                        color:
                        Colors.white.withValues(alpha: 0.16),
                        border: Border.all(
                          color:
                          Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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

class _GlassEmptyState extends StatelessWidget {
  const _GlassEmptyState();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 22,
          sigmaY: 22,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 50,
                color: Colors.white70,
              ),
              SizedBox(height: 15),
              Text(
                'No bank accounts found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}