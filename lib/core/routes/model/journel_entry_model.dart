import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String? id;
  final String chapterId;
  final String questionId;
  final DateTime date;
  final String question;
  final String? body;
  final List<String> imagePaths;
  final bool isPhotoProtected;

  // ── AI fields ──────────────────────────────────────────────
  final Map<String, dynamic>? tags;
  final String? taggingStatus;   // 'pending' | 'complete' | 'failed'
  final String? inferenceSource; // 'on_device' | 'cloud' | 'failed'
  // ───────────────────────────────────────────────────────────

  const JournalEntry({
    this.id,
    this.isPhotoProtected = false,
    required this.chapterId,
    required this.questionId,
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
      'body': body,
      'imagePaths': imagePaths,
      'isPhotoProtected': isPhotoProtected,
      'tags': tags,
      'taggingStatus': taggingStatus,
      'inferenceSource': inferenceSource,
    };
  }

  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    return JournalEntry(
      id: id,
      chapterId: map['chapterId'] as String? ?? '',
      questionId: map['questionId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      question: map['question'] as String? ?? '',
      body: map['body'] as String?,
      imagePaths: List<String>.from(map['imagePaths'] as List? ?? []),
      isPhotoProtected: map['isPhotoProtected'] as bool? ?? false,
      tags: map['tags'] as Map<String, dynamic>?,
      taggingStatus: map['taggingStatus'] as String?,
      inferenceSource: map['inferenceSource'] as String?,
    );
  }

  JournalEntry copyWith({
    String? id,
    List<String>? imagePaths,
    bool? isPhotoProtected,
    Map<String, dynamic>? tags,
    String? taggingStatus,
    String? inferenceSource,
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
    );
  }
}