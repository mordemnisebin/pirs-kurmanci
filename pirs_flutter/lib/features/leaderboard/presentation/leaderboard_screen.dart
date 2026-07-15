import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pirs_flutter/core/services/leaderboard_service.dart';

/// Lîsteya xelatê.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _selectedPeriod = 'allTime';
  bool _isLoading = true;
  List<LeaderboardEntry> _leaders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final leaders = await LeaderboardService.getLeaderboard(period: _selectedPeriod);
      setState(() {
        _leaders = leaders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Tabloya giştî nehat girtin: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabloya Giştî'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (period) {
              if (period != _selectedPeriod) {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadLeaderboard();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'allTime',
                child: Text('Hemû dem'),
              ),
              const PopupMenuItem(
                value: 'daily',
                child: Text('Rojane'),
              ),
              const PopupMenuItem(
                value: 'weekly',
                child: Text('Hefteyî'),
              ),
              const PopupMenuItem(
                value: 'monthly',
                child: Text('Mehane'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadLeaderboard,
                          child: const Text('Dîsa biceribîne'),
                        ),
                      ],
                    ),
                  ),
                )
              : _leaders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Hîn kes lîst nekir',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLeaderboard,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final leader = _leaders[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: index < 3
                                  ? Colors.amber.shade100
                                  : Colors.grey.shade200,
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: index < 3 ? Colors.amber.shade900 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            title: Text(
                              leader.nickname,
                              style: TextStyle(
                                fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: Text(
                              '${leader.score} xal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: _leaders.length,
                      ),
                    ),
    );
  }
}
