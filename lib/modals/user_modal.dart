class User {
  final String id;
  final String username;
  final String? email;
  final String accessToken;
  final String? firstName;
  final String? userType;
  final String? lastName;
  final String? phone;
  final String? refreshToken;

  User({
    required this.id,
    required this.username,
    this.email,
    required this.accessToken,
    this.firstName,
    this.userType,
    this.refreshToken,
    this.lastName,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final tokens = json['tokens'] ?? {};
    return User(
      id: userData['id']?.toString() ?? '',
      username: userData['username'] ?? '',
      email: userData['email'],
      accessToken: tokens['access'] ?? userData['access_token'] ?? '',
      refreshToken: tokens['refresh'] ?? userData['refresh_token'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      phone: userData['phone_number'],
      userType: userData['userType'],
    );
  }

  @override
  String toString() {
    return 'User{'
        'id: $id, '
        'username: $username, '
        'email: $email, '
        'accessToken: ${accessToken.isNotEmpty ? "****" : "empty"}, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'phone: $phone, '
        'userType: $userType}';
  }
}