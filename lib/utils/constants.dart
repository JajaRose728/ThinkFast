import 'package:flutter/material.dart';

enum QuizMode {
  normal,
  timed,
}

const List<String> quizCategories = [
  'Science',
  'History',
  'Tech',
  'Math',
  'Geography',
  'Sports',
  'Entertainment',
  'Literature',
  'Others',
];

// ── Cohesive Aesthetic Color Palette ──

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6366F1);      // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);  // Deep Indigo
  static const Color secondary = Color(0xFFEC4899);    // Pink
  static const Color accent = Color(0xFF06B6D4);       // Cyan
  static const Color success = Color(0xFF10B981);      // Emerald
  static const Color warning = Color(0xFFF59E0B);      // Amber
  static const Color error = Color(0xFFEF4444);        // Rose Red

  static const Color background = Color(0xFFF8F7FF);   // Soft Lavender White
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);  // Slate 800
  static const Color textSecondary = Color(0xFF6B7280); // Slate 500
  static const Color divider = Color(0xFFE5E7EB);      // Slate 200
}

// Category colors (soft pastel tints)
final Map<String, Color> categoryColors = {
  'All': AppColors.primary,
  'Science': const Color(0xFF0EA5E9),      // Sky Blue
  'History': const Color(0xFFF59E0B),      // Amber
  'Tech': const Color(0xFF8B5CF6),         // Violet
  'Math': const Color(0xFF10B981),         // Emerald
  'Geography': const Color(0xFF14B8A6),    // Teal
  'Sports': const Color(0xFFF97316),       // Orange
  'Entertainment': const Color(0xFFEC4899), // Pink
  'Literature': const Color(0xFFEF4444),   // Red
  'Others': const Color(0xFF64748B),       // Slate
};

// Option card colors for quiz screen
final List<Color> optionColors = [
  const Color(0xFF6366F1), // Indigo
  const Color(0xFFEC4899), // Pink
  const Color(0xFF06B6D4), // Cyan
  const Color(0xFFF59E0B), // Amber
  const Color(0xFF8B5CF6), // Violet
  const Color(0xFF10B981), // Emerald
];
