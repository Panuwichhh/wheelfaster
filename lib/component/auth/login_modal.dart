import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheelfaster/controllers/auth_controller.dart';

class LoginModal extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginModal({super.key, this.onLoginSuccess});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _auth = AuthController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool loginSuccess = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = emailController.text.trim();
    final pass = passwordController.text;
    if (email.isEmpty || pass.isEmpty) {
      return "กรุณากรอกอีเมลและรหัสผ่าน";
    }
    if (!email.contains("@") || !email.contains(".")) {
      return "รูปแบบอีเมลไม่ถูกต้อง";
    }
    return null;
  }

  String _mapAuthError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return "อีเมลไม่ถูกต้อง";
        case 'user-disabled':
          return "บัญชีถูกปิดการใช้งาน";
        case 'user-not-found':
          return "ไม่พบบัญชีผู้ใช้";
        case 'wrong-password':
          return "รหัสผ่านไม่ถูกต้อง";
        case 'too-many-requests':
          return "ลองหลายครั้งเกินไป โปรดลองใหม่ภายหลัง";
        case 'network-request-failed':
          return "เครือข่ายมีปัญหา ตรวจสอบอินเทอร์เน็ต";
        default:
          return "เข้าสู่ระบบไม่สำเร็จ (${e.code})";
      }
    }
    return "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ";
  }

  Future<void> login() async {
    final v = _validate();
    if (v != null) {
      setState(() => error = v);
      return;
    }

    setState(() {
      loading = true;
      loginSuccess = false;
      error = null;
    });

    try {
      await _auth.signIn(emailController.text.trim(), passwordController.text);

      setState(() => loginSuccess = true);
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.pop(context);
      widget.onLoginSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loginSuccess = false;
        error = _mapAuthError(e);
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !loading;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary.withOpacity(0.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: const Icon(
                Icons.lock_outline,
                size: 36,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'เข้าสู่ระบบ',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: InputDecoration(
                labelText: 'อีเมล',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              ),
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => canSubmit ? login() : null,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF01CE55),
                  disabledBackgroundColor: const Color(0xFF8EEFB6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                ),
                onPressed: canSubmit ? login : null,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: loading
                      ? (loginSuccess
                            ? const Icon(
                                Icons.check_circle,
                                key: ValueKey('ok'),
                                color: Colors.white,
                                size: 28,
                              )
                            : const SizedBox(
                                key: ValueKey('spin'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ))
                      : const Text('เข้าสู่ระบบ', key: ValueKey('text')),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showLoginModal(BuildContext context, {VoidCallback? onLoginSuccess}) {
  showDialog(
    context: context,
    builder: (_) => LoginModal(onLoginSuccess: onLoginSuccess),
  );
}
