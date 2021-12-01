class Quiz {
  String name;
  String topic;
  List<Question> questions;
  String user;

  Quiz(this.name, this.topic, this.questions, this.user);

  // Returns sample quizzes
  static List<Quiz> generateData() {
    return [
      Quiz('Math q', 'Math', [], 'Admin'),
      Quiz('Sci q', 'Science', [], 'Admin'),
      Quiz('Eng q', 'Literature', [], 'Admin'),
    ];
  }
}

class Question {
  String question;
  List<Option> options;

  Question(this.question, this.options);
}

class Option {
  String option;
  bool isAnswer;

  Option(this.option, this.isAnswer);
}
