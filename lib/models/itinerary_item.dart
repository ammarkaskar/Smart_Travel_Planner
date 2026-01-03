import 'package:intl/intl.dart';

class ItineraryItem {
  final String id;
  final String placeId;
  final String placeName;
  final DateTime date;
  final String time;
  final String? notes;
  final int order;

  ItineraryItem({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.date,
    required this.time,
    this.notes,
    required this.order,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'],
      placeId: json['placeId'],
      placeName: json['placeName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      notes: json['notes'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'placeName': placeName,
      'date': date.toIso8601String(),
      'time': time,
      'notes': notes,
      'order': order,
    };
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
}

