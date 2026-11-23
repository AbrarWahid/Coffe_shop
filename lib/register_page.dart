import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/validators.dart';
import 'widgets/app_button.dart';
import 'widgets/app_text_field.dart';
import 'widgets/auth_layout.dart';
import 'widgets/inline_message.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Registering signs the user in directly: no second login step.
      await AppScope.read(context)
          .register(_username.text, _email.text, _password.text);
      messenger.showSnackBar(
        const SnackBar(content: Text('Welcome! Your account is ready.')),
      );
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      eyebrow: 'Join the club',
      title: 'Great coffee,\njust a tap away.',
      subtitle: 'Create an account to save favourites, track orders and check out faster.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create account', style: AppText.display(26)),
              const SizedBox(height: 4),
              Text(
                'It only takes a minute.',
                style: AppText.body(14, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              InlineMessage(message: _error),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Username',
                controller: _username,
                hint: 'Letters, numbers, . or _',
                icon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.newUsername],
                validator: Validators.username,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Password',
                controller: _password,
                hint: 'At least 8 characters with a number',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.newPassword,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Create account',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppText.body(14, color: AppColors.muted),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.copperDeep,
                        textStyle: AppText.body(14, weight: FontWeight.w700),
                      ),
                      child: const Text('Sign in'),
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
