import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pirs_flutter/core/models/user.dart';
import 'package:pirs_flutter/core/providers/app_providers.dart';
import 'package:pirs_flutter/core/services/auth_service.dart';
import 'package:pirs_flutter/features/home/presentation/home_screen.dart';

/// Ekrana têketina bikarhêneran.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_nicknameCtrl.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Ji kerema xwe navê bikarhênerê binivîse';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isRegistering = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        nickname: _nicknameCtrl.text.trim(),
      );

      if (result.isSuccess && result.user != null) {
        final notifier = ref.read(currentUserProvider.notifier);
        notifier.state = result.user!;

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Çewtiyek çêbû')),
        );
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
          _isRegistering = false;
        });
      }
    } catch (e) {
      final message = 'Çewtiyek çêbû: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      setState(() {
        _errorMessage = message;
        _isLoading = false;
        _isRegistering = false;
      });
    }
  }

  Future<void> _handleLogin({bool asGuest = false}) async {
    if (asGuest) {
      final notifier = ref.read(currentUserProvider.notifier);
      notifier.state = UserProfile.guest();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (result.isSuccess && result.user != null) {
        final notifier = ref.read(currentUserProvider.notifier);
        notifier.state = result.user!;

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Çewtiyek çêbû')),
        );
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      final message = 'Çewtiyek çêbû: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pirsên Kurmancî'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bi xêr hatî, heval! \nBila hûn bi hesabekê yan jî wek mêvan tevlî bin.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isRegistering)
                        TextFormField(
                          controller: _nicknameCtrl,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Navê bikarhêner',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      if (_isRegistering) const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'E-peyam',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ji kerema xwe e-peyamê binivîse';
                          }
                          if (!value.contains('@')) {
                            return 'E-peyam rast nake';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Şîfre',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Herî kêm 6 tîpan binivîse';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _isRegistering ? _handleRegister() : _handleLogin(),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(_isRegistering ? Icons.person_add : Icons.lock_open),
                          label: Text(
                            _isLoading
                                ? (_isRegistering ? 'Tê qeyd dike...' : 'Têdikeve...')
                                : (_isRegistering ? 'Qeyd bike' : 'Têkeve'),
                          ),
                        ),
                      ),
                      if (!_isRegistering)
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isRegistering = true;
                                    _errorMessage = null;
                                  });
                                },
                          child: const Text('Hesabek nû vekir'),
                        )
                      else
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isRegistering = false;
                                    _errorMessage = null;
                                    _nicknameCtrl.clear();
                                  });
                                },
                          child: const Text('Hesabek heye? Têkeve'),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading ? null : () => _handleLogin(asGuest: true),
                        child: const Text('Wek mêvan bidomîne'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
