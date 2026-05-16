import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Adım 1 — e-posta
  final _emailFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  // Adım 2 — kod + yeni şifre
  final _resetFormKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _codeSent = false;
  bool _loading = false;
  bool _done = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMessage = null; });
    await ref.read(authProvider.notifier).forgotPassword(email: _emailCtrl.text.trim());
    if (mounted) setState(() { _loading = false; _codeSent = true; });
  }

  Future<void> _resetPassword() async {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMessage = null; });

    final result = await ref.read(authProvider.notifier).resetPassword(
      email: _emailCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      newPassword: _newPassCtrl.text,
    );

    if (!mounted) return;
    if (result.success) {
      setState(() { _loading = false; _done = true; });
    } else {
      setState(() { _loading = false; _errorMessage = result.error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.softGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isDark ? Colors.white70 : AppTheme.primaryBlue,
                ),
                padding: EdgeInsets.zero,
              ).animate().fadeIn(),

              const SizedBox(height: 28),

              Text(
                'Şifreni Sıfırla',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryBlue,
                ),
              ).animate().fadeIn(delay: 60.ms).slideY(begin: -0.1),

              const SizedBox(height: 6),

              Text(
                _done
                    ? 'Şifren başarıyla güncellendi!'
                    : _codeSent
                        ? '${_emailCtrl.text.trim()} adresine gönderilen 6 haneli kodu girin.'
                        : 'Kayıtlı e-postana sıfırlama kodu göndereceğiz.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppTheme.midGrey,
                  height: 1.5,
                ),
              ).animate(key: ValueKey(_codeSent)).fadeIn(delay: 100.ms),

              const SizedBox(height: 40),

              if (_done)
                _SuccessState(isDark: isDark)
              else if (_codeSent)
                _ResetStep(
                  formKey: _resetFormKey,
                  codeCtrl: _codeCtrl,
                  newPassCtrl: _newPassCtrl,
                  confirmPassCtrl: _confirmPassCtrl,
                  obscureNew: _obscureNew,
                  obscureConfirm: _obscureConfirm,
                  onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
                  onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  loading: _loading,
                  errorMessage: _errorMessage,
                  onResend: () => setState(() { _codeSent = false; _codeCtrl.clear(); }),
                  onSubmit: _resetPassword,
                  isDark: isDark,
                )
              else
                _EmailStep(
                  formKey: _emailFormKey,
                  emailCtrl: _emailCtrl,
                  loading: _loading,
                  onSubmit: _sendCode,
                  isDark: isDark,
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSubmit,
    required this.isDark,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthFieldLabel('E-posta', isDark),
          const SizedBox(height: 8),
          AuthTextField(
            controller: emailCtrl,
            hint: 'ornek@mail.com',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
              if (!v.contains('@')) return 'Geçerli e-posta girin';
              return null;
            },
          ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.06),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Kod Gönder',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResetStep extends StatelessWidget {
  const _ResetStep({
    required this.formKey,
    required this.codeCtrl,
    required this.newPassCtrl,
    required this.confirmPassCtrl,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.loading,
    required this.errorMessage,
    required this.onResend,
    required this.onSubmit,
    required this.isDark,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController codeCtrl;
  final TextEditingController newPassCtrl;
  final TextEditingController confirmPassCtrl;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onResend;
  final VoidCallback onSubmit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthFieldLabel('6 Haneli Kod', isDark),
          const SizedBox(height: 8),
          AuthTextField(
            controller: codeCtrl,
            hint: '123456',
            icon: Icons.pin_outlined,
            isDark: isDark,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().length != 6) return '6 haneli kodu girin';
              return null;
            },
          ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.06),

          const SizedBox(height: 18),

          AuthFieldLabel('Yeni Şifre', isDark),
          const SizedBox(height: 8),
          _PassField(
            controller: newPassCtrl,
            hint: 'En az 6 karakter',
            obscure: obscureNew,
            onToggle: onToggleNew,
            isDark: isDark,
            validator: (v) {
              if (v == null || v.length < 6) return 'En az 6 karakter';
              return null;
            },
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06),

          const SizedBox(height: 18),

          AuthFieldLabel('Yeni Şifre (Tekrar)', isDark),
          const SizedBox(height: 8),
          _PassField(
            controller: confirmPassCtrl,
            hint: 'Şifreyi tekrar girin',
            obscure: obscureConfirm,
            onToggle: onToggleConfirm,
            isDark: isDark,
            validator: (v) {
              if (v != newPassCtrl.text) return 'Şifreler eşleşmiyor';
              return null;
            },
          ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.06),

          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryStatusRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.primaryStatusRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: AppTheme.primaryStatusRed, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Şifremi Sıfırla',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
          ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: loading ? null : onResend,
              child: const Text(
                'Kodu tekrar gönder',
                style: TextStyle(fontSize: 13, color: AppTheme.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  const _PassField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.isDark,
    required this.validator,
  });
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final bool isDark;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.textMuted),
        prefixIcon: Icon(Icons.lock_outline_rounded,
            color: isDark ? Colors.white38 : AppTheme.midGrey, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: isDark ? Colors.white38 : AppTheme.midGrey, size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white12 : AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white12 : AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryStatusRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryStatusRed, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryStatusGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: AppTheme.primaryStatusGreen, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Şifren güncellendi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Yeni şifrenle giriş yapabilirsin.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : AppTheme.midGrey,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.85, 0.85)),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: () => context.go('/login'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Giriş Ekranına Dön',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}
