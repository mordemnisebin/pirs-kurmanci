import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pirs_flutter/core/models/category.dart';
import 'package:pirs_flutter/core/providers/app_providers.dart';
import 'package:pirs_flutter/core/services/category_service.dart';
import 'package:pirs_flutter/core/services/multiplayer_service.dart';
import 'multiplayer_game_screen.dart';

/// Multiplayer lobi ekranı - oda oluştur veya katıl.
class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  final _roomCodeController = TextEditingController();
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _connectAndListen();
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      // Kategoriler yüklenemezse varsayılan tüm kategoriler
    }
  }

  void _connectAndListen() {
    MultiplayerService.connect();
    
    _subscription = MultiplayerService.events.listen((event) {
      final eventType = event['event'] as String;
      final data = event['data'];

      switch (eventType) {
        case 'roomCreated':
          setState(() => _isLoading = false);
          if (data['success'] == true) {
            _navigateToWaitingRoom(
              roomCode: data['roomCode'],
              isOwner: true,
            );
          }
          break;
        case 'roomJoined':
          setState(() => _isLoading = false);
          if (data['success'] == true) {
            _navigateToWaitingRoom(
              roomCode: data['roomCode'],
              isOwner: data['isOwner'] ?? false,
            );
          }
          break;
        case 'serverError':
          setState(() {
            _isLoading = false;
            _errorMessage = data['message'] ?? 'Çewtî çêbû';
          });
          break;
      }
    });
  }

  void _navigateToWaitingRoom({required String roomCode, required bool isOwner}) {
    final user = ref.read(currentUserProvider);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiplayerWaitingRoom(
          roomCode: roomCode,
          isOwner: isOwner,
          userId: user.id,
          userName: user.nickname,
        ),
      ),
    );
  }

  void _createRoom() {
    final user = ref.read(currentUserProvider);
    if (user.isGuest) {
      _showLoginRequired();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    MultiplayerService.createRoom(
      userId: user.id,
      name: user.nickname,
      categoryId: _selectedCategoryId,
    );
  }

  void _joinRoom() {
    final user = ref.read(currentUserProvider);
    if (user.isGuest) {
      _showLoginRequired();
      return;
    }

    final code = _roomCodeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Koda odayê 6 tîp divê be');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    MultiplayerService.joinRoom(
      roomCode: code,
      userId: user.id,
      name: user.nickname,
    );
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ji bo multiplayer, divê tu têkevî'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('🎮 Multiplayer'),
                centerTitle: true,
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '👥',
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bi Hevalên Xwe Re Bilîze',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Odayek biafirîne an jî odayek beşdar bibe',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Hata mesajı
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Oda Oluştur
                      _buildSection(
                        title: '🏠 Odayek Biafirîne',
                        child: Column(
                          children: [
                            // Kategori seçimi
                            DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: 'Kategorî (Bijarte)',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Hemû Kategorî'),
                                ),
                                ..._categories.map((cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Row(
                                    children: [
                                      Text(cat.icon ?? '📁'),
                                      const SizedBox(width: 8),
                                      Text(cat.nameKu ?? cat.name),
                                    ],
                                  ),
                                )),
                              ],
                              onChanged: (value) => setState(() => _selectedCategoryId = value),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _createRoom,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.add_circle),
                                label: Text(_isLoading ? 'Tê afirandin...' : 'Oda Biafirîne'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Odaya Katıl
                      _buildSection(
                        title: '🚪 Odayekê Beşdar Bibe',
                        child: Column(
                          children: [
                            TextField(
                              controller: _roomCodeController,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                                UpperCaseTextFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Koda Odayê',
                                hintText: 'Mînak: ABC123',
                                prefixIcon: const Icon(Icons.vpn_key),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                counterText: '',
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _joinRoom,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(_isLoading ? 'Tê girêdan...' : 'Beşdar Bibe'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Bilgi kartı
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Çawa Dilîzin?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('1️⃣', 'Odayek biafirîne an koda odayê têkeve'),
                            _buildInfoRow('2️⃣', 'Li bendê bin ku hemû lîstikvan amade bin'),
                            _buildInfoRow('3️⃣', 'Xwediyê odayê lîstikê dest pê dike'),
                            _buildInfoRow('4️⃣', '10 pirs, 15 saniye ji bo her pirsê'),
                            _buildInfoRow('5️⃣', 'Bersiva zûtirîn herî zêde xal digire!'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Büyük harf formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Multiplayer bekleme odası
class MultiplayerWaitingRoom extends ConsumerStatefulWidget {
  const MultiplayerWaitingRoom({
    super.key,
    required this.roomCode,
    required this.isOwner,
    required this.userId,
    required this.userName,
  });

  final String roomCode;
  final bool isOwner;
  final String userId;
  final String userName;

  @override
  ConsumerState<MultiplayerWaitingRoom> createState() => _MultiplayerWaitingRoomState();
}

class _MultiplayerWaitingRoomState extends ConsumerState<MultiplayerWaitingRoom> {
  List<Map<String, dynamic>> _players = [];
  bool _isReady = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _isReady = widget.isOwner; // Oda sahibi otomatik hazır
    _listenToEvents();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenToEvents() {
    _subscription = MultiplayerService.events.listen((event) {
      final eventType = event['event'] as String;
      final data = event['data'];

      switch (eventType) {
        case 'playerJoined':
        case 'playerReady':
        case 'playerLeft':
        case 'playerDisconnected':
          setState(() {
            _players = List<Map<String, dynamic>>.from(data['players'] ?? []);
          });
          if (eventType == 'playerJoined' && data['newPlayer'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${data['newPlayer']} hate odayê! 👋'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          break;
        case 'gameStarted':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MultiplayerGameScreen(
                roomCode: widget.roomCode,
                userId: widget.userId,
                initialQuestion: data,
              ),
            ),
          );
          break;
        case 'serverError':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Çewtî çêbû'),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    });
  }

  void _setReady() {
    MultiplayerService.setReady(
      roomCode: widget.roomCode,
      userId: widget.userId,
    );
    setState(() => _isReady = true);
  }

  void _startGame() {
    MultiplayerService.startGame(
      roomCode: widget.roomCode,
      userId: widget.userId,
    );
  }

  void _leaveRoom() {
    MultiplayerService.leaveRoom(
      roomCode: widget.roomCode,
      userId: widget.userId,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allReady = _players.isNotEmpty && _players.every((p) => p['isReady'] == true);
    final canStart = widget.isOwner && allReady && _players.length >= 2;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Derkeve?'),
              content: const Text('Tu bi rastî dixwazî ji odayê derkevî?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Na'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Erê'),
                ),
              ],
            ),
          );
          if (shouldLeave == true) _leaveRoom();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade800,
                Colors.deepPurple.shade900,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final shouldLeave = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Derkeve?'),
                                  content: const Text('Tu bi rastî dixwazî ji odayê derkevî?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Na'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Erê'),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldLeave == true) _leaveRoom();
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Expanded(
                            child: Text(
                              'Odeya Bendê',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Oda Kodu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'KODA ODAYÊ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.roomCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: widget.roomCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kod hate kopîkirin! 📋'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vê kodê bi hevalên xwe re parve bike',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Oyuncu Listesi
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '👥 Lîstikvan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_players.length}/4',
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Expanded(
                          child: _players.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Li bendê lîstikvan...',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _players.length,
                                  itemBuilder: (context, index) {
                                    final player = _players[index];
                                    final isCurrentUser = player['id'] == widget.userId;
                                    final isOwner = index == 0;
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? Colors.purple.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: isCurrentUser
                                            ? Border.all(color: Colors.purple.withOpacity(0.3))
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.purple,
                                            child: Text(
                                              player['name']?.toString()[0].toUpperCase() ?? '?',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      player['name'] ?? 'Lîstikvan',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (isOwner) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.amber,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: const Text(
                                                          '👑 Xwedî',
                                                          style: TextStyle(fontSize: 10),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (isCurrentUser)
                                                  Text(
                                                    'Tu',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: player['isReady'] == true
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              player['isReady'] == true ? '✅ Amade' : '⏳ Li bendê',
                                              style: TextStyle(
                                                color: player['isReady'] == true
                                                    ? Colors.green
                                                    : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Aksiyonlar
                        if (!_isReady && !widget.isOwner)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _setReady,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Ez Amade Me!'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),

                        if (widget.isOwner) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: canStart ? _startGame : null,
                              icon: const Icon(Icons.play_arrow),
                              label: Text(
                                canStart
                                    ? 'Lîstikê Dest Pê Bike! 🎮'
                                    : _players.length < 2
                                        ? 'Herî kêm 2 lîstikvan lazim in'
                                        : 'Li benda amadebûnê...',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
