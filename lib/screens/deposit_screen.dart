import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() =>
      _DepositScreenState();
}

class _DepositScreenState
    extends ConsumerState<DepositScreen> {
  Account? selectedAccount;

  final amountController = TextEditingController();

  bool isDepositing = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> depositMoney() async {
    if (selectedAccount == null) {
      showMessage('Please select an account.');
      return;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      showMessage(
        'Please enter a valid deposit amount.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Deposit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deposit ₱${amount.toStringAsFixed(2)} '
                'to ${selectedAccount!.firstName} '
                '${selectedAccount!.lastName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isDepositing = true;
    });

    try {
      final newBalance = await ref
          .read(accountsProvider.notifier)
          .depositToAccount(
        id: selectedAccount!.id,
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Deposit Successful',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '₱${amount.toStringAsFixed(2)} '
                  'has been deposited.\n\n'
                  'New balance: '
                  '₱${newBalance.toStringAsFixed(2)}',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
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
        'Deposit failed.\n\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isDepositing = false;
        });
      }
    }
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Deposit Error',
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
    final accountsState = ref.watch(accountsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColors = isDark
        ? const [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF111827),
    ]
        : const [
      Color(0xFFEAF4FF),
      Color(0xFFF7F9FC),
      Color(0xFFE8EEF7),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF7F9FC),
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
          child: Column(
            children: [
              _DepositHeader(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: accountsState.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 56,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load accounts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                              colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(
                                accountsProvider
                                    .notifier,
                              )
                                  .refreshAccounts();
                            },
                            icon: const Icon(
                              Icons.refresh,
                            ),
                            label: const Text(
                              'Retry',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return Center(
                        child: Text(
                          'No bank accounts found.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                            colorScheme.onSurface,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      physics:
                      const BouncingScrollPhysics(),
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        30,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                              colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...accounts.map(
                                (account) => Padding(
                              padding:
                              const EdgeInsets.only(
                                bottom: 12,
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
                              const SizedBox(height: 8),
                              GlassCard(
                                padding:
                                const EdgeInsets.all(
                                  20,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Deposit Amount',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Current balance: '
                                          '₱${selectedAccount!.balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    TextField(
                                      controller:
                                      amountController,
                                      keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: TextStyle(
                                        color: colorScheme
                                            .onSurface,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                      cursorColor:
                                      colorScheme.primary,
                                      decoration:
                                      InputDecoration(
                                        labelText:
                                        'Amount to Deposit',
                                        labelStyle: TextStyle(
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        prefixIcon:
                                        Icon(
                                          Icons
                                              .add_card,
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        prefixText: '₱ ',
                                        prefixStyle:
                                        TextStyle(
                                          color: colorScheme
                                              .onSurface,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.black
                                            .withValues(
                                          alpha: 0.18,
                                        )
                                            : Colors.white
                                            .withValues(
                                          alpha: 0.35,
                                        ),
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            16,
                                          ),
                                          borderSide:
                                          BorderSide(
                                            color: colorScheme
                                                .outline
                                                .withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            16,
                                          ),
                                          borderSide:
                                          BorderSide(
                                            color: colorScheme
                                                .primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width:
                                      double.infinity,
                                      child: GlassButton(
                                        icon: isDepositing
                                            ? const Icon(
                                          Icons.sync,
                                        )
                                            : const Icon(
                                          Icons
                                              .add_card,
                                        ),
                                        onTap:
                                        isDepositing
                                            ? () {}
                                            : depositMoney,
                                        label: isDepositing
                                            ? 'Processing...'
                                            : 'Deposit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepositHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _DepositHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 58,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
            color: colorScheme.onSurface,
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              'Deposit Money',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              colorScheme.primaryContainer,
              child: Icon(
                selected
                    ? Icons.check
                    : Icons.person,
                color:
                colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${account.firstName} '
                        '${account.lastName}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Account: ${account.accountNumber}',
                    style: TextStyle(
                      color:
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Balance: '
                        '₱${account.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}