import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '../models/weather.dart';
import '../services/api_service.dart';
import 'itinerary_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Weather? _weather;
  bool _isLoadingWeather = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadImage();
  }

  Future<void> _loadWeather() async {
    if (widget.place.latitude == null || widget.place.longitude == null) {
      return;
    }

    setState(() => _isLoadingWeather = true);

    try {
      final weather = await ApiService.getWeatherByLocation(
        latitude: widget.place.latitude!,
        longitude: widget.place.longitude!,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  Future<void> _loadImage() async {
    // Use existing imageUrl if available
    if (widget.place.imageUrl != null && widget.place.imageUrl!.isNotEmpty) {
      setState(() => _imageUrl = widget.place.imageUrl);
      return;
    }
    
    try {
      // Determine location hint based on coordinates
      String? locationHint;
      if (widget.place.latitude != null && widget.place.longitude != null) {
        if (widget.place.latitude! >= 48.8 && widget.place.latitude! <= 49.0 && 
            widget.place.longitude! >= 2.2 && widget.place.longitude! <= 2.4) {
          locationHint = 'Paris';
        } else if (widget.place.latitude! >= 40.7 && widget.place.latitude! <= 40.8 && 
                   widget.place.longitude! >= -74.1 && widget.place.longitude! <= -73.9) {
          locationHint = 'New York';
        } else if (widget.place.latitude! >= 51.4 && widget.place.latitude! <= 51.6 && 
                   widget.place.longitude! >= -0.2 && widget.place.longitude! <= 0.1) {
          locationHint = 'London';
        }
      }
      
      final imageUrl = await ApiService.getDestinationImage(
        widget.place.name,
        locationHint: locationHint,
        category: widget.place.category,
      );
      if (mounted) {
        setState(() => _imageUrl = imageUrl);
      }
    } catch (e) {
      // Ignore image loading errors
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.place.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              background: _imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6366F1),
                              const Color(0xFF8B5CF6),
                            ],
                          ),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6366F1),
                              const Color(0xFF8B5CF6),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.place,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.place,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Chip
                  if (widget.place.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.place.category!.split(',').first,
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Weather Section - PROMINENT
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _isLoadingWeather
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : _weather != null
                            ? Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.wb_sunny,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Current Weather',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_weather!.icon.isNotEmpty)
                                          Image.network(
                                            'https://openweathermap.org/img/wn/${_weather!.icon}@2x.png',
                                            width: 80,
                                            height: 80,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.wb_sunny,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _weather!.temperatureString,
                                                style: const TextStyle(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  height: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _weather!.description
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Feels like ${_weather!.feelsLikeString}',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _WeatherInfo(
                                          icon: Icons.water_drop,
                                          label: 'Humidity',
                                          value: '${_weather!.humidity}%',
                                        ),
                                        _WeatherInfo(
                                          icon: Icons.air,
                                          label: 'Wind Speed',
                                          value:
                                              '${_weather!.windSpeed.toStringAsFixed(1)} m/s',
                                        ),
                                        _WeatherInfo(
                                          icon: Icons.location_city,
                                          label: 'City',
                                          value: _weather!.city,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.cloud_off,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Weather information not available',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (widget.place.description != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF6366F1),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.place.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Location Info
                  if (widget.place.latitude != null &&
                      widget.place.longitude != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF6366F1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Coordinates',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.place.latitude!.toStringAsFixed(4)}, ${widget.place.longitude!.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Add to Itinerary Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ItineraryScreen(selectedPlace: widget.place),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'Add to Itinerary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
