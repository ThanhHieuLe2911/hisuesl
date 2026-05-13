import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // [MỚI] Import để đọc cài đặt âm thanh
import '../../../core/constants/app_colors.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import '../services/quiz_service.dart';
import '../../home/widgets/heart_shop_sheet.dart';
import '../../../core/services/sound_service.dart';

class QuizScreen extends StatefulWidget {
  final int unitId;
  const QuizScreen({super.key, required this.unitId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final QuestionService _questionService = QuestionService();
  final FlutterTts _flutterTts = FlutterTts();
  final SoundService _soundService = SoundService();

  List<QuestionModel> _questions = [];
  bool _isLoading = true;

  int _currentQuestionIndex = 0;
  int _hearts = 0;
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;

  int? _pendingStreakMilestone;

  List<Map<String, dynamic>> _wrongAnswers = [];

  bool _isChecked = false;
  dynamic _selectedAnswer;
  final TextEditingController _typeController = TextEditingController();
  List<String> _arrangeAvailableWords = [];
  List<String> _arrangeSelectedWords = [];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _speak(String text) => _flutterTts.speak(text);

  Future<void> _loadQuizData() async {
    await _refreshHeartData();

    bool canPlay = await _quizService.checkHeartAvailability();

    if (canPlay) {
      if (mounted) {
        setState(() => _isLoading = true);

        final questions = await _questionService.getQuestionsByUnit(widget.unitId);

        if (mounted) {
          setState(() {
            if (questions.isNotEmpty) {
              List<QuestionModel> shuffled = List.from(questions);
              shuffled.shuffle();
              _questions = shuffled.take(10).toList();
            } else {
              _questions = [];
            }
            _isLoading = false;
          });

          if (_questions.isNotEmpty) {
            _setupCurrentQuestion();
          }
        }
      }
    } else {
      if (mounted) _showOutOfHeartsDialog();
    }
  }

  Future<void> _refreshHeartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _hearts = doc.data()?['hearts'] ?? 0;
        });
      }
    }
  }

  void _setupCurrentQuestion() {
    if (_questions.isEmpty) return;

    final q = _questions[_currentQuestionIndex];
    _isChecked = false;
    _selectedAnswer = null;
    _pendingStreakMilestone = null;
    _typeController.clear();

    if (q.type == QuestionType.arrange) {
      _arrangeSelectedWords = [];
      _arrangeAvailableWords = List<String>.from(q.options ?? []);
      _arrangeAvailableWords.shuffle();
    } else if (q.type == QuestionType.listening) {
      _speak(q.questionText);
    }
  }

  // --- SỬA LỖI ÂM THANH TẠI ĐÂY ---
  void _checkAnswer() async {
    if (_selectedAnswer == null && _typeController.text.isEmpty && _arrangeSelectedWords.isEmpty) return;

    if (_hearts <= 0) {
      _showOutOfHeartsDialog();
      return;
    }

    // [MỚI] Lấy cài đặt âm thanh trước khi phát
    final prefs = await SharedPreferences.getInstance();
    bool isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;

    final currentQ = _questions[_currentQuestionIndex];
    bool isCorrect = false;

    switch (currentQ.type) {
      case QuestionType.multipleChoice:
      case QuestionType.listening:
        isCorrect = _selectedAnswer == currentQ.correctAnswer;
        break;
      case QuestionType.typing:
        isCorrect = _typeController.text.trim().toLowerCase() == currentQ.correctAnswer.toString().toLowerCase();
        break;
      case QuestionType.arrange:
        String userSentence = _arrangeSelectedWords.join(" ");
        String correctSentence = (currentQ.correctAnswer as List<String>).join(" ");
        isCorrect = userSentence == correctSentence;
        break;
    }

    setState(() {
      _isChecked = true;
      if (isCorrect) {
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;

        int multiplier = 1;
        if (_streak >= 10) multiplier = 10;
        else if (_streak >= 5) multiplier = 5;
        else if (_streak >= 3) multiplier = 3;

        _score += 10 * multiplier;

        if (_streak == 3 || _streak == 5 || _streak == 10) {
          _pendingStreakMilestone = _streak;
        }

      } else {
        _streak = 0;
        if (_hearts > 0) {
          _hearts--;
        }

        String userAnswerText = "";
        String correctAnswerText = "";

        if (currentQ.type == QuestionType.arrange) {
          userAnswerText = _arrangeSelectedWords.join(" ");
          correctAnswerText = (currentQ.correctAnswer as List<String>).join(" ");
        } else if (currentQ.type == QuestionType.typing) {
          userAnswerText = _typeController.text;
          correctAnswerText = currentQ.correctAnswer.toString();
        } else {
          userAnswerText = _selectedAnswer?.toString() ?? "Chưa chọn";
          correctAnswerText = currentQ.correctAnswer.toString();
        }

        _wrongAnswers.add({
          'question': currentQ.questionText,
          'userAnswer': userAnswerText,
          'correctAnswer': correctAnswerText,
        });
      }
    });

    if (!isCorrect) {
      await _quizService.deductHeart();
    }

    // [MỚI] Kiểm tra isSoundEnabled trước khi phát tiếng
    if (isCorrect) {
      if (isSoundEnabled) _soundService.playCorrect();
      _showResultSheet(true, "Chính xác!", currentQ.correctAnswer.toString());
    } else {
      if (isSoundEnabled) _soundService.playWrong();
      String correctText = currentQ.type == QuestionType.arrange
          ? (currentQ.correctAnswer as List<String>).join(" ")
          : currentQ.correctAnswer.toString();
      _showResultSheet(false, "Sai rồi!", "Đáp án đúng: $correctText");
    }

    if (_hearts == 0) {
      _showOutOfHeartsDialog();
    }
  }

  void _handleContinue() {
    if (_hearts == 0) {
      _showOutOfHeartsDialog();
      return;
    }

    Navigator.pop(context);

    if (_pendingStreakMilestone != null) {
      _showStreakCelebrationDialog(_pendingStreakMilestone!);
    } else {
      _moveToNextQuestion();
    }
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _setupCurrentQuestion();
    } else {
      _finishQuiz();
    }
  }

  void _showReviewMistakesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),

            Text("Ôn lại lỗi sai", style: GoogleFonts.dongle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.0)),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _wrongAnswers.length,
                itemBuilder: (ctx, index) {
                  final item = _wrongAnswers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Câu hỏi:", style: GoogleFonts.dongle(fontSize: 22, color: Colors.grey[600], height: 1.0)),
                        Text(item['question'], style: GoogleFonts.dongle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.1)),
                        const Divider(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.close, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(text: "Bạn chọn: ", style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey[600])),
                                      TextSpan(text: "${item['userAnswer']}", style: GoogleFonts.dongle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold)),
                                    ]
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(text: "Đáp án đúng: ", style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey[600])),
                                      TextSpan(text: "${item['correctAnswer']}", style: GoogleFonts.dongle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ]
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // --- SỬA LỖI ÂM THANH STREAK ---
  Future<void> _showStreakCelebrationDialog(int streak) async {
    // [MỚI] Check cài đặt âm thanh
    final prefs = await SharedPreferences.getInstance();
    bool isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;

    if (isSoundEnabled) {
      _soundService.playStreak();
    }

    String title = "";
    String message = "";
    Color color = Colors.blue;
    IconData icon = Icons.thumb_up;
    String? emoji;

    if (streak == 3) {
      title = "CHÁY QUÁ!";
      emoji = "🔥";
      message = "Bạn đã đúng 3 câu liên tiếp.\nĐiểm thưởng x3!";
      color = Colors.orange;
      icon = Icons.local_fire_department_rounded;
    } else if (streak == 5) {
      title = "XUẤT SẮC!";
      emoji = "⚡";
      message = "Bạn đã đúng 5 câu liên tiếp.\nĐiểm thưởng x5!";
      color = Colors.deepPurple;
      icon = Icons.flash_on_rounded;
    } else if (streak == 10) {
      title = "THẦN THÁNH!";
      emoji = "👑";
      message = "Bạn đã đúng 10 câu liên tiếp.\nĐiểm thưởng x10!";
      color = Colors.amber.shade800;
      icon = Icons.emoji_events_rounded;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color, width: 4),
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 60, color: color),
              ),
              const SizedBox(height: 20),
              Text(title, textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 42, fontWeight: FontWeight.bold, color: color, height: 1.0)),
              if (emoji != null)
                Text(emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 28, color: Colors.grey.shade700, height: 1.2)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: const StadiumBorder(),
                      elevation: 5
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _moveToNextQuestion();
                  },
                  child: Text("CHIẾN TIẾP!", style: GoogleFonts.dongle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOutOfHeartsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.heart_broken, color: Colors.red, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ôi hỏng!", style: GoogleFonts.dongle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red, height: 1.0)),
            const SizedBox(height: 10),
            Text("Bạn đã hết tim rồi.\nHãy mua thêm để tiếp tục nhé!", textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey[700], height: 1.2)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text("THOÁT", style: GoogleFonts.dongle(fontSize: 28, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5)
            ),
            onPressed: () async {
              Navigator.pop(context);

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                final points = doc.data()?['points'] ?? 0;

                if (mounted) {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => HeartShopSheet(currentPoints: points),
                  );
                  await _refreshHeartData();
                  if (_hearts <= 0) _showOutOfHeartsDialog();
                }
              }
            },
            child: Text("MUA TIM", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              Text("Dừng làm bài?", style: GoogleFonts.dongle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.0)),
              Text("Tiến độ bài kiểm tra này sẽ bị mất.", textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey, height: 1.1)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("THOÁT", style: GoogleFonts.dongle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Ở LẠI", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- SỬA LỖI ÂM THANH KẾT THÚC ---
  Future<void> _finishQuiz() async {
    _quizService.finishQuiz(_score, widget.unitId);

    // [MỚI] Check cài đặt âm thanh
    final prefs = await SharedPreferences.getInstance();
    bool isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    if (isSoundEnabled) {
      _soundService.playFinish();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.primary, width: 4),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 10),
              Text("HOÀN THÀNH!", style: GoogleFonts.dongle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.0)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultStat("Điểm số", "$_score", Colors.blue),
                  _buildResultStat("Streak", "$_maxStreak", Colors.orange),
                ],
              ),
              const SizedBox(height: 30),

              if (_wrongAnswers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => _showReviewMistakesSheet(),
                      child: Text("XEM LẠI LỖI SAI (${_wrongAnswers.length})",
                          style: GoogleFonts.dongle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      elevation: 5
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("TUYỆT VỜI", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.dongle(fontSize: 48, fontWeight: FontWeight.bold, color: color, height: 1.0)),
        Text(label, style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey, height: 1.0)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_questions.isEmpty) {
      return Scaffold(appBar: AppBar(leading: const BackButton()), body: const Center(child: Text("Không tải được câu hỏi!")));
    }

    final currentQ = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => _showExitConfirmDialog(),
        ),
        title: Row(
          children: [
            Expanded(
              child: LinearPercentIndicator(
                lineHeight: 12.0,
                percent: (_currentQuestionIndex + 1) / _questions.length,
                progressColor: AppColors.primary,
                backgroundColor: Colors.grey.shade200,
                barRadius: const Radius.circular(10),
                animation: true,
                animateFromLastPercent: true,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.favorite, color: Colors.red, size: 28),
            const SizedBox(width: 4),
            Text("$_hearts", style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red, height: 1.0)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Câu ${_currentQuestionIndex + 1}", style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey)),
                  if (currentQ.type == QuestionType.listening)
                    GestureDetector(
                      onTap: () => _speak(currentQ.questionText),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 50),
                      ),
                    )
                  else
                    Text(currentQ.questionText, style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                  const SizedBox(height: 30),
                  if (currentQ.type == QuestionType.multipleChoice || currentQ.type == QuestionType.listening)
                    _buildMultipleChoiceArea(currentQ)
                  else if (currentQ.type == QuestionType.arrange)
                    _buildArrangeArea()
                  else if (currentQ.type == QuestionType.typing)
                      _buildTypingArea()
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: _canSubmit() ? 4 : 0,
                ),
                onPressed: _canSubmit() ? _checkAnswer : null,
                child: Text("KIỂM TRA", style: GoogleFonts.dongle(fontSize: 30, color: _canSubmit() ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _canSubmit() {
    if (_isChecked) return false;
    final q = _questions[_currentQuestionIndex];
    if (q.type == QuestionType.arrange) return _arrangeSelectedWords.isNotEmpty;
    if (q.type == QuestionType.typing) return _typeController.text.isNotEmpty;
    return _selectedAnswer != null;
  }

  Widget _buildMultipleChoiceArea(QuestionModel q) {
    return Column(
      children: q.options!.map((option) {
        bool isSelected = _selectedAnswer == option;
        return GestureDetector(
          onTap: _isChecked ? null : () => setState(() => _selectedAnswer = option),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
              border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: Text(option, style: GoogleFonts.dongle(fontSize: 26, color: isSelected ? AppColors.primary : Colors.black87))),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary)
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingArea() {
    return TextField(
      controller: _typeController,
      enabled: !_isChecked,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: "Nhập đáp án tại đây...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: GoogleFonts.dongle(fontSize: 28),
    );
  }

  Widget _buildArrangeArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2))
          ),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: _arrangeSelectedWords.map((word) {
              return ActionChip(
                label: Text(word, style: GoogleFonts.dongle(fontSize: 24)),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                onPressed: _isChecked ? null : () {
                  setState(() {
                    _arrangeSelectedWords.remove(word);
                    _arrangeAvailableWords.add(word);
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 12, runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _arrangeAvailableWords.map((word) {
            return ActionChip(
              label: Text(word, style: GoogleFonts.dongle(fontSize: 24)),
              backgroundColor: Colors.white,
              elevation: 2,
              side: BorderSide(color: Colors.grey.shade300),
              onPressed: _isChecked ? null : () {
                setState(() {
                  _arrangeAvailableWords.remove(word);
                  _arrangeSelectedWords.add(word);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showResultSheet(bool isCorrect, String title, String message) {
    Color color = isCorrect ? Colors.green : Colors.red;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: color, size: 32),
                const SizedBox(width: 10),
                Text(title, style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold, color: color, height: 1.0)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.dongle(fontSize: 24, color: color)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, shape: const StadiumBorder()),
                onPressed: _handleContinue,
                child: Text("TIẾP TỤC", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}