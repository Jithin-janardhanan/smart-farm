class Farmer {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String aadharNumber;
  final String houseName;
  final String village;
  final String district;
  final String state;
  final String pincode;

  Farmer({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.aadharNumber,
    required this.houseName,
    required this.village,
    required this.district,
    required this.state,
    required this.pincode,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      aadharNumber: json['aadhar_number'],
      houseName: json['house_name'],
      village: json['village'],
      district: json['district'],
      state: json['state'],
      pincode: json['pincode'],
    );
  }
}
