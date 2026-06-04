import 'package:flutter/material.dart';

import '../models/service_item.dart';
import '../models/technician.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';

class OrderPage extends StatefulWidget {
  final VoidCallback? onCreated;

  const OrderPage({super.key, this.onCreated});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _notesController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<ServiceItem> _services = [];
  List<Technician> _technicians = [];
  ServiceItem? _selectedService;
  Technician? _selectedTechnician;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getServices(),
        ApiService.getTechnicians(),
      ]);
      if (!mounted) return;
      setState(() {
        _services = results[0] as List<ServiceItem>;
        _technicians = results[1] as List<Technician>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 45)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (_selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      _showError('Pilih layanan, tanggal, dan waktu terlebih dahulu.');
      return;
    }

    final scheduledDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (!scheduledDate.isAfter(DateTime.now())) {
      _showError('Jadwal harus lebih dari waktu sekarang.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.createBooking(
        serviceId: _selectedService!.id,
        technicianId: _selectedTechnician?.id,
        scheduledDate: scheduledDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _selectedService = null;
        _selectedTechnician = null;
        _selectedDate = null;
        _selectedTime = null;
        _notesController.clear();
      });
      widget.onCreated?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Booking berhasil dibuat.'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pilih layanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_services.isEmpty)
            const _EmptyText('Belum ada layanan tersedia.')
          else
            ..._services.map(_serviceCard),
          const SizedBox(height: 20),
          const Text('Pilih teknisi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<Technician?>(
            initialValue: _selectedTechnician,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Teknisi'),
            items: [
              const DropdownMenuItem<Technician?>(
                  value: null, child: Text('Otomatis pilih teknisi tersedia')),
              ..._technicians.map(
                (technician) => DropdownMenuItem<Technician?>(
                  value: technician,
                  child: Text('${technician.name} (${technician.status})'),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedTechnician = value),
          ),
          const SizedBox(height: 20),
          const Text('Jadwal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Tanggal'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(_selectedTime == null
                      ? 'Waktu'
                      : _selectedTime!.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Catatan tambahan',
              hintText: 'Contoh: AC di lantai 2, parkir tersedia',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.check_circle),
              label: Text(_isSubmitting ? 'Mengirim...' : 'Buat Booking'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(ServiceItem service) {
    final selected = _selectedService?.id == service.id;
    return Card(
      color: selected ? const Color(0xFFE3F2FD) : null,
      child: ListTile(
        leading: const Icon(Icons.ac_unit),
        title: Text(service.name),
        subtitle: Text(
            '${service.description}\nDurasi ${service.durationMinutes} menit'),
        trailing: Text(formatRupiah(service.price),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        selected: selected,
        onTap: () => setState(() => _selectedService = service),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
          child: Text(text, style: TextStyle(color: Colors.grey.shade600))),
    );
  }
}
