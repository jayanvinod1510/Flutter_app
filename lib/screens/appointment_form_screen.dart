import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/frappe_auth_service.dart';

class AppointmentFormScreen extends StatefulWidget {
  final String baseUrl;
  final FrappeAuthService authService;
  final Appointment? appointment;

  const AppointmentFormScreen({
    super.key,
    required this.baseUrl,
    required this.authService,
    this.appointment,
  });

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDoctor;
  List<Map<String, String>> _doctors = [];
  bool _isLoading = false;
  late final AppointmentService _appointmentService;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService(
      baseUrl: widget.baseUrl,
      authService: widget.authService,
    );
    _loadDoctors();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.appointment != null) {
      _selectedDoctor = widget.appointment!.doctor;
      _selectedDate = widget.appointment!.date;
      _selectedTime = TimeOfDay(
        hour: widget.appointment!.time.hour,
        minute: widget.appointment!.time.minute,
      );
      _reasonController.text = widget.appointment!.reason;
    }
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _appointmentService.getDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load doctors'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String getCookie(String name) {
    final cookies = html.document.cookie?.split('; ') ?? [];
    for (var cookie in cookies) {
      final parts = cookie.split('=');
      if (parts.length == 2 && parts[0] == name) {
        return Uri.decodeComponent(parts[1]);
      }
    }
    return "";
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        _selectedDoctor != null) {
      setState(() => _isLoading = true);

      try {
        final dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        TimeOfDay timeOfDay =
            TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);

        final appointment = Appointment(
          name: widget.appointment?.name,
          doctor: _selectedDoctor!,
          patient_id: getCookie('user_id'),
          date: _selectedDate!,
          time: timeOfDay,
          reason: _reasonController.text,
        );

        if (widget.appointment != null) {
          await _appointmentService.updateAppointment(appointment);
        } else {
          await _appointmentService.addAppointment(appointment);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to save appointment'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appointment != null ? 'Edit Appointment' : 'New Appointment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _doctors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Doctor Dropdown
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Doctor',
                            prefixIcon: Icon(Icons.person),
                          ),
                          value: _selectedDoctor,
                          items: _doctors
                              .map((doctor) => DropdownMenuItem(
                                    value: doctor['id'],
                                    child: Text(doctor['name']!),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDoctor = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a doctor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Date Picker
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select Date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Time Picker
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Select Time',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Reason Field
                        TextFormField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            labelText: 'Reason for Visit',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the reason for your visit';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: _isLoading ? null : _submitForm,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.appointment != null
                                      ? 'Update'
                                      : 'Schedule',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
