import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../services/local_storage_service.dart';

class TripProvider with ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;

  TripProvider() {
    // load trips in the background
    loadTrips().catchError((error) {
      print('Error loading trips in constructor: $error');
      _isLoading = false;
      _trips = [];
      notifyListeners();
    });
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = await LocalStorageService.getAllTrips();
    } catch (e) {
      print('Error loading trips: $e');
      _trips = []; // Set empty list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTrip(Trip trip) async {
    try {
      await LocalStorageService.saveTrip(trip);
      await loadTrips();
    } catch (e) {
      print('Error saving trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await LocalStorageService.deleteTrip(tripId);
      await loadTrips();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }
}

