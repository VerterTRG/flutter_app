import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/modules/auth/logic/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  final String? tabId;
  const LoginScreen({super.key, this.tabId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      context.read<AuthCubit>().login(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Навигация после успешного входа
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful')),
            );
            // Тут можно сделать pop или редирект,
            // но пока просто уведомление, так как навигация управляется глобально
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const CircularProgressIndicator();
                          }
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Login'),
                            ),
                          );
                        },
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
