import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/frappe_auth_service.dart';
import '../widgets/appointment_dialog.dart';

class AppointmentScreen extends StatefulWidget {
  final String baseUrl;
  final FrappeAuthService authService;

  const AppointmentScreen({
    super.key,
    required this.baseUrl,
    required this.authService,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  String? _selectedDoctor;
  List<Map<String, String>> _doctors = [];

  late final AppointmentService _appointmentService;
  List<Appointment> _appointments = [];
  Appointment? _editingAppointment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService(
      baseUrl: widget.baseUrl,
      authService: widget.authService,
    );
    _loadDoctors();
    _loadAppointments();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _appointmentService.getDoctors();
      setState(() {
        _doctors = doctors;
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
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load appointments123'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _reasonController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedDoctor = null;
      _editingAppointment = null;
    });
  }

  void _editAppointment(Appointment appointment) {
    DateTime dateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );
    setState(() {
      _editingAppointment = appointment;
      _selectedDoctor = appointment.doctor;
      _selectedDate = appointment.date;
      _selectedTime = dateTime;
      _reasonController.text = appointment.reason;
    });
  }

  Future<void> _deleteAppointment(String id) async {
    try {
      await _appointmentService.deleteAppointment(id);
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Appointment deleted successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete appointment'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showAppointmentDialog([Appointment? appointment]) async {
    final result = await showDialog<Appointment>(
      context: context,
      builder: (context) => AppointmentDialog(
        appointment: appointment,
        doctors: _doctors,
        onSave: (appointment) async {
          try {
            if (appointment.name != null) {
              await _appointmentService.updateAppointment(appointment);
            } else {
              await _appointmentService.addAppointment(appointment);
            }
            if (mounted) {
              Navigator.pop(context, appointment);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appointment.name != null
                        ? 'Appointment updated successfully!'
                        : 'Appointment scheduled successfully!',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Failed to save appointment'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );

    if (result != null) {
      await _loadAppointments();
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
      initialTime: TimeOfDay.fromDateTime(_selectedTime ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1024;

    if (isWideScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    'Appointments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _showAppointmentDialog(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('New Appointment'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List View
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Appointments Yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first appointment to get started',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: () => _showAppointmentDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('New Appointment'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _appointments.length,
                          padding: const EdgeInsets.all(24),
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    _showAppointmentDialog(appointment),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                appointment.doctor[0]
                                                    .toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Dr. ${appointment.doctor_name}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  appointment.reason,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .primaryContainer
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${appointment.time.hour.toString().padLeft(2, '0')}:${appointment.time.minute.toString().padLeft(2, '0')}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () =>
                                                    _showAppointmentDialog(
                                                        appointment),
                                                icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 18),
                                                label: const Text('Edit'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      colorScheme.primary,
                                                  side: BorderSide(
                                                      color: colorScheme.primary
                                                          .withOpacity(0.5)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton.icon(
                                                onPressed: () =>
                                                    _showDeleteDialog(
                                                        appointment),
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 18),
                                                label: const Text('Delete'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      colorScheme.error,
                                                  side: BorderSide(
                                                      color: colorScheme.error
                                                          .withOpacity(0.5)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      );
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Appointments'),
                Tab(text: 'New Appointment'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Appointments List Tab
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 64,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No appointments yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first appointment',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  appointment.name ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} at ${appointment.time}\nPurpose: ${appointment.reason}',
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showAppointmentDialog(appointment);
                                        DefaultTabController.of(context)
                                            .animateTo(1);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Delete Appointment'),
                                          content: const Text(
                                            'Are you sure you want to delete this appointment?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteAppointment(
                                                    appointment.name!);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

              // Appointment Form Tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _editingAppointment != null
                              ? 'Edit Appointment'
                              : 'Schedule Appointment',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 24),
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
                            child: Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select Date',
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
                            child: Text(
                              _selectedTime != null
                                  ? _selectedTime.toString()
                                  : 'Select Time',
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            if (_editingAppointment != null) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _resetForm,
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _showAppointmentDialog,
                                icon: const Icon(Icons.save),
                                label: Text(
                                  _editingAppointment != null
                                      ? 'Update Appointment'
                                      : 'Schedule Appointment',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDeleteDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text(
          'Are you sure you want to delete this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointment.name!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
