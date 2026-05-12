import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../models/quiz_model.dart';
import '../services/database_service.dart';
import '../services/draft_service.dart';
import '../services/connectivity_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class QuizCreatorScreen extends StatefulWidget {
  final Quiz? quizToEdit;
  const QuizCreatorScreen({super.key, this.quizToEdit});

  @override
  State<QuizCreatorScreen> createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedCategory = quizCategories.first;

  final List<Question> _questions = [];
  final DatabaseService _dbService = DatabaseService();
  final ConnectivityService _connectivityService = ConnectivityService();
  late DraftService _draftService;
  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySub;

  // Controllers for current question input
  final _questionTextController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  int _correctOptionIndex = 0;
  int? _editingQuestionIndex;

  bool get _isEditing => widget.quizToEdit != null;

  @override
  void initState() {
    super.initState();
    _initializeDraftService();
    _checkConnectivity();
    _addOptionField();
    _addOptionField();
    if (_isEditing) {
      _titleController.text = widget.quizToEdit!.title;
      _selectedCategory = widget.quizToEdit!.category;
      if (!quizCategories.contains(_selectedCategory)) {
        _selectedCategory = quizCategories.first;
      }
      _questions.addAll(widget.quizToEdit!.questions);
    }
  }

  Future<void> _initializeDraftService() async {
    _draftService = await DraftService.create();
  }

  void _checkConnectivity() async {
    final hasInternet = await _connectivityService.hasInternet();
    setState(() {
      _isOnline = hasInternet;
    });

    // Listen for connectivity changes
    _connectivitySub = _connectivityService.connectivityStream.listen((isOnline) {
      if (!mounted) return;
      setState(() {
        _isOnline = isOnline;
      });
      if (isOnline) {
        _showSyncPrompt();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _titleController.dispose();
    _questionTextController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
      if (_correctOptionIndex >= _optionControllers.length) {
        _correctOptionIndex = _optionControllers.length - 1;
      }
    });
  }

  void _clearQuestionForm() {
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers.clear();
    _questionTextController.clear();
    _optionControllers.add(TextEditingController());
    _optionControllers.add(TextEditingController());
    _correctOptionIndex = 0;
    _editingQuestionIndex = null;
    setState(() {});
  }

  void _loadQuestionIntoForm(int index) {
    final selected = _questions[index];
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers.clear();
    for (final option in selected.options) {
      _optionControllers.add(TextEditingController(text: option));
    }
    if (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
      _optionControllers.add(TextEditingController());
    }
    _correctOptionIndex = selected.correctAnswerIndex.clamp(
      0,
      _optionControllers.length - 1,
    );
    setState(() {
      _editingQuestionIndex = index;
      _questionTextController.text = selected.questionText;
    });
  }

  void _removeOptionField(int index) {
    if (_optionControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 2 options required')),
      );
      return;
    }
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      if (_correctOptionIndex == index) {
        _correctOptionIndex = 0;
      } else if (_correctOptionIndex > index) {
        _correctOptionIndex--;
      }
    });
  }

  // Generate a random 6-digit alphanumeric code
  String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      if (_editingQuestionIndex != null) {
        if (_editingQuestionIndex == index) {
          _clearQuestionForm();
        } else if (_editingQuestionIndex! > index) {
          _editingQuestionIndex = _editingQuestionIndex! - 1;
        }
      }
    });
  }

  void _saveQuestion() {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the question text')),
      );
      return;
    }

    final options = _optionControllers.map((c) => c.text.trim()).toList();
    if (options.any((o) => o.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all option fields')),
      );
      return;
    }

    final newQuestion = Question(
      questionText: _questionTextController.text.trim(),
      options: options,
      correctAnswerIndex: _correctOptionIndex,
    );

    setState(() {
      if (_editingQuestionIndex != null) {
        _questions[_editingQuestionIndex!] = newQuestion;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Question updated')));
      } else {
        _questions.add(newQuestion);
      }
      _clearQuestionForm();
    });
  }

  void _saveQuiz() async {
    // Offline drafts should never block saving because optional fields are empty.
    // So we validate only the title and question list, and do NOT rely on TextFormField
    // validators for question/options.
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a quiz')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      try {
        if (_isEditing) {
          // Verify user is the creator before allowing edits
          if (widget.quizToEdit!.creatorId != user.uid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Only the quiz creator can edit this quiz'),
              ),
            );
            return;
          }

          final updatedQuiz = Quiz(
            id: widget.quizToEdit!.id,
            title: _titleController.text.trim(),
            category: _selectedCategory,
            questions: _questions,
            shareCode: widget.quizToEdit!.shareCode,
            creatorId: widget.quizToEdit!.creatorId,
            sharedWith: widget.quizToEdit!.sharedWith,
          );
          await _dbService.updateQuiz(updatedQuiz);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz updated successfully!')),
          );
        } else {
          final newQuiz = Quiz(
            title: _titleController.text.trim(),
            category: _selectedCategory,
            questions: _questions,
            shareCode: _generateShareCode(),
            creatorId: user.uid,
          );

          // Check if user is online
          if (_isOnline) {
            // Upload directly to Firebase
            await _dbService.uploadQuiz(newQuiz, user.uid);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quiz Created! Code: ${newQuiz.shareCode}'),
              ),
            );
          } else {
            // Save as draft locally
            await _draftService.saveDraftQuiz(newQuiz);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Quiz saved as draft! Code: ${newQuiz.shareCode}',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      }
    } else if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question!')),
      );
    }
  }

  void _showSyncPrompt() async {
    final drafts = await _draftService.getAllDrafts();
    if (drafts.isEmpty) return;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Drafts'),
        content: Text(
          'You have ${drafts.length} draft(s) ready to sync. Sync now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _syncAllDrafts();
            },
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncAllDrafts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final drafts = await _draftService.getAllDrafts();
      for (final draft in drafts) {
        await _dbService.syncDraftQuiz(draft, user.uid);
      }
      await _draftService.clearAllDrafts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${drafts.length} quiz(zes) synced successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync failed: $errorMessage')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = categoryColors[_selectedCategory] ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Quiz' : 'Create New Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                prefixIcon: Icon(Icons.title, color: AppColors.primary),
              ),
              validator: validateInputForInjection,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category, color: AppColors.primary),
              ),
              items: quizCategories.map((category) {
                final color = categoryColors[category] ?? AppColors.primary;
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const Divider(height: 40, thickness: 2),
            Text(
              _isEditing ? "Edit Questions" : "Step 2: Add Questions",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: catColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: catColor.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _questionTextController,
                      decoration: const InputDecoration(
                        labelText: 'Question Text',
                        prefixIcon: Icon(
                          Icons.help_outline,
                          color: AppColors.primary,
                        ),
                      ),
                      validator: validateInputForInjection,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Answer Options',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_optionControllers.length, (index) {
                      final optColor =
                          optionColors[index % optionColors.length];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: _correctOptionIndex,
                              activeColor: AppColors.success,
                              onChanged: (val) {
                                setState(() => _correctOptionIndex = val!);
                              },
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  prefixIcon: Container(
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: optColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: optColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  suffixIcon: _optionControllers.length > 2
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: AppColors.error,
                                          ),
                                          onPressed: () =>
                                              _removeOptionField(index),
                                        )
                                      : null,
                                ),
                                validator: validateInputForInjection,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_optionControllers.length < 6)
                      TextButton.icon(
                        onPressed: _addOptionField,
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text(
                          'Add Option',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _saveQuestion,
                      icon: const Icon(Icons.add),
                      label: Text(
                        _editingQuestionIndex != null
                            ? "Update Question"
                            : "Add Question to List",
                      ),
                    ),
                    if (_editingQuestionIndex != null)
                      TextButton(
                        onPressed: _clearQuestionForm,
                        child: const Text(
                          'Cancel Edit',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Questions to be saved: ${_questions.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_editingQuestionIndex != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Editing question ${_editingQuestionIndex! + 1}. Save or cancel to continue.',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ...List.generate(_questions.length, (index) {
              final q = _questions[index];
              final isSelected = index == _editingQuestionIndex;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected ? AppColors.primary.withOpacity(0.08) : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    q.questionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${q.options.length} options • Correct: ${q.options[q.correctAnswerIndex]}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _removeQuestion(index),
                  ),
                  onTap: () => _loadQuestionIntoForm(index),
                ),
              );
            }),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing
                    ? AppColors.warning
                    : AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isEditing ? "UPDATE QUIZ" : "SAVE TO DATABASE",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
