import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/weather.dart';
import '../utils/constants.dart';

class ApiService {
  // get places near a location using opentripmap
  static Future<List<Place>> getPlacesByLocation({
    required double latitude,
    required double longitude,
    double radius = 5000,
    int limit = 20,
  }) async {
    try {
      final apiKey = ApiConstants.openTripMapApiKey.trim();
      
      // build the api url
      final queryParams = <String, String>{
        'radius': radius.toString(),
        'lon': longitude.toString(),
        'lat': latitude.toString(),
        'limit': limit.toString(),
        'apikey': apiKey,
      };
      
      final url = Uri.https('api.opentripmap.io', '/0.1/en/places/radius', queryParams);
      
      print('🔍 Fetching places from OpenTripMap API');
      print('📍 Location: lat=$latitude, lon=$longitude, radius=$radius');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'SmartTravelPlanner/1.0',
        },
      );
      
      print('📊 Response status: ${response.statusCode}');
      
      // check if we got html instead of json (means something went wrong)
      final bodyTrimmed = response.body.trim();
      final isHtml = bodyTrimmed.startsWith('<html>') ||
          bodyTrimmed.startsWith('<!DOCTYPE') ||
          bodyTrimmed.startsWith('<script') ||
          bodyTrimmed.contains('<title>Loading...</title>') ||
          bodyTrimmed.contains('text/javascript') ||
          bodyTrimmed.contains('<head>');

      if (isHtml) {
        print('⚠️ API returned HTML instead of JSON - using sample data');
        return _getSamplePlaces(latitude, longitude);
      }

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('✅ Successfully decoded JSON response');
          
          // handle different response formats
          List features = [];
          if (data is Map) {
            features = data['features'] as List? ?? [];
          } else if (data is List) {
            features = data;
          }

          print('Found ${features.length} features in response');

          final places = features
              .map((feature) {
                try {
                  return Place.fromJson(feature);
                } catch (e) {
                  print('Error parsing place: $e');
                  return null;
                }
              })
              .whereType<Place>()
              .where((p) => p.name.isNotEmpty && p.name != 'Unknown Place')
              .toList();

          print('Successfully parsed ${places.length} places');

          // if nothing found, use sample data
          if (places.isEmpty) {
            print('No places found, using sample data');
            return _getSamplePlaces(latitude, longitude);
          }

