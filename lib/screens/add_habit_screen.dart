import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final nameController = TextEditingController();

  Future<void> addHabit() async {
    final id = FirebaseFirestore.instance.collection('habits').doc().id;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('habits').doc(id).set({
      'id': id,
      'name': nameController.text,
      'frequency': 'Щодня',
      'startDate': DateTime.now().toIso8601String(),
      'progress': {},
      'userId': userId,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Додати звичку')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Назва')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: addHabit, child: const Text('Додати')),
          ],
        ),
      ),
    );
  }
}
