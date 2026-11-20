enum SharedDirection { received, sent }

enum SharedDeleteScope { forMe, forEveryone }

class SharedPage {
  final String id;
  final String personId;
  final String question;
  final DateTime date;
  final DateTime? sharedAt; // ← new
  final String personName;
  final SharedDirection direction;
  final bool isNew;
  final bool isSeen;
  final String? body;
  final List<String> imagePaths;
  final String chapterId;
  final String questionId;

  SharedPage({
    required this.id,
    required this.personId,
    required this.question,
    required this.date,
    this.sharedAt, // ← new
    required this.personName,
    required this.direction,
    this.isNew = false,
    this.isSeen = false,
    this.body,
    this.imagePaths = const [],
    this.chapterId = '',
    this.questionId = '',
  });
}

class TrustedPerson {
  final String? photoUrl;
  final String id;
  final String name;
  final String username;
  final int sharedMemoriesCount;

  TrustedPerson({
    this.photoUrl,
    required this.id,
    required this.name,
    required this.username,
    required this.sharedMemoriesCount,
  });
}

class ConnectionRequest {
  final String id;
  final String fromUid;
  final String name;
  final String username;

  ConnectionRequest({
    required this.id,
    required this.fromUid,
    required this.name,
    required this.username,
  });
}

class AcceptedRequestNotice {
  final String id;
  final String friendName;
  final DateTime respondedAt;

  AcceptedRequestNotice({
    required this.id,
    required this.friendName,
    required this.respondedAt,
  });
}