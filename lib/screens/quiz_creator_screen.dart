import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizCreatorScreen extends StatefulWidget {
  const QuizCreatorScreen({super.key});

  @override
  State<QuizCreatorScreen> createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  
  // List to hold the questions as the user adds them
  final List<Question> _questions = [];

  // Controllers for the current question being typed
  final _questionTextController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();

  void _addQuestion() {
    if (_questionTextController.text.isNotEmpty && 
        _option1Controller.text.isNotEmpty && 
        _option2Controller.text.isNotEmpty) {
      
      setState(() {
        _questions.add(Question(
          questionText: _questionTextController.text,
          options: [_option1Controller.text, _option2Controller.text],
          correctAnswerIndex: 0, // Simplified: first option is correct
        ));
        // Clear question fields for the next one
        _questionTextController.clear();
        _option1Controller.clear();
        _option2Controller.clear();
      });
    }
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      // In a real app, you would send this to Firebase or Local Storage here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz Created Successfully!')),
      );
      Navigator.pop(context);
    } else if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Quiz')),
      body: Form(
        key: _formKey, // Goal: Form with validation [cite: 213]
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quiz Title'),
              validator: (value) => value!.isEmpty ? 'Enter a title' : null,
            ),
            TextFormField(
              controller: _timeLimitController,
              decoration: const InputDecoration(labelText: 'Time Limit (Seconds) for Timed Mode'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter a time limit' : null,
            ),
            const Divider(height: 40),
            const Text("Add Questions", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _questionTextController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            TextFormField(
              controller: _option1Controller,
              decoration: const InputDecoration(labelText: 'Option 1 (Correct Answer)'),
            ),
            TextFormField(
              controller: _option2Controller,
              decoration: const InputDecoration(labelText: 'Option 2'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addQuestion, child: const Text("Add Question to List")),
            
            const SizedBox(height: 20),
            Text("Questions Added: ${_questions.length}"),
            // Optimization: List of questions added
            ..._questions.map((q) => ListTile(title: Text(q.questionText))),
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveQuiz,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Save Final Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}