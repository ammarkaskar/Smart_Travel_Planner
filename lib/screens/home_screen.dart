import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'place_list_screen.dart';
import 'itinerary_screen.dart';
import 'saved_trips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const PlaceListScreen(),
    const SavedTripsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Travel Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outlined),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userData?['name'] ?? 'User';

    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $userName!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plan your next adventure with ease',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.explore,
                  title: 'Explore Places',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PlaceListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: Icons.calendar_today,
                  title: 'Create Itinerary',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ItineraryScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.bookmark,
                  title: 'Saved Trips',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SavedTripsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: Icons.info_outline,
                  title: 'About',
                  color: Colors.purple,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Features Section
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          const _FeatureItem(
            icon: Icons.location_on,
            title: 'Discover Destinations',
            description: 'Find amazing tourist places around the world',
          ),
          const _FeatureItem(
            icon: Icons.wb_sunny,
            title: 'Weather Information',
            description: 'Get current weather details for your destination',
          ),
          const _FeatureItem(
            icon: Icons.calendar_view_day,
            title: 'Plan Your Trip',
            description: 'Create detailed itineraries for your travels',
          ),
          const _FeatureItem(
            icon: Icons.save,
            title: 'Save & Access Offline',
            description: 'Save your trips and access them without internet',
          ),
          const SizedBox(height: 16), // Add bottom padding
        ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Smart Travel Planner'),
        content: const Text(
          'Smart Travel Planner is a Flutter-based mobile application designed to help users plan their trips easily. '
          'It provides information about tourist destinations, weather details, and itinerary planning.\n\n'
          'Features:\n'
          '• Destination discovery\n'
          '• Weather information\n'
          '• Itinerary planning\n'
          '• Offline access\n\n'
          'This is a college-level project demonstrating Flutter development and API integration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
