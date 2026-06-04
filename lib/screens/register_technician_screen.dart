import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import 'technician_dashboard.dart';

class RegisterTechnicianScreen extends StatefulWidget {
  const RegisterTechnicianScreen({super.key});

  @override
  State<RegisterTechnicianScreen> createState() =>
      _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState extends State<RegisterTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specializationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.registerTechnician(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        specialization: _specializationController.text,
      );

      if (!mounted) return;
      _goToDashboard(result.user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToDashboard(User user) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => TechnicianDashboard(initialUser: user)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Teknisi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameController, 'Nama lengkap'),
              const SizedBox(height: 14),
              _field(_emailController, 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator),
              const SizedBox(height: 14),
              _field(_phoneController, 'Nomor telepon',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _field(_addressController, 'Alamat', maxLines: 3),
              const SizedBox(height: 14),
              _field(_specializationController, 'Spesialisasi',
                  required: false),
              const SizedBox(height: 14),
              _field(_passwordController, 'Password',
                  obscureText: true, validator: _passwordValidator),
              const SizedBox(height: 14),
              _field(
                _confirmPasswordController,
                'Konfirmasi password',
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Konfirmasi password tidak sama.';
                  }
                  return _passwordValidator(value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Daftar sebagai teknisi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return '$label wajib diisi.';
            }
            return null;
          },
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!value.contains('@')) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi.';
    if (value.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }
}
