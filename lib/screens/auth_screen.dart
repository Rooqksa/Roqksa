// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isCreatingAccount = false;
  bool _hidePassword = true;
  bool _isLoading = false;

  static const _purple = Color(0xFF27D7D0);
  static const _gold = Color(0xFFFFC86B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continueWithFirebase() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final credential = _isCreatingAccount
          ? await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            )
          : await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'تعذر إنشاء جلسة المستخدم.',
        );
      }

      if (_isCreatingAccount) {
        final displayName = _nameController.text.trim();
        await user.updateDisplayName(displayName);
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();
        final now = FieldValue.serverTimestamp();
        batch.set(firestore.collection('users').doc(user.uid), {
          'uid': user.uid,
          'displayName': displayName,
          'photoUrl': null,
          'bio': '',
          'createdAt': now,
          'updatedAt': now,
        });
        batch.set(firestore.collection('publicProfiles').doc(user.uid), {
          'uid': user.uid,
          'displayName': displayName,
          'photoUrl': null,
          'bio': '',
          'giftsCount': 0,
          'postsCount': 0,
          'createdAt': now,
          'updatedAt': now,
        });
        await batch.commit();
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'invalid-email' => 'البريد الإلكتروني غير صحيح.',
        'user-disabled' => 'هذا الحساب موقوف.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        'email-already-in-use' => 'هذا البريد مسجل مسبقاً. سجّل الدخول بدلاً من ذلك.',
        'weak-password' => 'اختر كلمة مرور أقوى من 6 أحرف.',
        'too-many-requests' => 'محاولات كثيرة. حاول مرة أخرى لاحقاً.',
        'network-request-failed' => 'تحقق من اتصال الإنترنت وحاول مجدداً.',
        _ => 'تعذر تسجيل الدخول حالياً (${error.code}).',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ بيانات الحساب: ${error.message ?? error.code}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ غير متوقع. حاول مرة أخرى.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_purple, Color(0xFF5DE0D7)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Roqksa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCreatingAccount
                            ? 'أنشئ حسابك وابدأ رحلتك معنا'
                            : 'مرحباً بعودتك إلى مجتمع Roqksa',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 30),
                      if (_isCreatingAccount) ...[
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'الاسم الظاهر',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_isCreatingAccount &&
                                (value == null || value.trim().length < 2)) {
                              return 'اكتب اسماً من حرفين على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          final validEmail = RegExp(
                            r'^[^@ ]+@[^@ ]+[.][^@ ]+$',
                          ).hasMatch(email);
                          if (!validEmail) {
                            return 'أدخل بريداً إلكترونياً صحيحاً';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        autofillHints: [
                          _isCreatingAccount
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                            onPressed: () => setState(() {
                              _hidePassword = !_hidePassword;
                            }),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      if (_isCreatingAccount) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _continueWithFirebase,
                          style: FilledButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _isCreatingAccount ? 'إنشاء حساب' : 'تسجيل الدخول',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() {
                          _isCreatingAccount = !_isCreatingAccount;
                          _formKey.currentState?.reset();
                        }),
                        child: Text(
                          _isCreatingAccount
                              ? 'لديك حساب؟ تسجيل الدخول'
                              : 'ليس لديك حساب؟ إنشاء حساب جديد',
                          style: const TextStyle(color: _gold),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF192A3B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: _gold, size: 20),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'تسجيل الحسابات يتم عبر Firebase Authentication، وتُحفظ بيانات الملف الشخصي في Firestore.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
