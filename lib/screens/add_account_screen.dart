import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_provider.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() =>
      _AddAccountScreenState();
}

class _AddAccountScreenState
    extends ConsumerState<AddAccountScreen> {
  final accountNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final balanceController = TextEditingController();

  bool isSaving = false;

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

  Future<void> _addAccount() async {
    if (accountNumberController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }

    final balanceText = balanceController.text.trim();

    final balance = balanceText.isEmpty
        ? 0.0
        : double.tryParse(balanceText);

    if (balance == null || balance < 0) {
      _showError('Please enter a valid balance.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      await ref
          .read(accountsProvider.notifier)
          .addAccount(
        accountNumber:
        accountNumberController.text.trim(),
        firstName:
        firstNameController.text.trim(),
        lastName:
        lastNameController.text.trim(),
        email:
        emailController.text.trim(),
        phone:
        phoneController.text.trim(),
        balance: balance,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return _GlassDialog(
            title: 'Account Created',
            message:
            'The bank account has been created successfully.',
            buttonText: 'OK',
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
        return _GlassDialog(
          title: 'Add Account Error',
          message: message,
          buttonText: 'OK',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  child: SingleChildScrollView(
                    physics:
                    const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      130,
                    ),
                    child: _GlassFormCard(
                      child: Column(
                        children: [
                          _GlassMainIcon(
                            icon:
                            Icons.person_add_alt_1_rounded,
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Create Bank Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Enter the details below to create a new account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.white
                                  .withValues(alpha: 0.70),
                            ),
                          ),

                          const SizedBox(height: 28),

                          _GlassTextField(
                            controller:
                            accountNumberController,
                            label: 'Account Number',
                            icon:
                            Icons.credit_card_rounded,
                            keyboardType:
                            TextInputType.number,
                          ),

                          const SizedBox(height: 16),

                          _GlassTextField(
                            controller:
                            firstNameController,
                            label: 'First Name',
                            icon:
                            Icons.person_outline_rounded,
                            keyboardType:
                            TextInputType.name,
                          ),

                          const SizedBox(height: 16),

                          _GlassTextField(
                            controller:
                            lastNameController,
                            label: 'Last Name',
                            icon:
                            Icons.person_outline_rounded,
                            keyboardType:
                            TextInputType.name,
                          ),

                          const SizedBox(height: 16),

                          _GlassTextField(
                            controller: emailController,
                            label: 'Email',
                            icon:
                            Icons.email_outlined,
                            keyboardType:
                            TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          _GlassTextField(
                            controller: phoneController,
                            label: 'Phone',
                            icon:
                            Icons.phone_outlined,
                            keyboardType:
                            TextInputType.phone,
                          ),

                          const SizedBox(height: 16),

                          _GlassTextField(
                            controller: balanceController,
                            label: 'Initial Balance',
                            icon: Icons
                                .account_balance_wallet_outlined,
                            keyboardType:
                            const TextInputType
                                .numberWithOptions(
                              decimal: true,
                            ),
                          ),

                          const SizedBox(height: 26),

                          _GlassCreateButton(
                            isSaving: isSaving,
                            onTap: _addAccount,
                          ),
                        ],
                      ),
                    ),
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
                'Add Account',
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

class _GlassFormCard extends StatelessWidget {
  final Widget child;

  const _GlassFormCard({
    required this.child,
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
            color: Colors.white.withValues(alpha: 0.13),
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

              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassMainIcon extends StatelessWidget {
  final IconData icon;

  const _GlassMainIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.white.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 34,
        color: Colors.white,
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color:
              Colors.white.withValues(alpha: 0.68),
            ),
            floatingLabelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 14,
                right: 8,
              ),
              child: Icon(
                icon,
                color:
                Colors.white.withValues(alpha: 0.78),
                size: 21,
              ),
            ),
            prefixIconConstraints:
            const BoxConstraints(
              minWidth: 50,
            ),
            filled: true,
            fillColor:
            Colors.white.withValues(alpha: 0.10),
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(20),
              borderSide: BorderSide(
                color:
                Colors.white.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(20),
              borderSide: BorderSide(
                color:
                Colors.white.withValues(alpha: 0.65),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCreateButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;

  const _GlassCreateButton({
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
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
                color:
                Colors.white.withValues(alpha: 0.32),
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
              child: isSaving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Create Account',
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

class _GlassDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const _GlassDialog({
    required this.title,
    required this.message,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
      Colors.black.withValues(alpha: 0.78),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color:
          Colors.white.withValues(alpha: 0.22),
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
          color:
          Colors.white.withValues(alpha: 0.72),
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}