import 'package:flutter/material.dart';

import '../../domain/validation.dart';
import 'sign_in_view_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({required this.viewModel, super.key});

  final SignInViewModel viewModel;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.viewModel.submit(_email.text, _password.text);
    }
  }

  void _resetPassword() {
    final problem = Validation.email(_email.text);
    if (problem != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Type your email first.')));
      return;
    }
    widget.viewModel.sendPasswordReset(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final vm = widget.viewModel;
                  final isSignUp = vm.mode == AuthMode.signUp;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isSignUp ? 'Create your account' : 'Gym Tracker',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: Validation.email,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          autofillHints: [
                            isSignUp
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          validator: Validation.password,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (vm.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            vm.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        if (vm.info != null) ...[
                          const SizedBox(height: 12),
                          Text(vm.info!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: vm.busy ? null : _submit,
                          child: vm.busy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isSignUp ? 'Create account' : 'Sign in'),
                        ),
                        TextButton(
                          onPressed: vm.busy ? null : vm.toggleMode,
                          child: Text(
                            isSignUp
                                ? 'I already have an account'
                                : 'Create an account',
                          ),
                        ),
                        if (!isSignUp)
                          TextButton(
                            onPressed: vm.busy ? null : _resetPassword,
                            child: const Text('Forgot password?'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
