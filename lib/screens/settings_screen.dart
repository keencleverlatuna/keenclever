import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import 'add_account_screen.dart';
import 'manage_accounts_screen.dart';
import 'withdraw_screen.dart';
import 'deposit_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: _SettingsBackground(),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SettingsTitle(),

                  const SizedBox(height: 32),

                  const _SectionTitle(
                    title: 'Appearance',
                  ),

                  const SizedBox(height: 12),

                  _ThemeCard(
                    isDark: isDark,
                    onChanged: (value) async {
                      await ref
                          .read(themeProvider.notifier)
                          .setTheme(
                        value
                            ? ThemeMode.dark
                            : ThemeMode.light,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  const _SectionTitle(
                    title: 'Account Management',
                  ),

                  const SizedBox(height: 12),

                  _AccountManagementCard(
                    onAddAccount: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const AddAccountScreen(),
                        ),
                      );
                    },
                    onManageAccounts: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ManageAccountsScreen(),
                        ),
                      );
                    },
                    onWithdraw: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const WithdrawScreen(),
                        ),
                      );
                    },
                    onDeposit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const DepositScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

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
            alignment: const Alignment(-1.15, -0.85),
            size: 270,
            color: isDark
                ? const Color(0xFF3159FF)
                : const Color(0xFF8FE9FF),
          ),
          _GlowOrb(
            alignment: const Alignment(1.10, -0.35),
            size: 300,
            color: isDark
                ? const Color(0xFF8A45FF)
                : const Color(0xFF5D8CFF),
          ),
          _GlowOrb(
            alignment: const Alignment(-0.95, 0.40),
            size: 290,
            color: isDark
                ? const Color(0xFF234DFF)
                : const Color(0xFF7B6DFF),
          ),
          _GlowOrb(
            alignment: const Alignment(0.95, 0.85),
            size: 330,
            color: isDark
                ? const Color(0xFF7438C8)
                : const Color(0xFFB78CFF),
          ),
          _GlowOrb(
            alignment: const Alignment(0.0, 0.05),
            size: 230,
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

class _SettingsTitle extends StatelessWidget {
  const _SettingsTitle();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Settings',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.90),
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeCard({
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 25,
          sigmaY: 25,
        ),
        child: Container(
          height: 108,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
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
                        Colors.white.withValues(alpha: 0.60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _GlassCircleIcon(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.wb_sunny_rounded,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDark
                              ? 'Dark mode'
                              : 'Light mode',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _GlassSwitch(
                    value: isDark,
                    onChanged: onChanged,
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

class _AccountManagementCard extends StatelessWidget {
  final VoidCallback onAddAccount;
  final VoidCallback onManageAccounts;
  final VoidCallback onWithdraw;
  final VoidCallback onDeposit;

  const _AccountManagementCard({
    required this.onAddAccount,
    required this.onManageAccounts,
    required this.onWithdraw,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 25,
          sigmaY: 25,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 22,
                right: 22,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  _SettingsRow(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Add Account',
                    subtitle: 'Create a new bank account',
                    onTap: onAddAccount,
                  ),
                  const _SettingsDivider(),
                  _SettingsRow(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Manage Accounts',
                    subtitle: 'Edit or delete existing accounts',
                    onTap: onManageAccounts,
                  ),
                  const _SettingsDivider(),
                  _SettingsRow(
                    icon: Icons.payments_outlined,
                    title: 'Withdraw Money',
                    subtitle:
                    'Select an account and withdraw money',
                    onTap: onWithdraw,
                  ),
                  const _SettingsDivider(),
                  _SettingsRow(
                    icon:
                    Icons.account_balance_wallet_outlined,
                    title: 'Deposit Money',
                    subtitle:
                    'Select an account and deposit money',
                    onTap: onDeposit,
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

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            18,
            18,
          ),
          child: Row(
            children: [
              _GlassRowIcon(
                icon: icon,
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.20),
      ),
    );
  }
}

class _GlassCircleIcon extends StatelessWidget {
  final IconData icon;

  const _GlassCircleIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.13),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.32),
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _GlassRowIcon extends StatelessWidget {
  final IconData icon;

  const _GlassRowIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withValues(alpha: 0.16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}

class _GlassSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GlassSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 60,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? Colors.black.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.90),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}