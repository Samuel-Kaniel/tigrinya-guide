import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/letter.dart';
import '../services/database_service.dart';
import '../services/pronunciation_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  List<Letter> letters = [];
  int currentIndex = 0;
  bool showAnswer = false;
  bool isLoading = true;

  late AnimationController _cardController;
  late AnimationController _flipController;
  late Animation<double> _cardAnimation;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _loadLetters();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    try {
      final loadedLetters = await DatabaseService.instance.getLetters();
      setState(() {
        letters = loadedLetters;
        isLoading = false;
      });
      _cardController.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _nextLetter() {
    HapticFeedback.lightImpact();
    _cardController.reverse().then((_) {
      setState(() {
        currentIndex = (currentIndex + 1) % letters.length;
        showAnswer = false;
      });
      _flipController.reset();
      _cardController.forward();
    });
  }

  void _previousLetter() {
    HapticFeedback.lightImpact();
    _cardController.reverse().then((_) {
      setState(() {
        currentIndex = currentIndex > 0 ? currentIndex - 1 : letters.length - 1;
        showAnswer = false;
      });
      _flipController.reset();
      _cardController.forward();
    });
  }

  void _toggleAnswer() {
    HapticFeedback.mediumImpact();
    if (showAnswer) {
      _flipController.reverse().then((_) {
        setState(() => showAnswer = false);
      });
    } else {
      setState(() => showAnswer = true);
      _flipController.forward();
    }
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

    if (letters.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text(
            'No letters available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final currentLetter = letters[currentIndex];

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
                            'Practice Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${currentIndex + 1} of ${letters.length}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress indicator
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: (currentIndex + 1) / letters.length,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${((currentIndex + 1) / letters.length * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _cardAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardAnimation.value,
                        child: GestureDetector(
                          onTap: () {
                            PronunciationService.instance.speakPronunciation(
                                currentLetter.pronunciation);
                            HapticFeedback.selectionClick();
                          },
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
                            child: Stack(
                              children: [
                                // Background pattern
                                Positioned(
                                  right: -50,
                                  top: -50,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1DB954)
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                ),

                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Character
                                      Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF1DB954),
                                              Color(0xFF1ed760)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                              fontSize: 72,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Tap to hear hint
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1DB954)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF1DB954)
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.volume_up_rounded,
                                              color: Color(0xFF1DB954),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tap card to hear pronunciation',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Answer section
                                      AnimatedBuilder(
                                        animation: _flipAnimation,
                                        builder: (context, child) {
                                          return AnimatedOpacity(
                                            opacity: showAnswer
                                                ? _flipAnimation.value
                                                : 0.0,
                                            duration: const Duration(
                                                milliseconds: 200),
                                            child: showAnswer
                                                ? Column(
                                                    children: [
                                                      _buildAnswerRow(
                                                        'Pronunciation',
                                                        currentLetter
                                                            .pronunciation,
                                                        Icons
                                                            .record_voice_over_rounded,
                                                        () => PronunciationService
                                                            .instance
                                                            .speakPronunciation(
                                                                currentLetter
                                                                    .pronunciation),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      _buildAnswerRow(
                                                        'Example',
                                                        '${currentLetter.example} (${currentLetter.translation})',
                                                        Icons.translate_rounded,
                                                        () =>
                                                            PronunciationService
                                                                .instance
                                                                .speakExample(
                                                          currentLetter.example,
                                                          currentLetter
                                                              .translation,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox.shrink(),
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
                    },
                  ),
                ),
              ),

              // Controls
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Main action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleAnswer,
                        icon: Icon(showAnswer
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded),
                        label: Text(showAnswer ? 'Hide Answer' : 'Show Answer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Navigation controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          Icons.skip_previous_rounded,
                          'Previous',
                          _previousLetter,
                        ),
                        _buildControlButton(
                          Icons.shuffle_rounded,
                          'Shuffle',
                          () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              letters.shuffle();
                              currentIndex = 0;
                              showAnswer = false;
                            });
                            _flipController.reset();
                            _cardController.reset();
                            _cardController.forward();
                          },
                        ),
                        _buildControlButton(
                          Icons.skip_next_rounded,
                          'Next',
                          _nextLetter,
                        ),
                      ],
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

  Widget _buildAnswerRow(
      String title, String content, IconData icon, VoidCallback onPlay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1DB954), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onPlay();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
