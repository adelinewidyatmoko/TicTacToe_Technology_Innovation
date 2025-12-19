import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

DocumentReference<Map<String, dynamic>> getUserRef(String userId) {
  return FirebaseFirestore.instance.collection('leaderboard').doc(userId);
}

Future<void> incrementUserScore(String userId, int increment) async {
  final userRef = getUserRef(userId);
  await userRef.set({
    'score': FieldValue.increment(increment),
    'lastUpdated': FieldValue.serverTimestamp(),
    'hidden': false,
  }, SetOptions(merge: true));
}

String? getCurrentUserEmail() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.email;
}
