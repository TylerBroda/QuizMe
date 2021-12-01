class Quiz {
  String name;
  String topic;
  List<Question> questions;

  Quiz(this.name, this.topic, this.questions);

  // Returns sample quizzes
  static List<Quiz> generateData() {
    return [
      Quiz('Math q', 'Math', []),
      Quiz('Sci q', 'Science', []),
      Quiz('Eng q', 'Literature', []),
    ];
  }
}

class Question {
  String question;
  int correctOptionIndex;
  List<String> options;

  Question(this.question, this.correctOptionIndex, this.options);
}
