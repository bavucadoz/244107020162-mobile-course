import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: 'student@campus.ac.id');
  final _passwordController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login Campus Notify')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (authState.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  ref.read(authStateProvider.notifier).login(
                    _emailController.text,
                    _passwordController.text,
                  );
                },
                child: const Text('Login'),
              ),
            if (authState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  authState.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              )
          ],
        ),
      ),
    );
  }
}