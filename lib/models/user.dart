class User {
  final String name;
  final String email;
  final String password; // Для лабораторної — зберігаємо plain (не для продакшну)

  const User({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );
}
