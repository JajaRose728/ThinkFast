import 'dart:math';

String generateQuizCode() {
  return Random().nextInt(999999).toString().padLeft(6, '0');
}