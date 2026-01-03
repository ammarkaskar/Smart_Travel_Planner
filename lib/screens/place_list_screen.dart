import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '../services/api_service.dart';
import 'place_detail_screen.dart';

class PlaceListScreen extends StatefulWidget {
  final bool isSelectionMode;

  const PlaceListScreen({super.key, this.isSelectionMode = false});

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  List<Place> _allPlaces = []; // Store all loaded places
  List<Place> _filteredPlaces = []; // Filtered places for display
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlaces(); // Pre-load places on init
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);

    try {
      // Try loading from multiple popular cities
      List<Place> allPlaces = [];
      final locations = [
        {'lat': 48.8566, 'lon': 2.3522}, // Paris
        {'lat': 40.7128, 'lon': -74.0060}, // New York
        {'lat': 51.5074, 'lon': -0.1278}, // London
      ];

      for (final location in locations) {
        try {
          final places = await ApiService.getPlacesByLocation(
            latitude: location['lat'] as double,
            longitude: location['lon'] as double,
            radius: 10000,
            limit: 15,
          );
          print('Loaded ${places.length} places from location');
          if (places.isNotEmpty) {
            allPlaces.addAll(places);
            if (allPlaces.length >= 30) break;
          }
        } catch (e) {
          print('Error loading from location: $e');
          continue;
        }
      }
      
      print('Total places loaded: ${allPlaces.length}');

      // Remove duplicates
      final uniquePlaces = <String, Place>{};
      for (final place in allPlaces) {
        if (place.name.isNotEmpty && place.name != 'Unknown Place') {
          uniquePlaces[place.id] = place;
        }
      }

      var places = uniquePlaces.values.take(30).toList();
      print('Unique places after filtering: ${places.length}');
      
      // Fetch images for all places
      if (places.isNotEmpty) {
        try {
          print('🖼️ Fetching images for places...');
          places = await ApiService.fetchImagesForPlaces(places, {});
          print('✅ Images fetched successfully');
        } catch (e) {
          print('Error fetching images: $e');
          // Continue with places even if image fetching fails
        }
      }
      
      // If no places found from API, create sample places directly
      // (The API service should return sample data, but this is a backup)
      if (places.isEmpty) {
        print('No places from API, creating sample places directly');
        places = [
          Place(
            id: 'fallback1',
            name: 'Eiffel Tower',
            description: 'Iconic iron lattice tower located on the Champ de Mars in Paris. One of the most recognizable structures in the world.',
            latitude: 48.8584,
            longitude: 2.2945,
            category: 'tower,architecture',
            rating: 4.6,
          ),
          Place(
            id: 'fallback2',
            name: 'Louvre Museum',
            description: 'World\'s largest art museum and a historic monument in Paris. Home to the Mona Lisa and thousands of artworks.',
            latitude: 48.8606,
            longitude: 2.3376,
            category: 'museum,cultural',
            rating: 4.7,
          ),
          Place(
            id: 'fallback3',
            name: 'Notre-Dame Cathedral',
            description: 'Medieval Catholic cathedral on the Île de la Cité. A masterpiece of French Gothic architecture.',
            latitude: 48.8530,
            longitude: 2.3499,
            category: 'religion,architecture',
            rating: 4.6,
          ),
          Place(
            id: 'fallback4',
            name: 'Arc de Triomphe',
            description: 'Monumental arch in the center of Place Charles de Gaulle. Honors those who fought and died for France.',
            latitude: 48.8738,
            longitude: 2.2950,
            category: 'monument,historic',
            rating: 4.5,
          ),
          Place(
            id: 'fallback5',
            name: 'Statue of Liberty',
            description: 'Iconic symbol of freedom and democracy. Located on Liberty Island in New York Harbor.',
            latitude: 40.6892,
            longitude: -74.0445,
            category: 'monument,historic',
            rating: 4.7,
          ),
          Place(
            id: 'fallback6',
            name: 'Times Square',
            description: 'Major commercial intersection and tourist destination in Manhattan. Known for its bright billboards.',
            latitude: 40.7580,
            longitude: -73.9855,
            category: 'square,entertainment',
            rating: 4.5,
          ),
          Place(
            id: 'fallback7',
            name: 'Big Ben',
            description: 'Iconic clock tower at the north end of the Palace of Westminster in London.',
            latitude: 51.4994,
            longitude: -0.1245,
            category: 'tower,architecture',
            rating: 4.6,
          ),
          Place(
            id: 'fallback8',
            name: 'Tower Bridge',
            description: 'Combined bascule and suspension bridge in London. An iconic symbol of the city.',
            latitude: 51.5055,
            longitude: -0.0754,
            category: 'bridge,architecture',
            rating: 4.7,
          ),
        ];
        print('Created ${places.length} sample places as fallback');
      }

      if (mounted) {
        setState(() {
          _allPlaces = places; // Store all places
          _filteredPlaces = places; // Initially show all places
          _isLoading = false;
        });
        
        print('Final places count: ${places.length}');
      }
    } catch (e) {
      print('Error in _loadPlaces: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading places: $e'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _loadPlaces(),
            ),
          ),
        );
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      
      // Filter existing places instead of reloading
      if (query.isEmpty) {
        _filteredPlaces = _allPlaces;
      } else {
        _filteredPlaces = _allPlaces.where((place) {
          final searchLower = query.toLowerCase();
          return place.name.toLowerCase().contains(searchLower) ||
              (place.category?.toLowerCase().contains(searchLower) ?? false) ||
              (place.description?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.isSelectionMode ? 'Select a Place' : 'Explore Places'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _handleSearch,
            ),
          ),

          // Places List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading amazing places...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredPlaces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No places found for "$_searchQuery"'
                                  : 'No places found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _handleSearch('');
                                },
                                child: const Text('Clear search'),
                              ),
                            ],
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _loadPlaces(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _filteredPlaces[index];
                          return _PlaceCard(
                            place: place,
                            isSelectionMode: widget.isSelectionMode,
                            onTap: () {
                              if (widget.isSelectionMode) {
                                Navigator.of(context).pop(place);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlaceDetailScreen(place: place),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final bool isSelectionMode;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.place,
    this.isSelectionMode = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.8),
                        const Color(0xFF8B5CF6).withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: place.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.place,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.place,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Place Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (place.category != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            place.category!.split(',').first,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                      if (place.rating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelectionMode
                      ? Icons.check_circle_outline
                      : Icons.chevron_right_rounded,
                  color: isSelectionMode
                      ? const Color(0xFF10B981)
                      : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
