/// Modela pirsekê ku li ser bingeha danegehê diawere.
class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.difficulty,
    required this.text,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.categoryName,
  });

  final String id;
  final String categoryId;
  final String? categoryName;
  final String difficulty;
  final String text;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption; // "A", "B", "C", veya "D"

  /// Seçenekleri liste olarak döndür.
  List<String> get options => [optionA, optionB, optionC, optionD];

  /// Doğru seçeneğin index'ini döndür (0-3 arası).
  int get correctIndex {
    switch (correctOption.toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 0;
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['category']?['name'] as String?,
      difficulty: json['difficulty'] as String,
      text: json['text'] as String,
      optionA: json['optionA'] as String,
      optionB: json['optionB'] as String,
      optionC: json['optionC'] as String,
      optionD: json['optionD'] as String,
      correctOption: json['correctOption'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'difficulty': difficulty,
        'text': text,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctOption': correctOption,
      };
}
