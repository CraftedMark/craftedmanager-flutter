class User {
  final int id;
  final int peopleId;
  final String username;
  final String password;
  final String role;

  User({
    required this.id,
    required this.peopleId,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      peopleId: json['people_id'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'people_id': peopleId,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}