          return places;
        } catch (e) {
          print('JSON decode error: $e - using sample data');
          return _getSamplePlaces(latitude, longitude);
        }
      } else {
        print('API Error: ${response.statusCode} - using sample data');
        return _getSamplePlaces(latitude, longitude);
      }
    } catch (e) {
      print('Error fetching places: $e - using sample data');
      return _getSamplePlaces(latitude, longitude);
    }
  }

  // get more details about a specific place
  static Future<Place?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = ApiConstants.openTripMapApiKey.trim();
      
      final url = Uri.parse(
        'https://api.opentripmap.io/0.1/en/places/xid/$placeId?apikey=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Place.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
  }

  // get weather info for a location
  static Future<Weather?> getWeatherByLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final apiKey = ApiConstants.openWeatherMapApiKey.trim();
      
      final url = Uri.parse(
        '${ApiConstants.openWeatherMapBaseUrl}/weather?'
        'lat=$latitude&'
        'lon=$longitude&'
        'appid=$apiKey&'
        'units=metric',
      );

      print('🌤️ Fetching weather from OpenWeatherMap API');
      final response = await http.get(url);
      print('Weather response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        print('Weather API error: ${response.statusCode}');
        print('Response: ${response.body.substring(0, math.min(200, response.body.length))}');
        // return fake data if api fails
        return Weather(
          description: 'Partly cloudy',
          icon: '02d',
          temperature: 22.0,
          feelsLike: 21.0,
          humidity: 65,
          windSpeed: 8.0,
          city: 'Unknown',
        );
      }
    } catch (e) {
      print('Error fetching weather: $e');
      // return fake data if something breaks
      return Weather(
        description: 'Partly cloudy',
        icon: '02d',
        temperature: 22.0,
        feelsLike: 21.0,
        humidity: 65,
        windSpeed: 8.0,
        city: 'Unknown',
      );
    }
  }

  // get an image for a destination from unsplash
  static Future<String?> getDestinationImage(
    String query, {
    String? locationHint,
    String? category,
  }) async {
    try {
      final accessKey = ApiConstants.unsplashAccessKey.trim();
      
      // try to build a better search query
      String searchQuery = query;
      if (locationHint != null && locationHint.isNotEmpty) {
        // add location to help find better images
        searchQuery = '$query $locationHint';
      } else if (category != null && category.isNotEmpty) {
        // or use category if we don't have location
        searchQuery = '$query $category';
      }
      
      final url = Uri.parse(
        '${ApiConstants.unsplashBaseUrl}/search/photos?'
        'query=${Uri.encodeComponent(searchQuery)}&'
        'per_page=1&'
        'orientation=landscape&'
        'client_id=$accessKey',
      );

      print('🖼️ Fetching image from Unsplash for: "$searchQuery" (original: "$query")');
      final response = await http.get(url);
      print('Unsplash response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final results = data['results'] as List?;
          if (results != null && results.isNotEmpty) {
            final imageUrl = results[0]['urls']?['regular'] as String?;
            print('✅ Found image: $imageUrl');
            return imageUrl;
          }
          print('No images found in Unsplash results');
        } catch (e) {
          print('Error parsing Unsplash response: $e');
        }
      } else {
        print('Unsplash API error: ${response.statusCode}');
        if (response.statusCode == 401) {
          print('⚠️ Unsplash API key may be invalid');
        }
      }

      // return a placeholder image if nothing found
      return 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800';
    } catch (e) {
      print('Error fetching image from Unsplash: $e');
      // return placeholder if something breaks
      return 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800';
    }
  }

  // fetch images for a bunch of places
  static Future<List<Place>> fetchImagesForPlaces(
    List<Place> places,
    Map<String, String> locationMap,
  ) async {
    print('🖼️ Fetching images for ${places.length} places...');
    
    final updatedPlaces = <Place>[];
    
    for (int i = 0; i < places.length; i++) {
      final place = places[i];
      
      // skip if it already has an image
      if (place.imageUrl != null && place.imageUrl!.isNotEmpty) {
        updatedPlaces.add(place);
        continue;
      }
      
      // figure out which city this is based on coordinates
      String? locationHint;
      if (place.latitude != null && place.longitude != null) {
        // rough guess at which city this is
        if (place.latitude! >= 48.8 && place.latitude! <= 49.0 && 
            place.longitude! >= 2.2 && place.longitude! <= 2.4) {
          locationHint = 'Paris';
        } else if (place.latitude! >= 40.7 && place.latitude! <= 40.8 && 
                   place.longitude! >= -74.1 && place.longitude! <= -73.9) {
          locationHint = 'New York';
        } else if (place.latitude! >= 51.4 && place.latitude! <= 51.6 && 
                   place.longitude! >= -0.2 && place.longitude! <= 0.1) {
          locationHint = 'London';
        }
      }
      
      try {
        final imageUrl = await getDestinationImage(
          place.name,
          locationHint: locationHint,
          category: place.category,
        );
        
        if (imageUrl != null) {
          updatedPlaces.add(place.copyWith(imageUrl: imageUrl));
        } else {
          updatedPlaces.add(place);
        }
      } catch (e) {
        print('Error fetching image for ${place.name}: $e');
        updatedPlaces.add(place);
      }
      
      // small delay to avoid hitting rate limits
      if (i < places.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    print('✅ Finished fetching images for ${updatedPlaces.length} places');
    return updatedPlaces;
  }

  // sample places to use when api doesn't work
  static List<Place> _getSamplePlaces(double lat, double lon) {
    print('Using sample places as fallback');
    final allPlaces = _getAllSamplePlaces();
    
    // filter to places near the requested location (within ~1000km)
    return allPlaces.where((place) {
      final distance = _calculateDistance(
        lat,
        lon,
        place.latitude ?? 0,
        place.longitude ?? 0,
      );
      return distance < 1000; // Within 1000km
    }).toList();
  }

  // list of sample places to fall back to
  static List<Place> _getAllSamplePlaces() {
    return [
      Place(
        id: 'sample1',
        name: 'Eiffel Tower',
        description:
            'Iconic iron lattice tower located on the Champ de Mars in Paris. One of the most recognizable structures in the world.',
        latitude: 48.8584,
        longitude: 2.2945,
        category: 'tower,architecture',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800',
      ),
      Place(
        id: 'sample2',
        name: 'Louvre Museum',
        description:
            'World\'s largest art museum and a historic monument in Paris. Home to the Mona Lisa and thousands of artworks.',
        latitude: 48.8606,
        longitude: 2.3376,
        category: 'museum,cultural',
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1597466599360-ee97593177a1?w=800',
      ),
      Place(
        id: 'sample3',
        name: 'Notre-Dame Cathedral',
        description:
            'Medieval Catholic cathedral on the Île de la Cité. A masterpiece of French Gothic architecture.',
        latitude: 48.8530,
        longitude: 2.3499,
        category: 'religion,architecture',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1543396426-b7561250140c?w=800',
      ),
      Place(
        id: 'sample4',
        name: 'Arc de Triomphe',
        description:
            'Monumental arch in the center of Place Charles de Gaulle. Honors those who fought and died for France.',
        latitude: 48.8738,
        longitude: 2.2950,
        category: 'monument,historic',
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1562967916-eb82221df0f2?w=800',
      ),
      Place(
        id: 'sample5',
        name: 'Champs-Élysées',
        description:
            'Famous avenue in Paris known for theaters, cafés, and luxury shops. One of the world\'s most famous streets.',
        latitude: 48.8698,
        longitude: 2.3081,
        category: 'shopping,street',
        rating: 4.4,
        imageUrl: 'https://images.unsplash.com/photo-1502602898669-a3873847496d?w=800',
      ),
      Place(
        id: 'sample6',
        name: 'Statue of Liberty',
        description:
            'Iconic symbol of freedom and democracy. Located on Liberty Island in New York Harbor.',
        latitude: 40.6892,
        longitude: -74.0445,
        category: 'monument,historic',
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1507502707541-ee384f350657?w=800',
      ),
      Place(
        id: 'sample7',
        name: 'Times Square',
        description:
            'Major commercial intersection and tourist destination in Manhattan. Known for its bright billboards.',
        latitude: 40.7580,
        longitude: -73.9855,
        category: 'square,entertainment',
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1501446020-c129a35c777b?w=800',
      ),
      Place(
        id: 'sample8',
        name: 'Central Park',
        description:
            'Urban park in Manhattan. One of the most visited urban parks in the United States.',
        latitude: 40.7829,
        longitude: -73.9654,
        category: 'park,nature',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1589360204160-f5d87336049e?w=800',
      ),
      Place(
        id: 'sample9',
        name: 'Big Ben',
        description:
            'Iconic clock tower at the north end of the Palace of Westminster in London.',
        latitude: 51.4994,
        longitude: -0.1245,
        category: 'tower,architecture',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1529655683826-aba9b3e7a83f?w=800',
      ),
      Place(
        id: 'sample10',
        name: 'Tower Bridge',
        description:
            'Combined bascule and suspension bridge in London. An iconic symbol of the city.',
        latitude: 51.5055,
        longitude: -0.0754,
        category: 'bridge,architecture',
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1521335629791-ce45e07f917f?w=800',
      ),
      Place(
        id: 'sample11',
        name: 'Buckingham Palace',
        description:
            'The London residence and administrative headquarters of the monarch of the United Kingdom.',
        latitude: 51.5014,
        longitude: -0.1419,
        category: 'palace,historic',
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
      ),
      Place(
        id: 'sample12',
        name: 'Empire State Building',
        description:
            'Art Deco skyscraper in Midtown Manhattan. One of the most famous buildings in the world.',
        latitude: 40.7484,
        longitude: -73.9857,
        category: 'building,architecture',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800',
      ),
      Place(
        id: 'sample13',
        name: 'Brooklyn Bridge',
        description:
            'Hybrid cable-stayed/suspension bridge connecting Manhattan and Brooklyn.',
        latitude: 40.7061,
        longitude: -73.9969,
        category: 'bridge,architecture',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=800',
      ),
      Place(
        id: 'sample14',
        name: 'Sacre-Coeur Basilica',
        description:
            'Roman Catholic church in Paris, located at the summit of Montmartre hill.',
        latitude: 48.8867,
        longitude: 2.3431,
        category: 'religion,architecture',
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1502602898536-47ad22581b52?w=800',
      ),
      Place(
        id: 'sample15',
        name: 'London Eye',
        description:
            'Giant Ferris wheel on the South Bank of the River Thames. One of London\'s most popular tourist attractions.',
        latitude: 51.5033,
        longitude: -0.1196,
        category: 'attraction,entertainment',
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800',
      ),
    ];
  }

  // calculate distance between two points (haversine formula)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
