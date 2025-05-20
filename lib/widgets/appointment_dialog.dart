import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import '../models/appointment.dart';

class AppointmentDialog extends StatefulWidget {
  final Appointment? appointment;
  final List<Map<String, String>> doctors;
  final Function(Appointment appointment) onSave;
  final String? preselectedDoctorId;

  const AppointmentDialog({
    super.key,
    this.appointment,
    required this.doctors,
    required this.onSave,
    this.preselectedDoctorId,
  });

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _selectedDoctor = widget.appointment!.doctor;
      _selectedDate = widget.appointment!.date;
      _selectedTime = TimeOfDay(
        hour: widget.appointment!.time.hour,
        minute: widget.appointment!.time.minute,
      );
      _reasonController.text = widget.appointment!.reason;
    } else if (widget.preselectedDoctorId != null) {
      _selectedDoctor = widget.preselectedDoctorId;
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

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 1024;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isWideScreen ? 500 : double.infinity,
        constraints: BoxConstraints(
          maxWidth: isWideScreen ? 500 : size.width - 48,
          maxHeight: size.height - 80,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Icon with circles
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.appointment != null
                        ? 'Edit Appointment'
                        : 'New Appointment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.preselectedDoctorId == null) ...[
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Doctor',
                            prefixIcon: Icon(Icons.person),
                          ),
                          value: _selectedDoctor,
                          items: widget.doctors
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
                      ],
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
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Select Date',
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime != null
                                    ? _formatTimeOfDay(_selectedTime!)
                                    : 'Select Time',
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedDate != null &&
                          _selectedTime != null) {
                        final dateTime = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        );

                        TimeOfDay timeOfDay = TimeOfDay(
                            hour: dateTime.hour, minute: dateTime.minute);

                        final appointment = Appointment(
                          name: widget.appointment?.name,
                          doctor:
                              _selectedDoctor ?? widget.preselectedDoctorId!,
                          patient_id: getCookie('user_id'),
                          date: _selectedDate!,
                          time: timeOfDay,
                          reason: _reasonController.text,
                        );

                        widget.onSave(appointment);
                      }
                    },
                    child: Text(
                      widget.appointment != null ? 'Update' : 'Schedule',
                    ),
                  ),
                ],
              ),
            ),
          ],
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
