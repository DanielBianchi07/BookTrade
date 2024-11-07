class UInfo {
  final String id;
  final String name;
  final String? address;
  final double customerRating;
  final String profileImageUrl;
  final String email;
  final String phone;
  final List<String>? favoriteGenres;

  UInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.customerRating = 0.0,
    this.profileImageUrl = '',
    this.favoriteGenres,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'customerRating':customerRating,
      'favoriteGenres':favoriteGenres,
      'name':name,
      'email':email,
      'phone':phone,
    };
  }

  factory UInfo.fromMap(Map<String, dynamic> map) {
    return UInfo(
      id: map['userId'],
      profileImageUrl: map['profileImageUrl'] ?? '',
      address: map['address'],
      customerRating: map['customerRating']?.toDouble() ?? 0.0,
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}