class User {
  final String token;
  final int userId;
  final int farmerId;

  User({
    required this.token,
    required this.userId,
    required this.farmerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      userId: json['user_id'],
      farmerId: json['farmer_id'],
    );
  }
}
