import 'package:flutter/material.dart';
import 'vocab_model.dart';

class TopicModel {
  final int id;
  final String title;
  final String description;
  final String imagePath;
  final Color color;
  final List<VocabModel> vocabularies;
  bool isLearned;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
    required this.vocabularies,
    this.isLearned = false,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json, List<VocabModel> vocabs) {
    return TopicModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: json['image_path'] as String? ?? 'assets/icons/default.png',
      color: _parseColor(json['color'] as String?),
      vocabularies: vocabs,
      isLearned: false,
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF4CB050);
    final cleanHex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }
}
