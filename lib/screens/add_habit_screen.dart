import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:task_12/models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final nameController = TextEditingController();
  String frequency = 'Every day';
  final startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> addHabit() async {
    final id = FirebaseFirestore.instance.collection('habits').doc().id;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final habit = Habit(
      id: id,
      name: nameController.text,
      frequency: frequency,
      startDate: startDate,
      progress: {},
      userId: userId,
    );
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(id)
        .set(habit.toMap());
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: frequency,
              items:
                  ['Every day', 'Once a week', 'Once a month'].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (val) => setState(() => frequency = val!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: addHabit, child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}
