class UserInfo {
  final String name;
  final String address;
  final double customerRating;
  final String profileImageUrl;
  final String email;
  final String phone;

  UserInfo({
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
    this.customerRating = 0.0,
    this.profileImageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'profileImageUrl': profileImageUrl,
      'address': address,
      'customerRating':customerRating,
      'name':name,
      'email':email,
      'phone':phone,
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      profileImageUrl: map['profileImageUrl'] ?? '',
      address: map['adress'] ?? '',
      customerRating: map['customerRating']?.toDouble() ?? 0.0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}