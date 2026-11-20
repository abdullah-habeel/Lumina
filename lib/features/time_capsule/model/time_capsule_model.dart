import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeCapsuleModel {
  final String id;
  final String title;
  final DateTime unlockDate;
  final DateTime sealedDate;
  final Color spineColor;

  // ── AI fields ──────────────────────────────────────────────
  final Map<String, dynamic>? patternAtSealing;
  final String? snapshotText;
  // ───────────────────────────────────────────────────────────

  TimeCapsuleModel({
    required this.id,
    required this.title,
    required this.unlockDate,
    required this.sealedDate,
    required this.spineColor,
    this.patternAtSealing,
    this.snapshotText,
  });

  int get daysLeft => unlockDate.difference(DateTime.now()).inDays;
  bool get isUnlocked => daysLeft <= 0;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'unlockDate': Timestamp.fromDate(unlockDate),
      'sealedDate': Timestamp.fromDate(sealedDate),
      'spineColor': spineColor.value,
      'patternAtSealing': patternAtSealing,
      'snapshotText': snapshotText,
    };
  }

  factory TimeCapsuleModel.fromMap(String id, Map<String, dynamic> map) {
    return TimeCapsuleModel(
      id: id,
      title: map['title'] as String? ?? '',
      unlockDate: (map['unlockDate'] as Timestamp).toDate(),
      sealedDate: (map['sealedDate'] as Timestamp).toDate(),
      spineColor: Color(map['spineColor'] as int? ?? 0xff32402F),
      patternAtSealing: map['patternAtSealing'] as Map<String, dynamic>?,
      snapshotText: map['snapshotText'] as String?,
    );
  }
}