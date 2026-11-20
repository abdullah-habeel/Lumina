import 'dart:ui';

class ChapterModel {
  final String chapterId;
  final int number;
  final String title;
  final String subtitle;
  final String thumbnailImage;
  final String backgroundImage;
  final Color bgColor;

  ChapterModel({
    required this.chapterId,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.thumbnailImage,
    required this.backgroundImage,
    required this.bgColor,
  });
}