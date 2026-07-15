import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pirs_flutter/core/models/category.dart';
import 'package:pirs_flutter/core/models/question.dart';
import 'package:pirs_flutter/core/services/category_service.dart';
import 'package:pirs_flutter/core/services/question_service.dart';
import 'package:pirs_flutter/core/services/game_service.dart';
import 'package:pirs_flutter/core/providers/app_providers.dart';

/// Lêpirsên 10-yê yên yekkeser.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, this.categoryId});
  
  /// Kategori ID'si (null ise tüm kategoriler)
  final String? categoryId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with TickerProviderStateMixin {
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int? _selectedIndex;
  bool _completed = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    // Ana ekrandan gelen kategori ID'sini kullan
    _selectedCategoryId = widget.categoryId;
    
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await CategoryService.getCategories();
      _categories = categories;
    } catch (e) {
      _categories = [];
    }

    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService.getQuestions(
        categoryId: _selectedCategoryId,
        limit: 10,
      );
      if (questions.isEmpty) {
        setState(() {
          _errorMessage = 'Pirs nehatin dîtin';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _questions = questions..shuffle();
        _currentIndex = 0;
        _score = 0;
        _correctAnswers = 0;
        _selectedIndex = null;
        _completed = false;
        _isLoading = false;
      });
      _cardController.forward(from: 0);
    } catch (e) {
      setState(() {
        _errorMessage = 'Pirs nehatin girtin: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int index) {
    if (_selectedIndex != null || _completed) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      if (index == _questions[_currentIndex].correctIndex) {
        _score += 10;
        _correctAnswers++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_selectedIndex == null) return;

    if (_currentIndex == 9 || _currentIndex == _questions.length - 1) {
      setState(() {
        _completed = true;
      });
      
      final user = ref.read(currentUserProvider);
      if (!user.isGuest) {
        try {
          await GameService.finishGame(
            score: _score,
            totalQuestions: _questions.length,
            correctAnswers: _correctAnswers,
          );
        } catch (e) {
          debugPrint('Encam nehat tomarkirin: $e');
        }
      }
    } else {
      _cardController.forward(from: 0);
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Pirs tên barkirin...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null || _questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.errorContainer,
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        size: 64,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pirs nehatin dîtin',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage ?? 'Ji kerema xwe paşê dîsa biceribîne',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Vegere malê'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_completed) {
      return _buildResultScreen(context, colorScheme);
    }

    final question = _questions[_currentIndex];
    final totalQuestions = _questions.length;
    final progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.surface,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst kısım - Progress ve skor
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1}/$totalQuestions',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Soru kartı
              Expanded(
                child: ScaleTransition(
                  scale: _cardAnimation,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '📝 Pirs',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Soru metni
                          Text(
                            question.text,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Seçenekler
                          Expanded(
                            child: ListView.separated(
                              itemCount: question.options.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildOptionCard(
                                  context,
                                  index,
                                  question.options[index],
                                  question.correctIndex,
                                  colorScheme,
                                );
                              },
                            ),
                          ),
                          
                          // İleri butonu
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _selectedIndex == null ? null : _nextQuestion,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _currentIndex == totalQuestions - 1
                                    ? 'Temam bike ✓'
                                    : 'Pirseke din →',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildOptionCard(
    BuildContext context,
    int index,
    String option,
    int correctIndex,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedIndex == index;
    final isCorrect = correctIndex == index;
    final showResult = _selectedIndex != null;
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;
    
    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
        trailingIcon = Icons.check_circle;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
        trailingIcon = Icons.cancel;
      } else {
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.outline.withOpacity(0.3);
        textColor = colorScheme.onSurface.withOpacity(0.5);
        trailingIcon = null;
      }
    } else {
      backgroundColor = colorScheme.surface;
      borderColor = colorScheme.outline.withOpacity(0.3);
      textColor = colorScheme.onSurface;
      trailingIcon = null;
    }

    final labels = ['A', 'B', 'C', 'D'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: showResult ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: showResult && isCorrect
                      ? Colors.green
                      : showResult && isSelected
                          ? Colors.red
                          : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: showResult && (isCorrect || isSelected)
                          ? Colors.white
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: isSelected || (showResult && isCorrect)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, ColorScheme colorScheme) {
    final totalQuestions = _questions.length;
    final percentage = (_correctAnswers / totalQuestions * 100).round();
    
    String emoji;
    String message;
    Color color;
    
    if (percentage >= 80) {
      emoji = '🏆';
      message = 'Pir baş! Tu zana yî!';
      color = Colors.amber;
    } else if (percentage >= 60) {
      emoji = '🎉';
      message = 'Baş e! Berdewam bike!';
      color = Colors.green;
    } else if (percentage >= 40) {
      emoji = '💪';
      message = 'Tu dikarî baştir bikî!';
      color = Colors.orange;
    } else {
      emoji = '📚';
      message = 'Pratîk bike, tu ê baştir bibî!';
      color = Colors.blue;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                Text(
                  'Lîstik Qediya!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Skor kartı
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            context,
                            Icons.star_rounded,
                            Colors.amber,
                            '$_score',
                            'Xal',
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                          _buildStatItem(
                            context,
                            Icons.check_circle_rounded,
                            Colors.green,
                            '$_correctAnswers/$totalQuestions',
                            'Rast',
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                          _buildStatItem(
                            context,
                            Icons.percent_rounded,
                            Colors.blue,
                            '$percentage%',
                            'Rêje',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Butonlar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadQuestions();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'Dîsa bilîze',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text(
                      'Vegere malê',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
