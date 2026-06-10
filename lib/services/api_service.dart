import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/booking.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/service_item.dart';
import '../models/technician.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AuthResult {
  final User user;
  final String token;

  AuthResult({required this.user, required this.token});
}

class ApiService {
  static Uri _uri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw ApiException('Sesi login tidak ditemukan. Silakan login ulang.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveSession(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', user.role);
    await prefs.setString('name', user.name);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('name');
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw ApiException(
      'Format response server tidak dikenali.',
      response.statusCode,
    );
  }

  static void _throwIfNeeded(
    http.Response response,
    Map<String, dynamic> data,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final message = data['message']?.toString();
    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        throw ApiException(first.first.toString(), response.statusCode);
      }
    }

    throw ApiException(
      message ?? 'Request gagal (${response.statusCode}).',
      response.statusCode,
    );
  }

  static AuthResult _authResult(http.Response response) {
    final data = _decode(response);
    _throwIfNeeded(response, data);

    final token = (data['token'] ?? data['access_token'])?.toString();
    final userData = data['user'];

    if (token == null || token.isEmpty || userData is! Map<String, dynamic>) {
      throw ApiException('Response login tidak lengkap.', response.statusCode);
    }

    return AuthResult(user: User.fromJson(userData), token: token);
  }

  static Future<AuthResult> login(String email, String password) async {
    final response = await http.post(
      _uri('/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final result = _authResult(response);
    await saveSession(result.user, result.token);
    return result;
  }

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String address,
  }) async {
    final response = await http.post(
      _uri('/register'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone.trim(),
        'address': address.trim(),
      }),
    );

    final result = _authResult(response);
    await saveSession(result.user, result.token);
    return result;
  }

  static Future<AuthResult> registerTechnician({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String address,
    required String specialization,
  }) async {
    final response = await http.post(
      _uri('/register-provider'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone.trim(),
        'address': address.trim(),
        'specialization': specialization.trim(),
      }),
    );

    final result = _authResult(response);
    await saveSession(result.user, result.token);
    return result;
  }

  static Future<AuthResult> googleLoginMobile(
    String email,
    String name,
    String idToken,
  ) async {
    final response = await http.post(
      _uri('/google-login-mobile'),
      headers: await _headers(),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'id_token': idToken,
      }),
    );

    final result = _authResult(response);
    await saveSession(result.user, result.token);
    return result;
  }

  static Future<User> getProfile() async {
    final response = await http.get(
      _uri('/profile'),
      headers: await _headers(auth: true),
    );
    final data = _decode(response);
    _throwIfNeeded(response, data);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  static Future<User> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
    String? specialization,
  }) async {
    final response = await http.put(
      _uri('/profile'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        if (city != null) 'city': city.trim(),
        if (postalCode != null) 'postal_code': postalCode.trim(),
        if (specialization != null) 'specialization': specialization.trim(),
      }),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = await getToken();
    if (token != null) await saveSession(user, token);
    return user;
  }

  static Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await http.post(
      _uri('/change-password'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      }),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
  }

  static Future<void> logout() async {
    try {
      await http.post(_uri('/logout'), headers: await _headers(auth: true));
    } finally {
      await clearSession();
    }
  }

  static Future<List<ServiceItem>> getServices() async {
    final response = await http.get(
      _uri('/services'),
      headers: await _headers(auth: true),
    );
    final data = _decode(response);
    _throwIfNeeded(response, data);
    return ((data['services'] as List?) ?? [])
        .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Technician>> getTechnicians() async {
    final response = await http.get(
      _uri('/technicians'),
      headers: await _headers(auth: true),
    );
    final data = _decode(response);
    _throwIfNeeded(response, data);
    return ((data['technicians'] as List?) ?? [])
        .map((item) => Technician.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Booking>> getBookings() async {
    final response = await http.get(
      _uri('/bookings'),
      headers: await _headers(auth: true),
    );
    final data = _decode(response);
    _throwIfNeeded(response, data);
    return ((data['bookings'] as List?) ?? [])
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Booking> createBooking({
    required int serviceId,
    int? technicianId,
    required DateTime scheduledDate,
    required String serviceLocation,
    String? notes,
  }) async {
    final response = await http.post(
      _uri('/bookings'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'service_id': serviceId,
        if (technicianId != null) 'technician_id': technicianId,
        'scheduled_date': scheduledDate.toIso8601String(),
        'service_location': serviceLocation.trim(),
        'notes': notes,
      }),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  static Future<Booking> updateBookingStatus(
    int bookingId,
    String status, {
    String? notes,
  }) async {
    final response = await http.put(
      _uri('/bookings/$bookingId/status'),
      headers: await _headers(auth: true),
      body: jsonEncode({'status': status, if (notes != null) 'notes': notes}),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }

  static Future<List<Invoice>> getInvoices() async {
    final response = await http.get(
      _uri('/invoices'),
      headers: await _headers(auth: true),
    );
    final data = _decode(response);
    _throwIfNeeded(response, data);
    return ((data['invoices'] as List?) ?? [])
        .map((item) => Invoice.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Payment>> getInvoicePayments(int invoiceId) async {
    final response = await http.get(
      _uri('/invoices/$invoiceId/payments'),
      headers: await _headers(auth: true),
    );
    final data = _decode(response);
    _throwIfNeeded(response, data);
    return ((data['payments'] as List?) ?? [])
        .map((item) => Payment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Payment> submitPayment({
    required int invoiceId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? paymentProofPath,
    String? notes,
  }) async {
    final headers = await _headers(auth: true);
    headers.remove('Content-Type');

    final request = http.MultipartRequest(
      'POST',
      _uri('/invoices/$invoiceId/payments'),
    );
    request.headers.addAll(headers);
    request.fields['amount'] = amount.toString();
    request.fields['payment_method'] = paymentMethod;
    if (referenceNumber != null && referenceNumber.trim().isNotEmpty) {
      request.fields['reference_number'] = referenceNumber.trim();
    }
    if (notes != null && notes.trim().isNotEmpty) {
      request.fields['notes'] = notes.trim();
    }
    if (paymentProofPath != null && paymentProofPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('payment_proof', paymentProofPath),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = _decode(response);
    _throwIfNeeded(response, data);
    return Payment.fromJson(data['payment'] as Map<String, dynamic>);
  }

  static Future<Payment> approvePayment(int paymentId, {String? notes}) async {
    final response = await http.post(
      _uri('/payments/$paymentId/approve'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      }),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
    return Payment.fromJson(data['payment'] as Map<String, dynamic>);
  }

  static Future<Payment> rejectPayment(
    int paymentId, {
    required String reason,
  }) async {
    final response = await http.post(
      _uri('/payments/$paymentId/reject'),
      headers: await _headers(auth: true),
      body: jsonEncode({'reason': reason.trim()}),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
    return Payment.fromJson(data['payment'] as Map<String, dynamic>);
  }

  static Future<Booking> submitRating({
    required int bookingId,
    required int rating,
    required String review,
  }) async {
    final response = await http.post(
      _uri('/bookings/$bookingId/rating'),
      headers: await _headers(auth: true),
      body: jsonEncode({'rating': rating, 'review': review.trim()}),
    );

    final data = _decode(response);
    _throwIfNeeded(response, data);
    return Booking.fromJson(data['booking'] as Map<String, dynamic>);
  }
}
