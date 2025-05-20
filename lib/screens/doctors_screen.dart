import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../services/frappe_auth_service.dart';
import '../services/appointment_service.dart';
import '../widgets/appointment_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorsScreen extends StatefulWidget {
  final String baseUrl;
  final FrappeAuthService authService;

  const DoctorsScreen({
    super.key,
    required this.baseUrl,
    required this.authService,
  });

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  bool _isLoading = true;
  List<Doctor> _doctors = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _filteredDoctors = [];
  late final AppointmentService _appointmentService;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService(
      baseUrl: widget.baseUrl,
      authService: widget.authService,
    );
    _loadDoctors();
    _searchController.addListener(_filterDoctors);
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        return doctor.name.toLowerCase().contains(query) ||
            doctor.specialization.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.get(
        Uri.parse(
            '${widget.baseUrl}/api/resource/Doctor?fields=["name","doctor_name","specialization","qualification"]'),
        headers: {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Doctor> doctors = (data['data'] as List)
            .map((json) => Doctor.fromJson(json))
            .toList();

        setState(() {
          _doctors = doctors;
          _filteredDoctors = doctors;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      debugPrint('Error loading doctors: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load doctors. Please try again.';
      });
    }
  }

  Future<void> _showAppointmentDialog(Doctor doctor) async {
    final doctorsList = [
      {
        'id': doctor.id,
        'name': doctor.name,
      }
    ];

    await showDialog<Appointment>(
      context: context,
      builder: (context) => AppointmentDialog(
        doctors: doctorsList,
        preselectedDoctorId: doctor.id,
        onSave: (appointment) async {
          try {
            await _appointmentService.addAppointment(appointment);
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Appointment scheduled successfully!'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Failed to schedule appointment'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Doctors',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _loadDoctors,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredDoctors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: colorScheme.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No doctors found',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _filteredDoctors[index];
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _showAppointmentDialog(doctor),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Doctor Avatar
                                        Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              doctor.name.characters.first,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Doctor Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doctor.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                doctor.specialization,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 16),
                                                  Icon(
                                                    Icons.work_outline,
                                                    size: 16,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${doctor.qualification}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Book Appointment Button
                                        FilledButton.icon(
                                          onPressed: () =>
                                              _showAppointmentDialog(doctor),
                                          icon: const Icon(Icons.calendar_today,
                                              size: 18),
                                          label: const Text('Book'),
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
