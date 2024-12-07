class Person {
  final String name;
  final String studentNumber;
  final String email;
  final String branch;

  Person({
    required this.name,
    required this.studentNumber,
    required this.email,
    required this.branch,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      studentNumber: json['student_number'],
      email: json['email'],
      branch: json['branch'],
    );
  }
}
