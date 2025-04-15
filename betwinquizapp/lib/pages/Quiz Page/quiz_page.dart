import 'package:flutter/material.dart';
import 'package:betwinquizapp/services/TriviaService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:betwinquizapp/components/constants.dart';
import 'package:betwinquizapp/components/background.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:betwinquizapp/pages/Quiz%20Page/Components/CustomCountDownTimer.dart';
import 'Components/QuizCompletionBottomSheetWidget.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const int _normalModeQuestionCount = 5;
  static const int _bettingModeQuestionCount = 10;
  static const int _coinsPerCorrectAnswer = 5;
  static const Duration _nextButtonDelay = Duration(seconds: 1);
  static const Duration _questionDisplayDuration = Duration(seconds: 15);
  static const Duration _animationDuration = Duration(milliseconds: 500);

  final List<Question> _questions = [];
  final _controller = CustomCountDownTimerController();

  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int? _prediction;
  int questionNumber = 0;

  bool _isComplete = false;
  bool _isQuestionAnswered = false;
  bool _isLoading = true;
  bool _gameMode = true;
  bool _isNextButtonDisabled = false;
  bool _isBottomSheetOpen = false;
  String? _selectedAnswer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      questionNumber = int.parse(arguments['limit']);
    });
    _setGameMode(arguments);
    _fetchQuestions(arguments);
  }

  void _setGameMode(Map<String, dynamic> arguments) {
    if ( arguments['limit'] == questionNumber) {
      _prediction = arguments["prediction"];
    }
  }

  void _fetchQuestions(Map<String, dynamic> arguments) {
    TriviaService().fetchQuestions(
      limit: arguments["limit"],
      category: arguments["category"],
      difficulty: "easy",
    )
        .then(_handleFetchSuccess)
        .catchError(_handleFetchError);
  }

  void _handleFetchSuccess(List<Question> questions) {
    setState(() {
      _questions.addAll(questions);
      _isLoading = false;
      for (var question in _questions) {
        question.shuffleOptions();
      }
    });
  }

  void _handleFetchError(dynamic error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading questions: $error')),
    );
  }

  void _onNextQuestion() {
    if (_isNextButtonDisabled) return;

    setState(() {
      _isNextButtonDisabled = true;
    });

    if (_currentQuestionIndex < (_questions.length - 1)) {
      _moveToNextQuestion();
    } else {
      _completeQuiz();
    }

    Future.delayed(_nextButtonDelay, () {
      if (mounted && !_isComplete) {
        setState(() {
          _isNextButtonDisabled = false;
        });
      }
    });
  }

  void _moveToNextQuestion() {
    if (!_isComplete) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isQuestionAnswered = false;
        _controller.restart();
      });
    }
  }

  void _completeQuiz() {
    if (!_isComplete) {
      setState(() {
        _isComplete = true;
        _controller.pause();
      });
      _showCompletionSheet();
    }
  }

  void _showCompletionSheet() {
    if (_isBottomSheetOpen) return;

    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => QuizCompletionBottomSheet(
        correctCount: _correctCount,
        wrongCount: _wrongCount,
        coinsEarned: _correctCount * _coinsPerCorrectAnswer,
        gameMode: _gameMode,
        prediction: _gameMode ? null : _prediction,
      ),
    ).then((value) {
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
  }

  void _onOptionSelected(String option) {
    if (!_isQuestionAnswered && !_isComplete) {
      setState(() {
        _selectedAnswer = option;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentQuestion =
    _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
    final options = currentQuestion?.shuffledOptions ?? [];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        body: Background(
          child: _buildContent(size, currentQuestion, options),
        ),
      ),
    );
  }

  Widget _buildContent(
      Size size, Question? currentQuestion, List<String> options) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available.'));
    }
    return _buildQuizCard(size, currentQuestion, options);
  }

  Widget _buildQuizCard(
      Size size, Question? currentQuestion, List<String> options) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(child: _buildHeader(size)),
            Column(
              children: [
                SizedBox(
                  height: size.height * 0.65,
                  child: _buildCardAnimationWithBody(
                      size, currentQuestion, options),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AnimatedSwitcher _buildCardAnimationWithBody(
      Size size, Question? currentQuestion, List<String> options) {
    return AnimatedSwitcher(
      duration: _animationDuration,
      transitionBuilder: _buildTransition,
      child: _buildCardBody(size, currentQuestion, options),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  SizedBox _buildCardBody(
      Size size, Question? currentQuestion, List<String> options) {
    return SizedBox(
      key: ValueKey<int>(_currentQuestionIndex),
      height: size.height * 0.65,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimer(size),
            _buildQuestionText(currentQuestion),
            _buildOptionsColumn(options),
            _buildNavigationButton(size),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(Size size) {
    return CustomCountDownTimer(
      width: size.width * 0.2,
      height: size.height * 0.095,
      duration: _questionDisplayDuration.inSeconds,
      strokeWidth: 8,
      textStyle:
      GoogleFonts.quicksand(fontSize: 32, fontWeight: FontWeight.bold),
      fillColor: Colors.grey[300]!,
      isReverseAnimation: false,
      controller: _controller,
      onComplete: _onNextQuestion,
      ringColor: Constants.primaryColor,
    );
  }

  Widget _buildQuestionText(Question? currentQuestion) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AutoSizeText(
        currentQuestion!.question,
        maxFontSize: 24,
        style: GoogleFonts.quicksand(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildOptionsColumn(List<String> options) {
    return Column(
      children: options.map((option) {
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildQuestionButton(option),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButton(Size size) {
    final isLastQuestion = _currentQuestionIndex == (_questions.length - 1);
    return _buildControlButton(size, isLastQuestion ? 'Finish' : 'Next');
  }

  Widget _buildQuestionButton(String option) {
    final buttonColors = _getButtonColors(option);

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: buttonColors.backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: TextButton(
        onPressed:
        !_isQuestionAnswered ? () => _onOptionSelected(option) : null,
        style: TextButton.styleFrom(
          foregroundColor: buttonColors.foregroundColor,
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _buildOptionText(option, buttonColors.foregroundColor),
      ),
    );
  }

  ({Color backgroundColor, Color foregroundColor}) _getButtonColors(
      String option) {
    if (!_isQuestionAnswered) {
      return (
      backgroundColor:
      _selectedAnswer == option ? Constants.primaryColor : Colors.white,
      foregroundColor:
      _selectedAnswer == option ? Colors.white : Colors.black,
      );
    }

    if (option == _questions[_currentQuestionIndex].correctAnswer) {
      return (
      backgroundColor: Colors.lightGreen,
      foregroundColor: Colors.white
      );
    }
    if (_selectedAnswer == option) {
      return (backgroundColor: Colors.red, foregroundColor: Colors.white);
    }
    return (backgroundColor: Colors.white, foregroundColor: Colors.black);
  }

  Widget _buildOptionText(String option, Color foregroundColor) {
    return AutoSizeText(
      option,
      textAlign: TextAlign.center,
      style: GoogleFonts.quicksand(
        fontSize: 16,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
      ),
      minFontSize: 12,
      maxFontSize: 18,
      maxLines: 2,
    );
  }

  SizedBox _buildControlButton(Size size, String text) {
    return SizedBox(
      width: size.width * 0.5,
      child: ElevatedButton(
        onPressed: _isNextButtonDisabled ? null : _handleAnswerSubmission,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 32.0,
          ),
          backgroundColor: Constants.secondaryColor,
          foregroundColor: Colors.white,
        ),
        child: Text(text),
      ),
    );
  }

  Future<void> _handleAnswerSubmission() async {
    if (!_isComplete) {
      _controller.pause();
      if (_selectedAnswer != null) {
        _updateScores();
      }
      setState(() {
        _isQuestionAnswered = true;
      });
      await Future.delayed(_nextButtonDelay);
      _onNextQuestion();
    }
  }

  void _updateScores() {
    if (_selectedAnswer == _questions[_currentQuestionIndex].correctAnswer) {
      _correctCount++;
    } else {
      _wrongCount++;
    }
  }

  Widget _buildHeader(Size size) {
    return SizedBox(
      height: size.height * 0.08,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/$questionNumber',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / (questionNumber),
              borderRadius: BorderRadius.circular(12),
              minHeight: 6,
              backgroundColor: Colors.grey[300]!,
              color: Constants.primaryColor,
            ),
            SizedBox(height: size.height * 0.02),
          ]),
        ],
      ),
    );
  }
}
