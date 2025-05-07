import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_12/auth_gate.dart';
import 'add_habit_screen.dart';
import 'package:intl/intl.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  Future<void> toggleHabitCompletion(String habitId, bool isCompleted) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final habitRef = FirebaseFirestore.instance
        .collection('habits')
        .doc(habitId);

    await habitRef.set({
      'progress': {today: isCompleted},
      'userId': userId,
    }, SetOptions(merge: true));
  }

  Future<void> deleteHabit(String habitId) async {
    await FirebaseFirestore.instance.collection('habits').doc(habitId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.email ?? 'unknown user'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('habits')
                .where('userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No habits'));
          }

          return ListView(
            children:
                snapshot.data!.docs.map((doc) {
                  final habit = doc.data() as Map<String, dynamic>;
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                  final progress =
                      habit['progress'] as Map<String, dynamic>? ?? {};
                  final isCompletedToday = progress[today] == true;

                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await deleteHabit(doc.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('habit deleted')),
                        );
                      }
                    },
                    child: ListTile(
                      title: Text(habit['name']),
                      subtitle: Text(habit['frequency']),
                      trailing: Checkbox(
                        value: isCompletedToday,
                        onChanged: (value) async {
                          await toggleHabitCompletion(doc.id, value ?? false);
                        },
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
