import 'package:flutter/material.dart';

import 'register_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/validators.dart';
import 'widgets/app_button.dart';
import 'widgets/app_text_field.dart';
import 'widgets/auth_layout.dart';
import 'widgets/inline_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // On success the app root swaps to the home screen by itself.
      await AppScope.read(context).signIn(_username.text, _password.text);
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      eyebrow: 'Welcome back',
      title: 'Your daily ritual,\nbrewed with care.',
      subtitle:
          'Sign in to reorder your favourites and get them delivered warm.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sign in', style: AppText.display(26)),
              const SizedBox(height: 4),
              Text(
                'Enter your details to continue.',
                style: AppText.body(14, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              InlineMessage(message: _error),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Username',
                controller: _username,
                hint: 'e.g. tony',
                icon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.username],
                validator: Validators.username,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Password',
                controller: _password,
                hint: 'Your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please enter your password'
                    : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Sign in',
                loading: _loading,
                onPressed: _submit,
                trailing: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.cream,
                  size: 20,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'New here? ',
                      style: AppText.body(14, color: AppColors.muted),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.copperDeep,
                        textStyle: AppText.body(14, weight: FontWeight.w700),
                      ),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
