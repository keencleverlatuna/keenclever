import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends ConsumerState<TransactionsScreen> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: _TransactionBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _GlassHeader(
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _FilterBar(
                  selectedFilter: selectedFilter,
                  onChanged: (index) {
                    setState(() {
                      selectedFilter = index;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: transactionsState.when(
                    loading: () => const _GlassLoading(),
                    error: (error, stackTrace) => _GlassError(
                      message: error.toString(),
                      onRetry: () {
                        ref
                            .read(transactionsProvider.notifier)
                            .refreshTransactions();
                      },
                    ),
                    data: (transactions) {
                      final filtered =
                      _filterTransactions(transactions);

                      return RefreshIndicator(
                        color: Colors.white,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.15),
                        displacement: 40,
                        onRefresh: () {
                          return ref
                              .read(
                            transactionsProvider.notifier,
                          )
                              .refreshTransactions();
                        },
                        child: filtered.isEmpty
                            ? ListView(
                          physics:
                          const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(
                            top: 120,
                            bottom: 150,
                          ),
                          children: const [
                            _GlassEmptyState(),
                          ],
                        )
                            : ListView.builder(
                          physics:
                          const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding:
                          const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            150,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                bottom: 14,
                              ),
                              child: _TransactionCard(
                                transaction: filtered[index],
                                onDelete: () {
                                  _confirmDelete(
                                    filtered[index],
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

  List<Transaction> _filterTransactions(
      List<Transaction> transactions,
      ) {
    if (selectedFilter == 1) {
      return transactions
          .where(
            (transaction) =>
        transaction.type.toLowerCase() == 'deposit',
      )
          .toList();
    }

    if (selectedFilter == 2) {
      return transactions
          .where(
            (transaction) =>
        transaction.type.toLowerCase() == 'withdraw',
      )
          .toList();
    }

    return transactions;
  }

  Future<void> _confirmDelete(
      Transaction transaction,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          title: const Text(
            'Delete Transaction?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this transaction history?\n\n',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(transaction.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Transaction deleted successfully.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          Colors.black.withValues(alpha: 0.78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete transaction: $error',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          Colors.black.withValues(alpha: 0.78),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    }
  }
}

class _GlassHeader extends StatelessWidget {
  final bool isDark;

  const _GlassHeader({
    required this.isDark,
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
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            16,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.16),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.swap_vert_rounded,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final int selectedFilter;
  final ValueChanged<int> onChanged;

  const _FilterBar({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      'All',
      'Deposits',
      'Withdrawals',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 22,
            sigmaY: 22,
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: List.generate(
                filters.length,
                    (index) {
                  final selected =
                      selectedFilter == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(index),
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(
                            alpha: 0.22,
                          )
                              : Colors.transparent,
                          borderRadius:
                          BorderRadius.circular(19),
                          border: selected
                              ? Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.18),
                          )
                              : null,
                        ),
                        child: Text(
                          filters[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: selected ? 1 : 0.68,
                            ),
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit =
        transaction.type.toLowerCase() == 'deposit';

    final amountText =
        '${isDeposit ? '+' : '-'} ₱${transaction.amount.toStringAsFixed(2)}';

    final date =
        '${transaction.createdAt.day.toString().padLeft(2, '0')}/'
        '${transaction.createdAt.month.toString().padLeft(2, '0')}/'
        '${transaction.createdAt.year}';

    final time =
        '${transaction.createdAt.hour.toString().padLeft(2, '0')}:'
        '${transaction.createdAt.minute.toString().padLeft(2, '0')}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 22,
          sigmaY: 22,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.14,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.20,
                        ),
                      ),
                    ),
                    child: Icon(
                      isDeposit
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDeposit
                              ? 'Deposit'
                              : 'Withdrawal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${transaction.firstName} ${transaction.lastName}',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.70,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountText,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.95,
                      ),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white.withValues(
                      alpha: 0.65,
                    ),
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.accountNumber,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.72,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '$date • $time',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.58,
                      ),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.20,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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

class _TransactionBackground extends StatelessWidget {
  const _TransactionBackground();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

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
                Color(0xFF090B1A),
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
          size: 230,
          top: -60,
          left: -50,
          color: Color(0xFF5E5CE6),
        ),
        const _GlowOrb(
          size: 260,
          top: 180,
          right: -100,
          color: Color(0xFFBF5AF2),
        ),
        const _GlowOrb(
          size: 210,
          bottom: 70,
          left: -70,
          color: Color(0xFF0A84FF),
        ),
        const _GlowOrb(
          size: 180,
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
          sigmaX: 45,
          sigmaY: 45,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.60),
            shape: BoxShape.circle,
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
      child: CircularProgressIndicator(
        color: Colors.white,
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
        padding: const EdgeInsets.all(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load transactions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.22,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

class _GlassEmptyState extends StatelessWidget {
  const _GlassEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: Colors.white.withValues(alpha: 0.70),
              size: 60,
            ),
            const SizedBox(height: 14),
            const Text(
              'No transactions yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Your deposits and withdrawals will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}