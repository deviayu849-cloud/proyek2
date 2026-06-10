class Technician {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String specialization;
  final String status;
  final double averageRating;
  final int ratingCount;
  final String description;
  final int yearsExperience;
  final String photoUrl;

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.specialization,
    required this.status,
    required this.averageRating,
    required this.ratingCount,
    required this.description,
    required this.yearsExperience,
    required this.photoUrl,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      averageRating: double.tryParse(json['average_rating'].toString()) ?? 0,
      ratingCount: int.tryParse(json['rating_count'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      yearsExperience: int.tryParse(json['years_experience'].toString()) ?? 0,
      photoUrl: json['photo_url']?.toString() ?? '',
    );
  }
}
