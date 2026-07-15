import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pirs_flutter/core/providers/app_providers.dart';
import 'package:pirs_flutter/core/services/game_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  GameStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await GameService.getStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Statisîk nehatin girtin';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profîl')),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    user.nickname.isNotEmpty
                        ? user.nickname[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                children: [
                  Text(_error!, style: TextStyle(color: Colors.red.shade400)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadStats,
                    child: const Text('Dîsa biceribîne'),
                  ),
                ],
              )
            else if (_stats == null || _stats!.totalSessions == 0)
              const Text(
                'Hîn ti lîstik nehat lîstin. Dest bi yek lîstikê bike!',
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statisîkên te',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _ProfileStatRow(
                            label: 'Hejmara lîstikan',
                            value: _stats!.totalSessions.toString(),
                          ),
                          const Divider(),
                          _ProfileStatRow(
                            label: 'Xala herî zêde',
                            value: _stats!.bestScore.toString(),
                          ),
                          const Divider(),
                          _ProfileStatRow(
                            label: 'Navnîşa xal',
                            value: _stats!.averageScore.toString(),
                          ),
                          const Divider(),
                          _ProfileStatRow(
                            label: 'Rêjeya rast',
                            value:
                                '${(_stats!.correctRate * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatRow extends StatelessWidget {
  const _ProfileStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
