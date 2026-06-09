import 'package:flutter/material.dart';
import 'package:face_locker/core/widgets/app_toast.dart';
import 'package:face_locker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:face_locker/features/auth/repositories/auth_repository.dart';
import 'package:face_locker/features/auth/presentation/controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.controller});

  final RegisterController? controller;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late final RegisterController _controller;
  late final bool _ownsController;

  String _gender = 'MALE';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        RegisterController(
          authRepository: AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSource(),
          ),
        );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _birthdayCtrl.dispose();
    _phoneCtrl.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final success = await _controller.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _gender,
      birthday: _birthdayCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      AppToast.success(
        context,
        title: 'Account created',
        message: 'You can sign in now.',
      );
      Navigator.of(context).pop();
      return;
    }

    AppToast.error(
      context,
      title: 'Register failed',
      message: _controller.errorMessage ?? 'Please check your information.',
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _birthdayValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) {
      return requiredError;
    }

    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Use format YYYY-MM-DD';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _firstNameCtrl,
                    validator: _requiredValidator,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _lastNameCtrl,
                    validator: _requiredValidator,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailCtrl,
                    validator: _requiredValidator,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(
                      hintText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
                      DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _gender = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _birthdayCtrl,
                    validator: _birthdayValidator,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Birthday (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneCtrl,
                    validator: _requiredValidator,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    validator: _requiredValidator,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Color(0xFF4A90E2),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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
