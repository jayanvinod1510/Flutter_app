import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/frappe_auth_service.dart';
import 'appointment_screen.dart';
import 'doctors_screen.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  final String frappeUrl;
  final FrappeAuthService authService;

  const HomeScreen({
    super.key,
    required this.frappeUrl,
    required this.authService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1024;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.1),
                colorScheme.surface,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.authService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/background_pattern.svg',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  extended: screenWidth > 1200,
                  backgroundColor: Colors.white,
                  useIndicator: true,
                  indicatorColor: colorScheme.primaryContainer,
                  selectedIconTheme: IconThemeData(
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  selectedLabelTextStyle: TextStyle(
                    fontFamily: 'Ubuntu',
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    fontFamily: 'Ubuntu',
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  elevation: 1,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                      ),
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: const Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.calendar_month_outlined),
                      selectedIcon: const Icon(Icons.calendar_month),
                      label: const Text('Appointments'),
                    ),
                  ],
                ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // Dashboard Tab
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Welcome Section
                            Card(
                              elevation: 0,
                              color: colorScheme.surface.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 88,
                                            height: 88,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Icon(
                                            Icons.medical_services_rounded,
                                            size: 56,
                                            color: colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Welcome to Medical Appointments',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Manage your appointments efficiently',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Quick Actions Grid
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: isWideScreen ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _DashboardCard(
                                  icon: Icons.calendar_today_outlined,
                                  title: 'Schedule',
                                  subtitle: 'Book new appointments',
                                  color: const Color(0xFF4F46E5),
                                  onTap: () {
                                    setState(() => _selectedIndex = 1);
                                  },
                                ),
                                _DashboardCard(
                                  icon: Icons.people_outline,
                                  title: 'Doctors',
                                  subtitle: 'View available doctors',
                                  color: const Color(0xFF0EA5E9),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DoctorsScreen(
                                          baseUrl: widget.frappeUrl,
                                          authService: widget.authService,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _DashboardCard(
                                  icon: Icons.open_in_new,
                                  title: 'Frappe Desk',
                                  subtitle: 'Open admin dashboard',
                                  color: const Color(0xFF6366F1),
                                  onTap: () async {
                                    final url = Uri.parse('${widget.frappeUrl}/app');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Appointments Tab
                    AppointmentScreen(
                      baseUrl: widget.frappeUrl,
                      authService: widget.authService,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen ? NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
        ],
      ) : null,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surface.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.12),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String trend;
  final bool trendUp;
  final Color color;

  const _StatisticsCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.12),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trendUp ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: trendUp ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: trendUp ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 