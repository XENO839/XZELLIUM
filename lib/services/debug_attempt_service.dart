import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Save the result of a daily debug challenge for a user.
Future<void> saveChallengeResult({
  required String challengeId,
  required int attempts,
  required bool fixed,
  required int xp,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final now = DateTime.now();
  final datePath =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('debug_history')
      .doc(datePath)
      .collection('challenge$challengeId')
      .doc('result');

  await docRef.set({
    'fixed': fixed,
    'attempts': attempts,
    'completedAt': Timestamp.now(),
    'xpEarned': xp,
  });
}

/// Update the user's daily skill streak after solving any one challenge.
/// Increments if last solve was yesterday, resets if older, does nothing if already today.
Future<void> updateDailyStreak() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
  final snapshot = await userDoc.get();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final streakData = snapshot.data()?['streak'];

  if (streakData != null) {
    final lastUpdated = (streakData['lastUpdated'] as Timestamp).toDate();
    final lastDate = DateTime(
      lastUpdated.year,
      lastUpdated.month,
      lastUpdated.day,
    );
    final diff = today.difference(lastDate).inDays;

    if (diff == 1) {
      // Continue streak
      await userDoc.update({
        'streak.current': streakData['current'] + 1,
        'streak.max': (streakData['current'] + 1 > streakData['max'])
            ? streakData['current'] + 1
            : streakData['max'],
        'streak.lastUpdated': Timestamp.fromDate(today),
      });
    } else if (diff > 1) {
      // Streak broken
      await userDoc.update({
        'streak.current': 1,
        'streak.lastUpdated': Timestamp.fromDate(today),
      });
    }
    // If diff == 0 → already updated today → do nothing
  } else {
    // First streak entry
    await userDoc.set({
      'streak': {
        'current': 1,
        'max': 1,
        'lastUpdated': Timestamp.fromDate(today),
      },
    }, SetOptions(merge: true));
  }
}
