import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';

class DemoSeedService {
  final _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _entriesRef {
    final uid = _uid;
    if (uid == null) throw Exception('No signed-in user.');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('journal_entries');
  }

  CollectionReference<Map<String, dynamic>> get _capsulesRef {
    final uid = _uid;
    if (uid == null) throw Exception('No signed-in user.');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('time_capsules');
  }

  // ── Seed memories ───────────────────────────────────────────
  static final List<Map<String, dynamic>> _seedMemories = [
    // Beginnings — chapterId: beginnings
    {
      'chapterId': 'beginnings',
      'questionId': 'q1',
      'question': 'What is your earliest memory?',
      'body':
          'I remember sitting in my grandmother\'s kitchen, the smell of cardamom tea filling the room. She was humming something old and Arabic. I must have been four or five. The light came through a yellow curtain and everything felt warm and endless.',
      'daysAgo': 30,
      'tags': {
        'people': ['grandmother'],
        'emotions': ['nostalgia', 'warmth', 'peace'],
        'themes': ['family', 'childhood', 'home'],
        'keywords': ['kitchen', 'tea', 'grandmother', 'warmth', 'light'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'beginnings',
      'questionId': 'q2',
      'question': 'Who shaped who you are most?',
      'body':
          'My father, without question. He never told me what to be but always showed me how to work. He woke before sunrise every day for thirty years. I never understood it as a child. I understand it now.',
      'daysAgo': 28,
      'tags': {
        'people': ['father'],
        'emotions': ['admiration', 'gratitude', 'understanding'],
        'themes': ['family', 'work', 'growth'],
        'keywords': ['father', 'work', 'sunrise', 'discipline', 'childhood'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'beginnings',
      'questionId': 'q3',
      'question': 'What did home feel like growing up?',
      'body':
          'Crowded and loud and full of cousins on Fridays. My mother cooking from noon. The television always on. Someone always arguing about football. It felt like too much then. I would give anything to go back for one afternoon.',
      'daysAgo': 27,
      'tags': {
        'people': ['mother', 'cousins'],
        'emotions': ['longing', 'warmth', 'nostalgia'],
        'themes': ['family', 'home', 'childhood'],
        'keywords': ['mother', 'cousins', 'Friday', 'cooking', 'noise'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'beginnings',
      'questionId': 'q4',
      'question': 'What were you afraid of as a child?',
      'body':
          'The dark, mostly. And failing. Even at seven I was terrified of getting things wrong. My teacher once returned a test with a red mark and I cried in the bathroom. I never told anyone.',
      'daysAgo': 26,
      'tags': {
        'people': ['teacher'],
        'emotions': ['fear', 'shame', 'vulnerability'],
        'themes': ['childhood', 'fear', 'performance'],
        'keywords': ['dark', 'failing', 'test', 'shame', 'secret'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'beginnings',
      'questionId': 'q5',
      'question': 'What made you laugh as a child?',
      'body':
          'My uncle Hassan. He did voices for every character when he read to us. The wolf, the king, the frightened merchant — all different. He made us feel the story was real. I still hear his voice when I read.',
      'daysAgo': 25,
      'tags': {
        'people': ['uncle Hassan'],
        'emotions': ['joy', 'warmth', 'delight'],
        'themes': ['family', 'childhood', 'storytelling'],
        'keywords': ['uncle', 'laughter', 'stories', 'voices', 'joy'],
        'significance': 'medium',
      },
    },

    // Becoming Me — chapterId: becoming_me
    {
      'chapterId': 'becoming_me',
      'questionId': 'q1',
      'question': 'What was your hardest year?',
      'body':
          'The year I turned twenty-two. I had just failed my finals. My parents were disappointed but said nothing, which was worse. I spent three months doing nothing, feeling like a ghost in my own house. It was the year I finally decided to build something for myself.',
      'daysAgo': 23,
      'tags': {
        'people': ['parents'],
        'emotions': ['despair', 'shame', 'determination'],
        'themes': ['failure', 'growth', 'turning point'],
        'keywords': ['failure', 'finals', 'parents', 'ghost', 'decision'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'becoming_me',
      'questionId': 'q2',
      'question': 'When did you first feel truly capable?',
      'body':
          'When I shipped my first app. It was small and nobody used it. But I built it alone, from nothing. I remember sitting at my desk at two in the morning watching the build succeed. I felt like I could do anything.',
      'daysAgo': 22,
      'tags': {
        'people': [],
        'emotions': ['pride', 'joy', 'confidence'],
        'themes': ['work', 'achievement', 'growth'],
        'keywords': ['app', 'build', 'midnight', 'pride', 'capable'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'becoming_me',
      'questionId': 'q3',
      'question': 'What did you believe at twenty that you no longer believe?',
      'body':
          'That success would make me feel safe. I chased it for years. And when things finally started working, I realized the anxiety had never been about success at all. It was about something older than that.',
      'daysAgo': 21,
      'tags': {
        'people': [],
        'emotions': ['disillusionment', 'clarity', 'reflection'],
        'themes': ['growth', 'belief', 'self-discovery'],
        'keywords': ['success', 'safety', 'anxiety', 'belief', 'clarity'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'becoming_me',
      'questionId': 'q4',
      'question': 'Who did you lose along the way?',
      'body':
          'A friend named Tariq. We were close for six years. Something happened between us that neither of us ever named, and slowly the calls stopped. I still think about him sometimes. I hope he is well.',
      'daysAgo': 20,
      'tags': {
        'people': ['Tariq'],
        'emotions': ['grief', 'longing', 'acceptance'],
        'themes': ['friendship', 'loss', 'distance'],
        'keywords': ['Tariq', 'friendship', 'loss', 'silence', 'hope'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'becoming_me',
      'questionId': 'q5',
      'question': 'What habit changed your life?',
      'body':
          'Writing every morning. Even ten minutes. I started it during the hard year and never stopped. It is the only thing that makes me feel like I understand myself.',
      'daysAgo': 19,
      'tags': {
        'people': [],
        'emotions': ['clarity', 'peace', 'discipline'],
        'themes': ['growth', 'writing', 'self-discovery'],
        'keywords': ['writing', 'morning', 'habit', 'clarity', 'self'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'becoming_me',
      'questionId': 'q6',
      'question': 'What were you wrong about?',
      'body':
          'I was wrong about my brother for years. I thought he was careless and selfish. Then I saw how he was with his daughter and I understood that people are more than the version of them you first decided on.',
      'daysAgo': 18,
      'tags': {
        'people': ['brother'],
        'emotions': ['regret', 'understanding', 'humility'],
        'themes': ['family', 'growth', 'judgment'],
        'keywords': ['brother', 'wrong', 'judgment', 'daughter', 'change'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'becoming_me',
      'questionId': 'q7',
      'question': 'What made you feel most alive?',
      'body':
          'Traveling alone for the first time. I took a bus to a city where I knew no one. I ate at a small restaurant and nobody knew my name or my family or my failures. For two days I was just a person in the world.',
      'daysAgo': 17,
      'tags': {
        'people': [],
        'emotions': ['freedom', 'joy', 'aliveness'],
        'themes': ['travel', 'self-discovery', 'freedom'],
        'keywords': ['travel', 'alone', 'city', 'freedom', 'anonymous'],
        'significance': 'high',
      },
    },

    // Right Now — chapterId: right_now
    {
      'chapterId': 'right_now',
      'questionId': 'q1',
      'question': 'What are you working on right now?',
      'body':
          'An app called Lumina. It is a journaling app with AI built into it. I have been building it for months and it is almost ready. I want it to help people understand themselves the way writing has helped me.',
      'daysAgo': 15,
      'tags': {
        'people': [],
        'emotions': ['excitement', 'focus', 'purpose'],
        'themes': ['work', 'technology', 'purpose'],
        'keywords': ['Lumina', 'app', 'AI', 'journaling', 'building'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q2',
      'question': 'What do you want more of in your life?',
      'body':
          'Silence and slowness. I live fast. I always have more tabs open than I need, more plans than I can keep. I want to learn how to sit with one thing at a time.',
      'daysAgo': 14,
      'tags': {
        'people': [],
        'emotions': ['longing', 'restlessness', 'self-awareness'],
        'themes': ['self-discovery', 'peace', 'growth'],
        'keywords': ['silence', 'slow', 'focus', 'peace', 'present'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q3',
      'question': 'What are you afraid of now?',
      'body':
          'That I will build something good and it will not matter. Or worse, that I will not finish it. Fear of incompletion is the fear I carry most quietly.',
      'daysAgo': 13,
      'tags': {
        'people': [],
        'emotions': ['fear', 'vulnerability', 'honesty'],
        'themes': ['work', 'fear', 'self-discovery'],
        'keywords': ['fear', 'finish', 'build', 'matter', 'incompletion'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q4',
      'question': 'Who matters most to you right now?',
      'body':
          'My mother. She asks me every week if I am eating. I always say yes even when I am not. She knows. She sends food anyway. I do not say thank you enough.',
      'daysAgo': 12,
      'tags': {
        'people': ['mother'],
        'emotions': ['love', 'gratitude', 'guilt'],
        'themes': ['family', 'love', 'connection'],
        'keywords': ['mother', 'food', 'love', 'gratitude', 'care'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q5',
      'question': 'What do you believe today?',
      'body':
          'That small consistent effort beats talent almost every time. I have met brilliant people who built nothing. I have met ordinary people who built remarkable things. The difference was always showing up.',
      'daysAgo': 11,
      'tags': {
        'people': [],
        'emotions': ['conviction', 'clarity', 'confidence'],
        'themes': ['work', 'belief', 'growth'],
        'keywords': ['effort', 'talent', 'consistency', 'belief', 'showing up'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q6',
      'question': 'What do you do when things feel heavy?',
      'body':
          'I walk. No destination. No podcast. Just the street and whatever is in my head. Something about moving helps the weight redistribute itself.',
      'daysAgo': 10,
      'tags': {
        'people': [],
        'emotions': ['heaviness', 'relief', 'coping'],
        'themes': ['self-care', 'peace', 'coping'],
        'keywords': ['walk', 'heavy', 'movement', 'silence', 'coping'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q7',
      'question': 'What does success look like to you now?',
      'body':
          'Waking up with something to work on that feels worth it. That is all. Not numbers or titles. Just work that means something and people who are glad you exist.',
      'daysAgo': 6,
      'tags': {
        'people': [],
        'emotions': ['clarity', 'contentment', 'purpose'],
        'themes': ['success', 'purpose', 'work'],
        'keywords': ['success', 'meaning', 'work', 'worth', 'people'],
        'significance': 'high',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q8',
      'question': 'What are you grateful for today?',
      'body':
          'The fact that I get to build things. Not everyone does. Some people spend their whole life doing work they hate. I spend mine making things that did not exist before. That is a privilege I try not to forget.',
      'daysAgo': 4,
      'tags': {
        'people': [],
        'emotions': ['gratitude', 'humility', 'purpose'],
        'themes': ['gratitude', 'work', 'privilege'],
        'keywords': ['gratitude', 'build', 'privilege', 'create', 'meaning'],
        'significance': 'medium',
      },
    },
    {
      'chapterId': 'right_now',
      'questionId': 'q9',
      'question': 'What do you want to remember about this moment?',
      'body':
          'That I was trying. That I did not give up when things were uncertain. That I kept building even when I did not know if it would work. I want future me to know that past me showed up.',
      'daysAgo': 2,
      'tags': {
        'people': [],
        'emotions': ['determination', 'hope', 'pride'],
        'themes': ['growth', 'perseverance', 'self-belief'],
        'keywords': ['trying', 'building', 'uncertain', 'showed up', 'future'],
        'significance': 'high',
      },
    },
  ];

  // ── Main seed method ────────────────────────────────────────
  Future<void> seedDemoData() async {
    final uid = _uid;
    if (uid == null) throw Exception('No signed-in user.');

    // ── Seed memories ────────────────────────────────────────
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final seed in _seedMemories) {
      final daysAgo = seed['daysAgo'] as int;
      final date = now.subtract(Duration(days: daysAgo));
      final docId =
          '${seed['chapterId']}_${seed['questionId']}';

      final tags = seed['tags'] as Map<String, dynamic>;
final significance = tags['significance'] as String? ?? 'medium';
final significanceScore = significance == 'high' ? 8 : significance == 'medium' ? 5 : 2;

final entry = JournalEntry(
  id: docId,
  chapterId: seed['chapterId'] as String,
  questionId: seed['questionId'] as String,
  date: date,
  question: seed['question'] as String,
  body: seed['body'] as String,
  imagePaths: const [],
  tags: tags,
  taggingStatus: 'complete',
  inferenceSource: 'on_device',
  significanceScore: significanceScore,
);

      batch.set(_entriesRef.doc(docId), entry.toMap(), SetOptions(merge: false));
    }

    await batch.commit();

    // ── Seed time capsule ────────────────────────────────────
    final capsuleRef = _capsulesRef.doc('demo_capsule');

    final sealedDate = now.subtract(const Duration(days: 29));

    final patternAtSealing = {
      'totalMemories': 5,
      'topPeople': 'grandmother (1), father (1), mother (1)',
      'topEmotions': 'nostalgia (2), warmth (2), gratitude (1)',
      'topThemes': 'family (3), childhood (3), growth (1)',
      'highSignificanceCount': 3,
    };

    final capsule = TimeCapsuleModel(
      id: 'demo_capsule',
      title:
          'I am at the beginning of something. I do not know if Lumina will work. '
          'I do not know if I am good enough. But I am here, building it anyway. '
          'I hope future me is proud of what I started today.',
      unlockDate: now.subtract(const Duration(days: 1)),
      sealedDate: sealedDate,
      spineColor: const Color(0xff32402F),
      patternAtSealing: patternAtSealing,
      snapshotText:
          'You are someone who builds things in the dark, before anyone can '
          'see them. You carry doubt quietly and work loudly. Right now you '
          'are afraid but you are still here, and that is enough.',
    );

    await capsuleRef.set(capsule.toMap());

    debugPrint('DEMO_SEED: Seeded ${_seedMemories.length} memories + 1 capsule');
  }

  // ── Clear demo data ─────────────────────────────────────────
  Future<void> clearDemoData() async {
    final batch = _firestore.batch();

    for (final seed in _seedMemories) {
      final docId = '${seed['chapterId']}_${seed['questionId']}';
      batch.delete(_entriesRef.doc(docId));
    }

    await batch.commit();
    await _capsulesRef.doc('demo_capsule').delete();

    debugPrint('DEMO_SEED: Cleared all demo data');
  }
}