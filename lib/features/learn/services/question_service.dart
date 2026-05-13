import '../models/question_model.dart';
import '../data/mock_quiz_data.dart';
import 'api_service.dart';

class QuestionService {
  Future<List<QuestionModel>> getQuestionsByUnit(int unitId) async {
    final result = await ApiService.get('questions?unit_id=$unitId');

    if (result['success'] == true && result['isList'] == true) {
      final List<dynamic> questionsData = result['data'];
      if (questionsData.isNotEmpty) {
        return questionsData
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
      }
    }

    return getQuestionsForUnit(unitId);
  }
}
