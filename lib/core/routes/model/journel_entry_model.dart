import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String? id;
  final String chapterId;
  final String questionId;
  final DateTime date;
  final String question;
  final String? echoQuestion;
  final String? body;
  final List<String> imagePaths;
  final bool isPhotoProtected;
  final String? echoInferenceSource;

  // ── AI fields ──────────────────────────────────────────────
  final Map<String, dynamic>? tags;
  final String? taggingStatus;   // 'pending' | 'complete' | 'failed'
  final String? inferenceSource; // 'on_device' | 'cloud' | 'failed'
  final int? significanceScore;   // 1–10 numeric score
  // ───────────────────────────────────────────────────────────

  const JournalEntry({
    this.id,
    this.echoInferenceSource,
    this.echoQuestion,

    this.isPhotoProtected = false,
    required this.chapterId,
    required this.questionId,
    this.significanceScore,
    required this.date,
    required this.question,
    this.body,
    this.imagePaths = const [],
    this.tags,
    this.taggingStatus,
    this.inferenceSource,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get formattedDate =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'questionId': questionId,
      'date': Timestamp.fromDate(date),
      'question': question,
      'echoQuestion': echoQuestion,
      'body': body,
      'imagePaths': imagePaths,
      'isPhotoProtected': isPhotoProtected,
      'tags': tags,
      'taggingStatus': taggingStatus,
      'inferenceSource': inferenceSource,
       'significanceScore': significanceScore,
    };
  }

  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    return JournalEntry(
      id: id,
      echoInferenceSource: map['echoInferenceSource'] as String?,
      chapterId: map['chapterId'] as String? ?? '',
      questionId: map['questionId'] as String? ?? '',
      echoQuestion: map['echoQuestion'] as String?,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      question: map['question'] as String? ?? '',
      body: map['body'] as String?,
      imagePaths: List<String>.from(map['imagePaths'] as List? ?? []),
      isPhotoProtected: map['isPhotoProtected'] as bool? ?? false,
      tags: map['tags'] as Map<String, dynamic>?,
      taggingStatus: map['taggingStatus'] as String?,
      inferenceSource: map['inferenceSource'] as String?,
      significanceScore: map['significanceScore'] as int?,
    );
  }

    JournalEntry copyWith({
  String? id,
  String? echoInferenceSource,
  List<String>? imagePaths,
  bool? isPhotoProtected,
  Map<String, dynamic>? tags,
  String? taggingStatus,
  String? inferenceSource,
  int? significanceScore,
  String? echoQuestion,
}) {
  return JournalEntry(
    id: id ?? this.id,
    chapterId: chapterId,
    questionId: questionId,
    date: date,
    question: question,
    body: body,
    imagePaths: imagePaths ?? this.imagePaths,
    isPhotoProtected: isPhotoProtected ?? this.isPhotoProtected,
    tags: tags ?? this.tags,
    taggingStatus: taggingStatus ?? this.taggingStatus,
    inferenceSource: inferenceSource ?? this.inferenceSource,
    significanceScore: significanceScore ?? this.significanceScore,
    echoQuestion: echoQuestion ?? this.echoQuestion,
    echoInferenceSource: echoInferenceSource ?? this.echoInferenceSource,
  );
}
}