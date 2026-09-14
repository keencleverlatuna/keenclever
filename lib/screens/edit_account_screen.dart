import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  final Account account;

  const EditAccountScreen({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<EditAccountScreen> createState() =>
      _EditAccountScreenState();
}

class _EditAccountScreenState
    extends ConsumerState<EditAccountScreen> {
  late final TextEditingController accountNumberController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController balanceController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    accountNumberController =
        TextEditingController(text: widget.account.accountNumber);

    firstNameController =
        TextEditingController(text: widget.account.firstName);

    lastNameController =
        TextEditingController(text: widget.account.lastName);

    emailController =
        TextEditingController(text: widget.account.email);

    phoneController =
        TextEditingController(text: widget.account.phone);

    balanceController = TextEditingController(
      text: widget.account.balance.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    balanceController.dispose();

    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (accountNumberController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        balanceController.text.trim().isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    final balance =
    double.tryParse(balanceController.text.trim());

    if (balance == null || balance < 0) {
      _showError('Please enter a valid balance.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ref
          .read(accountsProvider.notifier)
          .editAccount(
        id: widget.account.id,
        accountNumber:
        accountNumberController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        balance: balance,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Account Updated',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'The bank account has been updated successfully.',
            ),
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

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
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
            'Update Error',
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
          child: Column(
            children: [
              _buildHeader(
                context,
                primaryText,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    30,
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primaryContainer,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 34,
                            color:
                            colorScheme.onPrimaryContainer,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Update Bank Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Edit the details below to update this account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryText,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _buildTextField(
                          controller:
                          accountNumberController,
                          label: 'Account Number',
                          icon: Icons.credit_card,
                          keyboardType:
                          TextInputType.number,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller:
                          firstNameController,
                          label: 'First Name',
                          icon: Icons.person_outline,
                          keyboardType:
                          TextInputType.name,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller:
                          lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          keyboardType:
                          TextInputType.name,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType:
                          TextInputType.emailAddress,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: phoneController,
                          label: 'Phone',
                          icon: Icons.phone_outlined,
                          keyboardType:
                          TextInputType.phone,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: balanceController,
                          label: 'Balance',
                          icon:
                          Icons.account_balance_wallet_outlined,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton.icon(
                            onPressed:
                            isSaving
                                ? null
                                : _saveChanges,
                            icon: isSaving
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.save_outlined,
                            ),
                            label: Text(
                              isSaving
                                  ? 'Saving...'
                                  : 'Save Changes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                              colorScheme.primary,
                              foregroundColor:
                              colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHeader(
      BuildContext context,
      Color textColor,
      ) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: textColor,
            ),
          ),

          Expanded(
            child: Text(
              'Edit Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: secondaryText,
        ),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark
              ? Colors.white70
              : Theme.of(context).colorScheme.primary,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.45),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white24
                : const Color(0xFF94A3B8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}
//latuna
