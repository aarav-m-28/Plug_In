import 'package:flutter/material.dart';
import 'package:app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _error;

  final _auth = AuthService();

  Future<void> _register() async {
    if (_username.isEmpty || _email.isEmpty || _password.isEmpty) {
      setState(() { _error = 'Please fill all fields'; });
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    
    final (success, message) = await _auth.register(
      username: _username,
      email: _email,
      password: _password,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() { _error = message; });
    }
    
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: (v) => _username = v,
                    validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (v) => _email = v,
                    validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (v) => _password = v,
                    validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_formKey.currentState?.validate() ?? false) _register();
                    },
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    child: const Text('Already have an account? Login'),
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
