class Invoice {
  final int id;
  final String invoiceNumber;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime? dueDate;
  final int bookingId;
  final Map<String, dynamic>? booking;
  final double approvedAmount;
  final double remainingAmount;
  final double pendingAmount;
  final bool hasPendingPayment;
  final Map<String, dynamic>? latestPayment;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.dueDate,
    required this.bookingId,
    required this.booking,
    required this.approvedAmount,
    required this.remainingAmount,
    required this.pendingAmount,
    required this.hasPendingPayment,
    required this.latestPayment,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      tax: double.tryParse(json['tax'].toString()) ?? 0,
      total: double.tryParse(json['total'].toString()) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      dueDate: json['due_date'] == null
          ? null
          : DateTime.tryParse(json['due_date'].toString()),
      bookingId: int.tryParse(json['booking_id'].toString()) ?? 0,
      booking: json['booking'] is Map<String, dynamic>
          ? json['booking'] as Map<String, dynamic>
          : null,
      approvedAmount: double.tryParse(json['approved_amount'].toString()) ?? 0,
      remainingAmount:
          double.tryParse(json['remaining_amount'].toString()) ?? 0,
      pendingAmount: double.tryParse(json['pending_amount'].toString()) ?? 0,
      hasPendingPayment: json['has_pending_payment'] == true,
      latestPayment: json['latest_payment'] is Map<String, dynamic>
          ? json['latest_payment'] as Map<String, dynamic>
          : null,
    );
  }

  bool get isPaid => status == 'paid';
}
