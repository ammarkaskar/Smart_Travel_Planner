import 'itinerary_item.dart';

class Trip {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<ItineraryItem> itinerary;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.itinerary,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      name: json['name'],
      destination: json['destination'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      itinerary: (json['itinerary'] as List?)
          ?.map((item) => ItineraryItem.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'itinerary': itinerary.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get duration => endDate.difference(startDate).inDays + 1;
}

