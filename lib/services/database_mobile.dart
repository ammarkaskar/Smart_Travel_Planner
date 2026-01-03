import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import '../utils/constants.dart';

class DatabaseMobile {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  static Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.dbName);

      return await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: (db, version) async {
          try {
            await db.execute('''
              CREATE TABLE trips (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                destination TEXT NOT NULL,
                startDate TEXT NOT NULL,
                endDate TEXT NOT NULL,
                itinerary TEXT NOT NULL,
                createdAt TEXT NOT NULL
              )
            ''');
          } catch (e) {
            print('Error creating database table: $e');
            rethrow;
          }
        },
      );
    } catch (e) {
      print('Error in _initDatabase: $e');
      rethrow;
    }
  }

  // save a trip to the database
  static Future<void> saveTrip(Trip trip) async {
    try {
      final db = await database;
      await db.insert(
        'trips',
        {
          'id': trip.id,
          'name': trip.name,
          'destination': trip.destination,
          'startDate': trip.startDate.toIso8601String(),
          'endDate': trip.endDate.toIso8601String(),
          'itinerary': jsonEncode(trip.itinerary.map((item) => item.toJson()).toList()),
          'createdAt': trip.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving trip: $e');
      rethrow;
    }
  }

  // get all saved trips
  static Future<List<Trip>> getAllTrips() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('trips', orderBy: 'createdAt DESC');

      return List.generate(maps.length, (i) {
        try {
          final map = maps[i];
          final itineraryJson = jsonDecode(map['itinerary'] as String) as List;
          return Trip(
            id: map['id'],
            name: map['name'],
            destination: map['destination'],
            startDate: DateTime.parse(map['startDate']),
            endDate: DateTime.parse(map['endDate']),
            itinerary: itineraryJson.map((item) => 
              ItineraryItem.fromJson(item as Map<String, dynamic>)
            ).toList(),
            createdAt: DateTime.parse(map['createdAt']),
          );
        } catch (e) {
          print('Error parsing trip at index $i: $e');
          // skip this one if we can't parse it
          return Trip(
            id: 'error_$i',
            name: 'Error loading trip',
            destination: 'Unknown',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            itinerary: [],
            createdAt: DateTime.now(),
          );
        }
      });
    } catch (e) {
      print('Error in getAllTrips: $e');
      return []; // Return empty list on error
    }
  }

  // delete a trip
  static Future<void> deleteTrip(String tripId) async {
    try {
      final db = await database;
      await db.delete('trips', where: 'id = ?', whereArgs: [tripId]);
    } catch (e) {
      print('Error deleting trip: $e');
      rethrow;
    }
  }

  // get a specific trip by id
  static Future<Trip?> getTripById(String tripId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trips',
        where: 'id = ?',
        whereArgs: [tripId],
      );

      if (maps.isNotEmpty) {
        try {
          final map = maps[0];
          final itineraryJson = jsonDecode(map['itinerary'] as String) as List;
          return Trip(
            id: map['id'],
            name: map['name'],
            destination: map['destination'],
            startDate: DateTime.parse(map['startDate']),
            endDate: DateTime.parse(map['endDate']),
            itinerary: itineraryJson.map((item) => 
              ItineraryItem.fromJson(item as Map<String, dynamic>)
            ).toList(),
            createdAt: DateTime.parse(map['createdAt']),
          );
        } catch (e) {
          print('Error parsing trip data: $e');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error in getTripById: $e');
      return null;
    }
  }
}

