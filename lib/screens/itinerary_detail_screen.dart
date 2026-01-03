import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';

class ItineraryDetailScreen extends StatelessWidget {
  final Trip trip;

  const ItineraryDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.destination,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(trip.startDate)} - ${DateFormat('MMM dd, yyyy').format(trip.endDate)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: ${trip.duration} ${trip.duration == 1 ? 'day' : 'days'}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Itinerary Items
            Text(
              'Itinerary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (trip.itinerary.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No itinerary items',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              )
            else
              ...trip.itinerary.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          '${item.order + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item.placeName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                item.formattedDate,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                item.time,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          if (item.notes != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.notes!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

