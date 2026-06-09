import 'package:face_locker/core/theme/app_theme.dart';
import 'package:face_locker/core/widgets/app_toast.dart';
import 'package:face_locker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:face_locker/features/auth/presentation/controllers/login_controller.dart';
import 'package:face_locker/features/auth/presentation/pages/register_page.dart';
import 'package:face_locker/features/auth/repositories/auth_repository.dart';
import 'package:face_locker/features/home/presentation/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.controller});

  final LoginController? controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  LoginController? _internalController;

  bool _obscurePassword = true;

  LoginController get _controller {
    return widget.controller ??
        (_internalController ??= LoginController(
          authRepository: AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSource(),
          ),
        ));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await _controller.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      return;
    }

    AppToast.error(
      context,
      title: 'Sign in failed',
      message: _controller.errorMessage ?? 'Please check your credentials.',
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Invalid email format';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: AppTheme.softPanel(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: AppTheme.text,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to manage your smart locker.',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _emailCtrl,
                              validator: _emailValidator,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordCtrl,
                              validator: _requiredValidator,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_controller.isLoading) _onSubmit();
                              },
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _controller.isLoading
                                  ? null
                                  : _onSubmit,
                              icon: _controller.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded, size: 18),
                              label: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text('Sign up'),
                          ),
                        ],
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.lock_person_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Face Locker',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Smart cabinet control',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
