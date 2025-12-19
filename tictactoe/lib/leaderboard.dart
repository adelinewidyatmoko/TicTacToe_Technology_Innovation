import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = FirebaseFirestore.instance
        .collection('leaderboard')
        .where('hidden', isEqualTo: false)
        .orderBy('score', descending: true)
        .limit(100)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: leaderboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users available'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              return ListTile(
                leading: Text('#${index + 1}'),
                title: Text(doc.id),
                trailing: Text('${data['score'] ?? 0}'),
              );
            },
          );
        },
      ),
    );
  }
}
