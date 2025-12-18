import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: leaderboard,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              return ListTile(
                leading: Text('#${index + 1}'),
                title: Text(data['name'] ?? 'Player'),
                trailing: Text('${data['score'] ?? 0}'),
              );
            },
          );
        },
      ),
    );
  }
}
