import 'service_item.dart';
import 'technician.dart';

class Booking {
  final int id;
  final String status;
  final DateTime? scheduledDate;
  final String serviceLocation;
  final String notes;
  final String completionNotes;
  final String cancellationReason;
  final double totalPrice;
  final ServiceItem? service;
  final Technician? technician;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? invoice;
  final Map<String, dynamic>? rating;

  Booking({
    required this.id,
    required this.status,
    required this.scheduledDate,
    required this.serviceLocation,
    required this.notes,
    required this.completionNotes,
    required this.cancellationReason,
    required this.totalPrice,
    required this.service,
    required this.technician,
    required this.customer,
    required this.invoice,
    required this.rating,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      status: json['status']?.toString() ?? 'pending',
      scheduledDate: _parseDate(json['scheduled_date']),
      serviceLocation: json['service_location']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      completionNotes: json['completion_notes']?.toString() ?? '',
      cancellationReason: json['cancellation_reason']?.toString() ?? '',
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      service: json['service'] is Map<String, dynamic>
          ? ServiceItem.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      technician: json['technician'] is Map<String, dynamic>
          ? Technician.fromJson(json['technician'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? json['customer'] as Map<String, dynamic>
          : null,
      invoice: json['invoice'] is Map<String, dynamic>
          ? json['invoice'] as Map<String, dynamic>
          : null,
      rating: json['rating'] is Map<String, dynamic>
          ? json['rating'] as Map<String, dynamic>
          : null,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool get isActive =>
      status == 'pending' ||
      status == 'confirmed' ||
      status == 'en_route' ||
      status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get hasRating => rating != null;
}
