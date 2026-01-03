import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import 'itinerary_detail_screen.dart';

class SavedTripsScreen extends StatelessWidget {
  const SavedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Trips'),
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripProvider.trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved trips yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first itinerary to get started',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tripProvider.trips.length,
            itemBuilder: (context, index) {
              final trip = tripProvider.trips[index];
              return _TripCard(
                trip: trip,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItineraryDetailScreen(trip: trip),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteDialog(context, tripProvider, trip);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TripProvider tripProvider, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete "${trip.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              tripProvider.deleteTrip(trip.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripCard({
    required this.trip,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              trip.destination,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd, yyyy').format(trip.endDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.duration} ${trip.duration == 1 ? 'day' : 'days'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.list, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.itinerary.length} ${trip.itinerary.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

