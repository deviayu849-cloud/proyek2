import 'package:intl/intl.dart';

final _rupiahFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

String formatRupiah(num value) => _rupiahFormat.format(value);

String formatDate(DateTime? value) {
  if (value == null) return '-';
  return _dateFormat.format(value.toLocal());
}

String bookingStatusLabel(String status) {
  return switch (status) {
    'pending' => 'Menunggu',
    'confirmed' => 'Dikonfirmasi',
    'en_route' => 'Menuju lokasi',
    'in_progress' => 'Sedang dikerjakan',
    'completed' => 'Selesai',
    'cancelled' => 'Dibatalkan',
    _ => status,
  };
}

String invoiceStatusLabel(String status) {
  return switch (status) {
    'draft' => 'Draft',
    'issued' => 'Belum dibayar',
    'paid' => 'Lunas',
    'overdue' => 'Jatuh tempo',
    _ => status,
  };
}

String paymentStatusLabel(String status) {
  return switch (status) {
    'pending_approval' => 'Menunggu verifikasi',
    'approved' => 'Disetujui',
    'rejected' => 'Ditolak',
    _ => status,
  };
}

String paymentMethodLabel(String method) {
  return switch (method) {
    'cash' => 'Tunai',
    'bank_transfer' => 'Transfer Bank',
    'check' => 'Cek',
    _ => method,
  };
}
