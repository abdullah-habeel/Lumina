enum QuestionStatus { completed, current, locked }

class ChapterQuestionModel {
  final String id;
  final DateTime date;
  final String question;
  final bool isAnswered;

  const ChapterQuestionModel({
    required this.id,
    required this.date,
    required this.question,
    this.isAnswered = false,
  });

  ChapterQuestionModel copyWith({bool? isAnswered, DateTime? date}) {
    return ChapterQuestionModel(
      id: id,
      date: date ?? this.date,
      question: question,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
}