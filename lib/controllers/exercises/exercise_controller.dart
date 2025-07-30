import 'package:flutter/material.dart';

abstract class ExerciseController {
  // Common state
  bool isCompleted = false;
  bool isCorrect = false;
  String? userAnswer;
  int score = 0;
  int attempts = 0;
  List<String> wrongAnswers = [];

  // Abstract methods that must be implemented by each exercise type
  bool checkAnswer(dynamic userInput);
  void reset();
  Map<String, dynamic> getState();
  void setState(Map<String, dynamic> state);

  // Common methods
  void markCompleted(int score) {
    this.score = score;
    isCompleted = true;
    isCorrect = true;
  }

  void markWrong(dynamic wrongAnswer) {
    isCompleted = false;
    isCorrect = false;
    attempts++;
    if (wrongAnswer != null) {
      wrongAnswers.add(wrongAnswer.toString());
    }
  }

  bool get isAnswered => userAnswer != null || attempts > 0;
} 