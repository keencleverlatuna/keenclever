import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';
import 'edit_account_screen.dart';

class ManageAccountsScreen extends ConsumerWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _ManageAccountsHeader(
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
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                              colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(
                                accountsProvider.notifier,
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

                    return ListView.builder(
                      physics:
                      const BouncingScrollPhysics(),
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        30,
                      ),
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 14,
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

  Future<void> _deleteAccount(
      BuildContext context,
      WidgetRef ref,
      Account account,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Delete ${account.firstName} ${account.lastName}?',
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
              child: const Text('Delete'),
            ),
          ],
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
        const SnackBar(
          content: Text(
            'Account deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $e',
          ),
        ),
      );
    }
  }
}

class _ManageAccountsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ManageAccountsHeader({
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
              'Manage Accounts',
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
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
            colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
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
                  '${account.firstName} ${account.lastName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
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
                  'Balance: ₱${account.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            color: colorScheme.onSurface,
            icon: const Icon(
              Icons.edit,
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            color: colorScheme.error,
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),
    );
  }
}