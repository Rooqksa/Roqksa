// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
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
  final _nameController = TextEditingController();
  bool _isCreatingAccount = false;
  bool _hidePassword = true;

  static const _purple = Color(0xFF9B72FF);
  static const _gold = Color(0xFFE9BD68);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _continueDemo() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'هذه معاينة تجريبية فقط؛ لم يتم إنشاء حساب أو تسجيل الدخول فعلياً.',
        ),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
                            colors: [_purple, Color(0xFFCB78E8)],
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
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _continueDemo,
                          style: FilledButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _isCreatingAccount ? 'إنشاء حساب تجريبي' : 'دخول تجريبي',
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
                          color: const Color(0xFF211C31),
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
                                'تسجيل الدخول وإنشاء الحساب هنا للمعاينة فقط. سيتم تفعيل الحسابات الحقيقية بعد ربط Firebase Authentication.',
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
,
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
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _continueDemo,
                          style: FilledButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _isCreatingAccount ? 'إنشاء حساب تجريبي' : 'دخول تجريبي',
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
                          color: const Color(0xFF211C31),
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
                                'تسجيل الدخول وإنشاء الحساب هنا للمعاينة فقط. سيتم تفعيل الحسابات الحقيقية بعد ربط Firebase Authentication.',
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
