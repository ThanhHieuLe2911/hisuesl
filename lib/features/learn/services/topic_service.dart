import '../models/topic_model.dart';
import '../models/vocab_model.dart';
import '../data/mock_data.dart';
import 'api_service.dart';

class TopicService {
  Future<List<TopicModel>> getTopics() async {
    final result = await ApiService.get('topics');

    if (result['success'] == true && result['isList'] == true) {
      final List<dynamic> topicsData = result['data'];
      final List<TopicModel> topics = [];

      for (final topicJson in topicsData) {
        final topicId = topicJson['id'] as int? ?? 0;
        final vocabsResult = await ApiService.get('vocabularies?unit_id=$topicId');

        List<VocabModel> vocabs = [];
        if (vocabsResult['success'] == true && vocabsResult['isList'] == true) {
          vocabs = (vocabsResult['data'] as List)
              .map((v) => VocabModel.fromJson(v as Map<String, dynamic>))
              .toList();
        }

        topics.add(TopicModel.fromJson(topicJson as Map<String, dynamic>, vocabs));
      }

      return topics;
    }

    return mockTopics;
  }

  Future<TopicModel?> getTopicById(int id) async {
    final result = await ApiService.get('topics?id=$id');

    if (result['success'] == true && result['isList'] == false) {
      final topicJson = result['data'] as Map<String, dynamic>;
      final vocabsResult = await ApiService.get('vocabularies?unit_id=$id');

      List<VocabModel> vocabs = [];
      if (vocabsResult['success'] == true && vocabsResult['isList'] == true) {
        vocabs = (vocabsResult['data'] as List)
            .map((v) => VocabModel.fromJson(v as Map<String, dynamic>))
            .toList();
      }

      return TopicModel.fromJson(topicJson, vocabs);
    }

    return mockTopics.firstWhere((t) => t.id == id, orElse: () => mockTopics.first);
  }
}
