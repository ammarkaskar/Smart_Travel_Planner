// Stub file for web - prevents import errors
// The actual web implementation uses SharedPreferences in local_storage_service.dart
import '../models/trip.dart';

class DatabaseMobile {
  static Future<void> saveTrip(Trip trip) async {
    throw UnimplementedError('DatabaseMobile not available on web');
  }

  static Future<List<Trip>> getAllTrips() async {
    throw UnimplementedError('DatabaseMobile not available on web');
  }

  static Future<void> deleteTrip(String tripId) async {
    throw UnimplementedError('DatabaseMobile not available on web');
  }

  static Future<Trip?> getTripById(String tripId) async {
    throw UnimplementedError('DatabaseMobile not available on web');
  }
}

