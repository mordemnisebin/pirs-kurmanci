import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pirs_flutter/core/services/multiplayer_service.dart';

/// Multiplayer oyun ekranı.
class MultiplayerGameScreen extends ConsumerStatefulWidget {
  const MultiplayerGameScreen({
    super.key,
    required this.roomCode,
    required this.userId,
    required this.initialQuestion,
  });

  final String roomCode;
  final String userId;
  final Map<String, dynamic> initialQuestion;

  @override
  ConsumerState<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends ConsumerState<MultiplayerGameScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _currentQuestion;
  int _questionNumber = 1;
  int _totalQuestions = 10;
  int _timeLimit = 15;
  double _timeLeft = 15;
  Timer? _timer;
  
  String? _selectedAnswer;
  bool _answered = false;
  bool? _wasCorrect;
  String? _correctAnswer;
  String? _explanation;
  
  List<Map<String, dynamic>> _scores = [];
  bool _gameEnded = false;
  List<Map<String, dynamic>>? _finalRankings;
  
  late AnimationController _progressController;
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;
  
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeLimit),
    );
    
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
    
    _processQuestion(widget.initialQuestion);
    _listenToEvents();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _progressController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _processQuestion(Map<String, dynamic> data) {
    final question = data['question'] as Map<String, dynamic>;
    setState(() {
      _currentQuestion = question;
      _questionNumber = data['questionNumber'] ?? 1;
      _totalQuestions = data['totalQuestions'] ?? 10;
      _timeLimit = data['timeLimit'] ?? 15;
      _timeLeft = _timeLimit.toDouble();
      _selectedAnswer = null;
      _answered = false;
      _wasCorrect = null;
      _correctAnswer = null;
      _explanation = null;
    });
    
    _startTimer();
    _progressController.forward(from: 0);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timeLeft -= 0.1;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          if (!_answered) {
            _submitAnswer(null);
          }
          timer.cancel();
        }
      });
    });
  }

  void _listenToEvents() {
    _subscription = MultiplayerService.events.listen((event) {
      final eventType = event['event'] as String;
      final data = event['data'];

      switch (eventType) {
        case 'answerResult':
          _handleAnswerResult(data);
          break;
        case 'newQuestion':
          _processQuestion(data);
          break;
        case 'gameEnded':
          _handleGameEnded(data);
          break;
      }
    });
  }

  void _handleAnswerResult(Map<String, dynamic> data) {
    _timer?.cancel();
    
    setState(() {
      _wasCorrect = data['isCorrect'] ?? false;
      _correctAnswer = data['correctAnswer'];
      _explanation = data['explanation'];
      _scores = List<Map<String, dynamic>>.from(data['scores'] ?? []);
    });
    
    _resultController.forward(from: 0);
    
    // 3 saniye sonra sonraki soruya geç
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_gameEnded) {
        MultiplayerService.nextQuestion(roomCode: widget.roomCode);
      }
    });
  }

  void _handleGameEnded(Map<String, dynamic> data) {
    _timer?.cancel();
    setState(() {
      _gameEnded = true;
      _finalRankings = List<Map<String, dynamic>>.from(data['rankings'] ?? []);
    });
  }

  void _submitAnswer(String? answer) {
    if (_answered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });
    
    MultiplayerService.submitAnswer(
      roomCode: widget.roomCode,
      userId: widget.userId,
      answer: answer ?? '',
      timeSpent: _timeLimit - _timeLeft,
    );
  }

  Color _getOptionColor(String option) {
    if (!_answered) {
      return _selectedAnswer == option
          ? Colors.blue.withOpacity(0.2)
          : Colors.transparent;
    }
    
    if (option == _correctAnswer) {
      return Colors.green.withOpacity(0.3);
    }
    
    if (option == _selectedAnswer && _selectedAnswer != _correctAnswer) {
      return Colors.red.withOpacity(0.3);
    }
    
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    if (_gameEnded) {
      return _buildGameEndScreen();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade800,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Soru numarası
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Pirs $_questionNumber/$_totalQuestions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Timer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 5
                            ? Colors.red.withOpacity(0.3)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_timeLeft.ceil()}',
                        style: TextStyle(
                          color: _timeLeft <= 5 ? Colors.red.shade100 : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _timeLeft / _timeLimit,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      _timeLeft <= 5 ? Colors.red : Colors.green,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Soru kartı
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Soru
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (_currentQuestion?['difficulty'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    _currentQuestion!['difficulty'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getDifficultyText(_currentQuestion!['difficulty']),
                                  style: TextStyle(
                                    color: _getDifficultyColor(
                                      _currentQuestion!['difficulty'],
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              _currentQuestion?['text'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Seçenekler
                      ...['A', 'B', 'C', 'D'].map((option) {
                        final optionText = _currentQuestion?['option$option'] ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _answered ? null : () => _submitAnswer(option),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getOptionBorderColor(option),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getOptionColor(option),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getOptionBgColor(option),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            color: _getOptionTextColor(option),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_answered && option == _correctAnswer)
                                      const Icon(Icons.check_circle, color: Colors.green),
                                    if (_answered && 
                                        option == _selectedAnswer && 
                                        option != _correctAnswer)
                                      const Icon(Icons.cancel, color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // Açıklama
                      if (_answered && _explanation != null && _explanation!.isNotEmpty)
                        ScaleTransition(
                          scale: _resultAnimation,
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _explanation!,
                                    style: const TextStyle(color: Colors.blue),
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

              // Skorlar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📊 Xal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _scores.length,
                        itemBuilder: (context, index) {
                          final score = _scores[index];
                          final isCurrentUser = score['id'] == widget.userId;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.amber
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  score['name'] ?? '',
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${score['score']}',
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.black87 : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

  Widget _buildGameEndScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.shade700,
              Colors.orange.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                '🏆',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lîstik Qediya!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              
              // Sıralama
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎖️ Rêzbend',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _finalRankings?.length ?? 0,
                          itemBuilder: (context, index) {
                            final ranking = _finalRankings![index];
                            final isCurrentUser = ranking['id'] == widget.userId;
                            final rank = ranking['rank'] ?? index + 1;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: isCurrentUser
                                    ? Border.all(color: Colors.amber, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(rank),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getRankEmoji(rank),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ranking['name'] ?? 'Lîstikvan',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
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
                                  Text(
                                    '${ranking['score']} xal',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _getRankColor(rank),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Çıkış butonu
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Serûpelê'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOptionBorderColor(String option) {
    if (!_answered) {
      return _selectedAnswer == option ? Colors.blue : Colors.grey.shade300;
    }
    if (option == _correctAnswer) return Colors.green;
    if (option == _selectedAnswer) return Colors.red;
    return Colors.grey.shade300;
  }

  Color _getOptionBgColor(String option) {
    if (!_answered) {
      return _selectedAnswer == option ? Colors.blue : Colors.grey.shade200;
    }
    if (option == _correctAnswer) return Colors.green;
    if (option == _selectedAnswer && option != _correctAnswer) return Colors.red;
    return Colors.grey.shade200;
  }

  Color _getOptionTextColor(String option) {
    if (!_answered) {
      return _selectedAnswer == option ? Colors.white : Colors.black;
    }
    if (option == _correctAnswer) return Colors.white;
    if (option == _selectedAnswer) return Colors.white;
    return Colors.black;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '🟢 Hêsan';
      case 'medium':
        return '🟡 Navîn';
      case 'hard':
        return '🔴 Zehmet';
      case 'expert':
        return '🟣 Pispor';
      default:
        return difficulty;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.grey;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
