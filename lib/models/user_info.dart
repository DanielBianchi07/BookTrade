class UInfo {
  final String id;
  final String? profileImageUrl;
  final String? address;
  final double? customerRating;
  final String name;
  final String email;
  final String phone;

  UInfo({
    this.profileImageUrl,
    this.address,
    this.customerRating,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileImageUrl': profileImageUrl,
      'address': address,
      'customerRating': customerRating,
      'userId': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory UInfo.fromMap(Map<String, dynamic> map) {
    return UInfo(
      id: map['userId'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      address: map['address'] ?? '',
      customerRating: map['customerRating']?.toDouble() ?? 0.0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}