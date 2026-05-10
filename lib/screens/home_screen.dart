import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import '../models/quiz_model.dart';
import '../services/database_service.dart';
import 'quiz_creator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _selectedCategory = 'All';
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() => _controller.isDismissed ? _controller.forward() : _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final categoryColor = categoryColors[_selectedCategory] ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ThinkFast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.category, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text('Categories', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildCategoryItem('All', Icons.category),
            _buildCategoryItem('Science', Icons.science),
            _buildCategoryItem('History', Icons.history),
            _buildCategoryItem('Tech', Icons.computer),
            _buildCategoryItem('Math', Icons.calculate),
            _buildCategoryItem('Geography', Icons.public),
            _buildCategoryItem('Sports', Icons.sports),
            _buildCategoryItem('Entertainment', Icons.movie),
            _buildCategoryItem('Literature', Icons.menu_book),
            _buildCategoryItem('Others', Icons.more_horiz),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: categoryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, size: 18, color: categoryColor),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCategory,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<Quiz>>(
                    // FIXED: Uses the specific user filter
                    stream: _dbService.getQuizzesForUser(_selectedCategory),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading quizzes:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }

                      final quizzes = snapshot.data ?? [];
                      if (quizzes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                'No quizzes found.\nCreate or Import one!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final currentUser = FirebaseAuth.instance.currentUser;

                      return ListView.builder(
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];
                          final isCreator = quiz.creatorId == currentUser?.uid;
                          final catColor = categoryColors[quiz.category] ?? AppColors.primary;
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.quiz, color: catColor),
                              ),
                              title: Text(
                                quiz.title,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: catColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        quiz.category,
                                        style: TextStyle(fontSize: 12, color: catColor, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Code: ${quiz.shareCode}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isCreator)
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => QuizCreatorScreen(quizToEdit: quiz),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              title: const Text('Delete Quiz?'),
                                              content: Text('Are you sure you want to delete "${quiz.title}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            try {
                                              await _dbService.deleteQuiz(quiz.id!, quiz.shareCode);
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Quiz deleted')),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error deleting: $e')),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: AppColors.primary, size: 20),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: AppColors.error, size: 20),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: AppColors.error)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: AppColors.success),
                                  ),
                                ],
                              ),
                              onTap: () => _showModeSelection(context, quiz),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildSpeedDial(),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Import via Code"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: "Enter 6-digit code"),
          maxLength: 6,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              try {
                String? quizId;

                // 1. Try the shareCodes collection (new quizzes)
                final shareCodeDoc = await FirebaseFirestore.instance
                    .collection('shareCodes')
                    .doc(code)
                    .get();

                if (shareCodeDoc.exists) {
                  quizId = shareCodeDoc.data()?['quizId'] as String?;
                }

                // 2. Fallback: query quizzes directly by shareCode (old quizzes without shareCodes doc)
                if (quizId == null) {
                  final quizQuery = await FirebaseFirestore.instance
                      .collection('quizzes')
                      .where('shareCode', isEqualTo: code)
                      .limit(1)
                      .get();
                  if (quizQuery.docs.isNotEmpty) {
                    quizId = quizQuery.docs.first.id;
                  }
                }

                if (quizId != null) {
                  // Add current user to the quiz's sharedWith array
                  await FirebaseFirestore.instance
                      .collection('quizzes')
                      .doc(quizId)
                      .update({
                        'sharedWith': FieldValue.arrayUnion([user.uid])
                      });
                  
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz added!')));
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz not found. Check the code and try again.')));
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing quiz: $e')));
              }
            }, 
            child: const Text("Find Quiz")
          ),
        ],
      ),
    );
  }

  // ... (Keep your _buildCategoryItem, _buildSpeedDial, _buildExpandingButton, _showModeSelection, and _modeAction methods as they were)
  Widget _buildCategoryItem(String name, IconData icon) {
    final catColor = categoryColors[name] ?? AppColors.primary;
    final isSelected = _selectedCategory == name;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? catColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isSelected ? catColor : AppColors.textSecondary),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? catColor : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        setState(() => _selectedCategory = name);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSpeedDial() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildExpandingButton(icon: Icons.file_download_outlined, label: "Import Quiz", offset: 2, color: AppColors.accent, onTap: _showImportDialog),
          _buildExpandingButton(icon: Icons.edit_note, label: "Create New", offset: 1, color: AppColors.secondary, onTap: () => Navigator.pushNamed(context, '/creator')),
          FloatingActionButton(
            heroTag: "main_fab",
            backgroundColor: AppColors.primary,
            onPressed: _toggleMenu,
            child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandingButton({required IconData icon, required String label, required double offset, required Color color, required VoidCallback onTap}) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.8), end: Offset(0, -0.2 * offset)).animate(_controller),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                heroTag: null,
                backgroundColor: color,
                onPressed: () { _toggleMenu(); onTap(); },
                child: Icon(icon, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModeSelection(BuildContext context, Quiz quiz) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text("Start ${quiz.title}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Select a mode to begin", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _modeAction(context, "Normal", Icons.menu_book, AppColors.primary, QuizMode.normal, quiz),
                _modeAction(context, "Timed", Icons.timer, AppColors.warning, QuizMode.timed, quiz),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeAction(BuildContext context, String label, IconData icon, Color color, QuizMode mode, Quiz quiz) {
    return InkWell(
      onTap: () {
        context.read<QuizProvider>().startQuiz(mode, 30, quiz);
        Navigator.pop(context);
        Navigator.pushNamed(context, '/quiz');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}