import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService auth;
  final UserService users;
  final VoidCallback onSwitch;
  const RegisterScreen(
      {super.key,
      required this.auth,
      required this.users,
      required this.onSwitch});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  static const _roles = ['student', 'instructor', 'other'];
  String _role = _roles.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.users.pending =
        PendingProfile(_first.text.trim(), _last.text.trim(), _role);
    try {
      await widget.auth.register(email: _email.text, password: _password.text);
    } catch (e) {
      widget.users.pending = null;
      if (mounted) setState(() => _error = AuthService.message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(children: [
            TextFormField(
                controller: _first,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: _required),
            TextFormField(
                controller: _last,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: _required),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: [
                for (final r in _roles) DropdownMenuItem(value: r, child: Text(r))
              ],
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'At least 6 characters' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Register'),
            ),
            TextButton(
                onPressed: widget.onSwitch,
                child: const Text('I already have an account')),
          ]),
        ),
      ),
    );
  }
}
