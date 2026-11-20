import 'package:cloud_firestore/cloud_firestore.dart';

class DeletedLeaf {
  final int anchorIndex;
  final DateTime deletedAt;

  const DeletedLeaf({
    required this.anchorIndex,
    required this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
        'anchorIndex': anchorIndex,
        'deletedAt': Timestamp.fromDate(deletedAt),
      };

  factory DeletedLeaf.fromMap(Map<String, dynamic> map) => DeletedLeaf(
        anchorIndex: map['anchorIndex'] as int,
        deletedAt: (map['deletedAt'] as Timestamp).toDate(),
      );
}