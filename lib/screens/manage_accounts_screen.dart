import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';
import 'edit_account_screen.dart';

class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountsProvider);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _GlassBackground(
            isDark: isDark,
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _GlassHeader(
                  onBack: () {
                    Navigator.pop(context);
                  },
                ),

                Expanded(
                  child: accountsState.when(
                    loading: () => const _GlassLoading(),

                    error: (error, stackTrace) => _GlassError(
                      message: error.toString(),
                      onRetry: () {
                        ref
                            .read(accountsProvider.notifier)
                            .refreshAccounts();
                      },
                    ),

                    data: (accounts) {
                      if (accounts.isEmpty) {
                        return const _GlassEmptyState();
                      }

                      return RefreshIndicator(
                        color: Colors.white,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.18),
                        onRefresh: () {
                          return ref
                              .read(accountsProvider.notifier)
                              .refreshAccounts();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            14,
                            16,
                            130,
                          ),
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final account = accounts[index];

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 16,
                              ),
                              child: _ManagementCard(
                                account: account,
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditAccountScreen(
                                            account: account,
                                          ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  _deleteAccount(
                                    context,
                                    ref,
                                    account,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(
      BuildContext context,
      WidgetRef ref,
      Account account,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _GlassDialog(
          title: 'Delete Account?',
          message:
          'Delete ${account.firstName} ${account.lastName}?',
          onCancel: () {
            Navigator.pop(context, false);
          },
          onDelete: () {
            Navigator.pop(context, true);
          },
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(accountsProvider.notifier)
          .removeAccount(account.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          Colors.black.withValues(alpha: 0.80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: const Text(
            'Account deleted successfully.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          Colors.black.withValues(alpha: 0.80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            'Delete failed: $e',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
}

class _GlassBackground extends StatelessWidget {
  final bool isDark;

  const _GlassBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                Color(0xFF080B25),
                Color(0xFF171330),
                Color(0xFF081B38),
              ]
                  : const [
                Color(0xFF246BFE),
                Color(0xFF6A4CFF),
                Color(0xFF19A7FF),
              ],
            ),
          ),
        ),

        const _GlowOrb(
          size: 260,
          top: -70,
          left: -70,
          color: Color(0xFF5E5CE6),
        ),

        const _GlowOrb(
          size: 280,
          top: 180,
          right: -110,
          color: Color(0xFFBF5AF2),
        ),

        const _GlowOrb(
          size: 220,
          bottom: 100,
          left: -80,
          color: Color(0xFF0A84FF),
        ),

        const _GlowOrb(
          size: 190,
          bottom: -60,
          right: 20,
          color: Color(0xFF30B0C7),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;

  const _GlowOrb({
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 50,
          sigmaY: 50,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.62),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _GlassHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30,
          sigmaY: 30,
        ),
        child: Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Manage Accounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              Positioned(
                left: 12,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                        Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManagementCard({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 14),
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
                        Colors.white
                            .withValues(alpha: 0.55),
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
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.14),
                          borderRadius:
                          BorderRadius.circular(17),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.24),
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${account.firstName} ${account.lastName}',
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Account: ${account.accountNumber}',
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.68),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    height: 1,
                    color: Colors.white
                        .withValues(alpha: 0.14),
                  ),

                  const SizedBox(height: 17),

                  Text(
                    'CURRENT BALANCE',
                    style: TextStyle(
                      color:
                      Colors.white.withValues(alpha: 0.58),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '₱${account.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _GlassAction(
                          icon: Icons.edit_rounded,
                          label: 'Edit',
                          onTap: onEdit,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _GlassAction(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          onTap: onDelete,
                          isDelete: true,
                        ),
                      ),
                    ],
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

class _GlassAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  const _GlassAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDelete
                    ? Colors.redAccent
                    .withValues(alpha: 0.35)
                    : Colors.white
                    .withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isDelete
                      ? Colors.redAccent
                      : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isDelete
                        ? Colors.redAccent
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassLoading extends StatelessWidget {
  const _GlassLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GlassError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _GlassError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.white,
                    size: 52,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Unable to load accounts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                      Colors.white.withValues(alpha: 0.68),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      height: 50,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.16),
                        borderRadius:
                        BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'No Bank Accounts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'No bank accounts found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                      Colors.white.withValues(alpha: 0.68),
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

class _GlassDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _GlassDialog({
    required this.title,
    required this.message,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
      Colors.black.withValues(alpha: 0.80),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: onDelete,
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}