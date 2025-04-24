class User {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String username;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'] ?? '',
      lastName: json['last_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phone,
    };
  }
}