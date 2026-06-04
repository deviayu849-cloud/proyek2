class Technician {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String specialization;
  final String status;
  final double averageRating;

  Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.specialization,
    required this.status,
    required this.averageRating,
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
    );
  }
}
