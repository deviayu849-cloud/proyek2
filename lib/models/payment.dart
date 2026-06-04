class Payment {
  final int id;
  final int invoiceId;
  final double amount;
  final String paymentMethod;
  final String referenceNumber;
  final String status;
  final String notes;
  final DateTime? submittedDate;
  final DateTime? approvedDate;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.status,
    required this.notes,
    required this.submittedDate,
    required this.approvedDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      invoiceId: int.tryParse(json['invoice_id'].toString()) ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      submittedDate: _parseDate(json['submitted_date']),
      approvedDate: _parseDate(json['approved_date']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
