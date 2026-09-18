import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() =>
      _WithdrawScreenState();
}

class _WithdrawScreenState
    extends ConsumerState<WithdrawScreen> {
  Account? selectedAccount;

  final amountController = TextEditingController();

  bool isWithdrawing = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> withdrawMoney() async {
    if (selectedAccount == null) {
      showMessage('Please select an account.');
      return;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      showMessage(
        'Please enter a valid withdrawal amount.',
      );
      return;
    }

    if (amount > selectedAccount!.balance) {
      showMessage('Insufficient balance.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _GlassConfirmDialog(
          title: 'Confirm Withdrawal',
          message:
          'Withdraw ₱${amount.toStringAsFixed(2)} '
              'from ${selectedAccount!.firstName} '
              '${selectedAccount!.lastName}?',
          onCancel: () {
            Navigator.pop(context, false);
          },
          onConfirm: () {
            Navigator.pop(context, true);
          },
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isWithdrawing = true;
    });

    try {
      final newBalance = await ref
          .read(accountsProvider.notifier)
          .withdrawFromAccount(
        id: selectedAccount!.id,
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return _GlassSuccessDialog(
            title: 'Withdrawal Successful',
            message:
            '₱${amount.toStringAsFixed(2)} '
                'has been withdrawn.\n\n'
                'New balance: '
                '₱${newBalance.toStringAsFixed(2)}',
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Withdrawal failed.\n\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isWithdrawing = false;
        });
      }
    }
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return _GlassMessageDialog(
          title: 'Withdrawal Error',
          message: message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

                    error: (error, stackTrace) =>
                        _GlassError(
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
                        Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        onRefresh: () {
                          return ref
                              .read(
                            accountsProvider.notifier,
                          )
                              .refreshAccounts();
                        },
                        child: SingleChildScrollView(
                          physics:
                          const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding:
                          const EdgeInsets.fromLTRB(
                            16,
                            14,
                            16,
                            130,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding:
                                EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  'Select Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  'Choose the account you want to withdraw money from.',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(
                                      alpha: 0.68,
                                    ),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              ...accounts.map(
                                    (account) => Padding(
                                  padding:
                                  const EdgeInsets.only(
                                    bottom: 14,
                                  ),
                                  child:
                                  _AccountSelectionCard(
                                    account: account,
                                    selected:
                                    selectedAccount
                                        ?.id ==
                                        account.id,
                                    onTap: () {
                                      setState(() {
                                        selectedAccount =
                                            account;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              if (selectedAccount != null)
                                ...[
                                  const SizedBox(height: 4),
                                  _GlassAmountCard(
                                    selectedAccount:
                                    selectedAccount!,
                                    amountController:
                                    amountController,
                                    isWithdrawing:
                                    isWithdrawing,
                                    onWithdraw:
                                    withdrawMoney,
                                  ),
                                ],
                            ],
                          ),
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
                'Withdraw Money',
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

class _AccountSelectionCard extends StatelessWidget {
  final Account account;
  final bool selected;
  final VoidCallback onTap;

  const _AccountSelectionCard({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 22,
            sigmaY: 22,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.19)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.23),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
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
                              .withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            .withValues(alpha: 0.22)
                            : Colors.white
                            .withValues(alpha: 0.12),
                        borderRadius:
                        BorderRadius.circular(17),
                        border: Border.all(
                          color: Colors.white
                              .withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        selected
                            ? Icons.check_rounded
                            : Icons.person_rounded,
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
                              fontSize: 17,
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
                                  .withValues(alpha: 0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '₱${account.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? Colors.white
                          : Colors.white
                          .withValues(alpha: 0.45),
                      size: 25,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassAmountCard extends StatelessWidget {
  final Account selectedAccount;
  final TextEditingController amountController;
  final bool isWithdrawing;
  final VoidCallback onWithdraw;

  const _GlassAmountCard({
    required this.selectedAccount,
    required this.amountController,
    required this.isWithdrawing,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 24,
          sigmaY: 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(alpha: 0.14),
                blurRadius: 30,
                offset: const Offset(0, 15),
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
                            .withValues(alpha: 0.60),
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.14),
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.24),
                          ),
                        ),
                        child: const Icon(
                          Icons.money_off_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Text(
                          'Withdrawal Amount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white
                              .withValues(alpha: 0.72),
                          size: 21,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Balance',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.58),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '₱${selectedAccount.balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 18,
                        sigmaY: 18,
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: 'Amount to Withdraw',
                          labelStyle: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.68),
                          ),
                          floatingLabelStyle:
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          prefixIcon: Padding(
                            padding:
                            const EdgeInsets.only(
                              left: 14,
                              right: 8,
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              color: Colors.white
                                  .withValues(alpha: 0.78),
                            ),
                          ),
                          prefixIconConstraints:
                          const BoxConstraints(
                            minWidth: 50,
                          ),
                          prefixText: '₱ ',
                          prefixStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                          filled: true,
                          fillColor: Colors.white
                              .withValues(alpha: 0.10),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white
                                  .withValues(alpha: 0.20),
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white
                                  .withValues(alpha: 0.65),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _GlassWithdrawButton(
                    isWithdrawing: isWithdrawing,
                    onTap: onWithdraw,
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

class _GlassWithdrawButton extends StatelessWidget {
  final bool isWithdrawing;
  final VoidCallback onTap;

  const _GlassWithdrawButton({
    required this.isWithdrawing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isWithdrawing ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isWithdrawing
                  ? const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 21,
                    height: 21,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.money_off_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Withdraw',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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
                color:
                Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                  Colors.white.withValues(alpha: 0.24),
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
                      color: Colors.white
                          .withValues(alpha: 0.68),
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
                color:
                Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                  Colors.white.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.12),
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
                      color: Colors.white
                          .withValues(alpha: 0.68),
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

class _GlassConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _GlassConfirmDialog({
    required this.title,
    required this.message,
    required this.onCancel,
    required this.onConfirm,
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
              color:
              Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'Confirm',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassSuccessDialog extends StatelessWidget {
  final String title;
  final String message;

  const _GlassSuccessDialog({
    required this.title,
    required this.message,
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
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
              Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'OK',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassMessageDialog extends StatelessWidget {
  final String title;
  final String message;

  const _GlassMessageDialog({
    required this.title,
    required this.message,
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'OK',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}