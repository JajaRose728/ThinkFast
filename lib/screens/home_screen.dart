import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Optimization: const constructor [cite: 175, 179]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text('ThinkFast'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Your Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Normal Mode Card
            _buildModeCard(
              context,
              title: 'Normal Challenge',
              subtitle: 'No timers, just pure learning.',
              icon: Icons.menu_book,
              color: Colors.blue,
              onTap: () {
                // Initialize Normal Mode logic [cite: 309]
                context.read<QuizProvider>().startQuiz(QuizMode.normal, 0);
                Navigator.pushNamed(context, '/quiz');
              },
            ),
            
            const SizedBox(height: 20),
            
            // Timed Mode Card
            _buildModeCard(
              context,
              title: 'Rapid Challenge',
              subtitle: 'Beat the clock! 30 seconds per quiz.',
              icon: Icons.timer,
              color: Colors.orange,
              onTap: () {
                // Initialize Timed Mode logic [cite: 309]
                context.read<QuizProvider>().startQuiz(QuizMode.timed, 30);
                Navigator.pushNamed(context, '/quiz');
              },
            ),
            
            const Spacer(),
            
            // Quiz Creator Section
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/creator'),
              icon: const Icon(Icons.add),
              label: const Text('Create Your Own Quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to keep UI code clean and organized [cite: 213, 277]
  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}