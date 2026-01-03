import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';
import '../utils/constants.dart';

// use mobile db on mobile, web stub on web
import 'database_mobile.dart' if (dart.library.html) 'database_web_stub.dart';

class LocalStorageService {
  // save a trip
  static Future<void> saveTrip(Trip trip) async {
    if (kIsWeb) {
      await _saveTripWeb(trip);
    } else {
      await DatabaseMobile.saveTrip(trip);
    }
  }

  // get all saved trips
  static Future<List<Trip>> getAllTrips() async {
    try {
      if (kIsWeb) {
        return await _getAllTripsWeb();
      } else {
        return await DatabaseMobile.getAllTrips();
      }
    } catch (e) {
      print('Error in getAllTrips: $e');
      return []; // Return empty list on error
    }
  }

  // delete a trip
  static Future<void> deleteTrip(String tripId) async {
    if (kIsWeb) {
      await _deleteTripWeb(tripId);
    } else {
      await DatabaseMobile.deleteTrip(tripId);
    }
  }

  // get a specific trip by id
  static Future<Trip?> getTripById(String tripId) async {
    if (kIsWeb) {
      return await _getTripByIdWeb(tripId);
    } else {
      return await DatabaseMobile.getTripById(tripId);
    }
  }

  // web version using SharedPreferences
  static Future<void> _saveTripWeb(Trip trip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await _getAllTripsWeb();
      trips.removeWhere((t) => t.id == trip.id);
      trips.add(trip);
      await prefs.setString(
          'trips', jsonEncode(trips.map((t) => t.toJson()).toList()));
    } catch (e) {
      print('Error saving trip to web storage: $e');
      rethrow;
    }
  }

  static Future<List<Trip>> _getAllTripsWeb() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsString = prefs.getString('trips');
      if (tripsString == null) return [];

      try {
        final List<dynamic> tripsJson = jsonDecode(tripsString);
        final trips = tripsJson
            .map((json) {
              try {
                return Trip.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing trip JSON: $e');
                return null;
              }
            })
            .whereType<Trip>()
            .toList();
        trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return trips;
      } catch (e) {
        print('Error decoding trips JSON: $e');
        return [];
      }
    } catch (e) {
      print('Error in _getAllTripsWeb: $e');
      return [];
    }
  }

  static Future<void> _deleteTripWeb(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await _getAllTripsWeb();
    trips.removeWhere((t) => t.id == tripId);
    await prefs.setString(
        'trips', jsonEncode(trips.map((t) => t.toJson()).toList()));
  }

  static Future<Trip?> _getTripByIdWeb(String tripId) async {
    final trips = await _getAllTripsWeb();
    try {
      return trips.firstWhere((t) => t.id == tripId);
    } catch (e) {
      return null;
    }
  }

  // user data storage (works everywhere)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.sharedPrefsUserKey, jsonEncode(userData));
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConstants.sharedPrefsUserKey);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null; // Return null on error
    }
  }

  static Future<void> setAuthenticated(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.sharedPrefsAuthKey, value);
    } catch (e) {
      print('Error setting authentication state: $e');
      rethrow;
    }
  }

  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.sharedPrefsAuthKey) ?? false;
    } catch (e) {
      print('Error checking authentication: $e');
      return false; // Default to not authenticated on error
    }
  }
}
