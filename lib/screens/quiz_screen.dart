import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/letter.dart';
import '../services/database_service.dart';
import '../services/pronunciation_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  List<Letter> letters = [];
  List<Letter> quizLetters = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  bool quizCompleted = false;
  String? selectedAnswer;
  bool showResult = false;

  late AnimationController _questionController;
  late AnimationController _optionController;
  late AnimationController _resultController;
  late Animation<double> _questionAnimation;
  late Animation<double> _optionAnimation;

  @override
  void initState() {
    super.initState();
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _optionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOutBack),
    );
    _optionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _optionController, curve: Curves.easeOut),
    );

    _loadQuiz();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final loadedLetters = await DatabaseService.instance.getLetters();
      setState(() {
        letters = loadedLetters;
        quizLetters = letters.take(10).toList()..shuffle();
        isLoading = false;
      });
      _questionController.forward();
      _optionController.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<String> _generateOptions(Letter correctLetter) {
    final options = <String>[correctLetter.pronunciation];
    final otherLetters = letters.where((l) => l.id != correctLetter.id).toList()
      ..shuffle();

    for (int i = 0; i < 3 && i < otherLetters.length; i++) {
      options.add(otherLetters[i].pronunciation);
    }

    options.shuffle();
    return options;
  }

  void _selectAnswer(String answer) {
    HapticFeedback.mediumImpact();
    setState(() {
      selectedAnswer = answer;
      showResult = true;
    });

    if (answer == quizLetters[currentQuestionIndex].pronunciation) {
      score++;
      PronunciationService.instance.speakPronunciation("Correct!");
    } else {
      PronunciationService.instance.speakPronunciation("Try again!");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestionIndex < quizLetters.length - 1) {
        _nextQuestion();
      } else {
        setState(() => quizCompleted = true);
        _resultController.forward();
      }
    });
  }

  void _nextQuestion() {
    _questionController.reverse().then((_) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showResult = false;
      });
      _questionController.forward();
    });
  }

  void _restartQuiz() {
    HapticFeedback.lightImpact();
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;
      selectedAnswer = null;
      showResult = false;
      quizLetters.shuffle();
    });
    _resultController.reset();
    _questionController.reset();
    _questionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954)),
        ),
      );
    }

    if (quizCompleted) {
      return _buildResultScreen();
    }

    final currentLetter = quizLetters[currentQuestionIndex];
    final options = _generateOptions(currentLetter);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1DB954),
              Color(0xFF121212),
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quiz Challenge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Question ${currentQuestionIndex + 1} of ${quizLetters.length}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / quizLetters.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: 40),

              // Question Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedBuilder(
                    animation: _questionAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _questionAnimation.value,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E1E1E),
                                Color(0xFF2A2A2A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'What is the pronunciation of this letter?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 40),

                                // Character
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    PronunciationService.instance
                                        .speakCharacter(
                                      currentLetter.character,
                                      "Listen carefully",
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1DB954),
                                          Color(0xFF1ed760)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1DB954)
                                              .withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        currentLetter.character,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 64,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Hint
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1DB954)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.volume_up_rounded,
                                        color: Color(0xFF1DB954),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tap to hear hint',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
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
                    },
                  ),
                ),
              ),

              // Options
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _optionAnimation,
                      builder: (context, child) {
                        return Column(
                          children: options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            return TweenAnimationBuilder(
                              duration:
                                  Duration(milliseconds: 200 + (index * 100)),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: _buildOptionButton(
                                        option, currentLetter),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
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

  Widget _buildOptionButton(String option, Letter currentLetter) {
    final isCorrect = option == currentLetter.pronunciation;
    final isSelected = option == selectedAnswer;

    Color backgroundColor = Colors.white.withOpacity(0.1);
    Color borderColor = Colors.white.withOpacity(0.2);
    Color textColor = Colors.white;

    if (showResult && isSelected) {
      backgroundColor = isCorrect
          ? Colors.green.withOpacity(0.3)
          : Colors.red.withOpacity(0.3);
      borderColor = isCorrect ? Colors.green : Colors.red;
    } else if (showResult && isCorrect) {
      backgroundColor = Colors.green.withOpacity(0.3);
      borderColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: showResult ? null : () => _selectAnswer(option),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: textColor.withOpacity(0.5)),
                  color: isSelected
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showResult && isCorrect)
                const Icon(Icons.volume_up_rounded,
                    color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (score / quizLetters.length * 100).round();
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isExcellent
                  ? const Color(0xFF1DB954)
                  : isGood
                      ? const Color(0xFFFECA57)
                      : const Color(0xFFFF6B6B),
              const Color(0xFF121212),
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _resultController,
            builder: (context, child) {
              return Transform.scale(
                scale: _resultController.value,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Trophy/Result Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          isExcellent
                              ? Icons.emoji_events_rounded
                              : isGood
                                  ? Icons.thumb_up_rounded
                                  : Icons.refresh_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        isExcellent
                            ? 'Excellent!'
                            : isGood
                                ? 'Good Job!'
                                : 'Keep Practicing!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'You scored $score out of ${quizLetters.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Action buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _restartQuiz,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF121212),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('Back to Home'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
