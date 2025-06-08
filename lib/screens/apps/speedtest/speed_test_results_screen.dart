import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpeedTestResultsScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const SpeedTestResultsScreen({
    Key? key,
    this.auth,
    this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _auth = auth ?? FirebaseAuth.instance;
    final _firestore = firestore ?? FirebaseFirestore.instance;
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speed Test Results')),
        body: const Center(child: Text('Please sign in to view your results.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Speed Test Results')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('speed_tests')
            .doc(user.uid)
            .collection('results')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No results found.'));
          }

          final results = snapshot.data!.docs;

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                  .format(result['timestamp'].toDate());
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Speed: ${result['downloadSpeed'].toStringAsFixed(2)} Mbps',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Speed: ${result['uploadSpeed'].toStringAsFixed(2)} Mbps',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ping: ${result['ping']} ms',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: $formattedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
