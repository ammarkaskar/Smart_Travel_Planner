import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/place.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import '../providers/trip_provider.dart';
import '../screens/place_list_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final Place? selectedPlace;

  const ItineraryScreen({super.key, this.selectedPlace});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<ItineraryItem> _itineraryItems = [];
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedPlace != null) {
      _destinationController.text = widget.selectedPlace!.name;
      // Use post-frame callback to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _addPlaceToItinerary(widget.selectedPlace!, showMessage: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addPlaceToItinerary(Place place, {bool showMessage = true}) {
    // If no start date is set, use today's date as default
    final dateToUse = _startDate ?? DateTime.now();
    
    // If start date was null, set it to today
    if (_startDate == null) {
      setState(() {
        _startDate = DateTime.now();
      });
    }

    setState(() {
      _itineraryItems.add(
        ItineraryItem(
          id: const Uuid().v4(),
          placeId: place.id,
          placeName: place.name,
          date: dateToUse,
          time: _timeController.text.isEmpty ? '09:00' : _timeController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          order: _itineraryItems.length,
        ),
      );
      _timeController.clear();
      _notesController.clear();
    });
    
    // Show success message only if requested and context is available
    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${place.name} added to itinerary'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('End date must be after start date')),
            );
          }
        }
      });
    }
  }

  Future<void> _selectTime(ItineraryItem item) async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeOfDay != null) {
      setState(() {
        final index = _itineraryItems.indexOf(item);
        _itineraryItems[index] = ItineraryItem(
          id: item.id,
          placeId: item.placeId,
          placeName: item.placeName,
          date: item.date,
          time: timeOfDay.format(context),
          notes: item.notes,
          order: item.order,
        );
      });
    }
  }

  void _removeItem(ItineraryItem item) {
    setState(() {
      _itineraryItems.remove(item);
    });
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    if (_itineraryItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one place to itinerary')),
      );
      return;
    }

    final trip = Trip(
      id: const Uuid().v4(),
      name: _tripNameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      itinerary: _itineraryItems,
      createdAt: DateTime.now(),
    );

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.saveTrip(trip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip saved successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Itinerary'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Name
              TextFormField(
                controller: _tripNameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter trip name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Destination
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Select date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'Select date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add Place Section
              Text(
                'Add Places',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final place = await Navigator.of(context).push<Place>(
                    MaterialPageRoute(
                      builder: (_) =>
                          const PlaceListScreen(isSelectionMode: true),
                    ),
                  );
                  if (place != null) {
                    _addPlaceToItinerary(place);
                  }
                },
                icon: const Icon(Icons.add_location),
                label: const Text('Browse Places'),
              ),
              const SizedBox(height: 16),

              // Time and Notes for Quick Add
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (optional)',
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'e.g., 09:00',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Itinerary Items
              Text(
                'Itinerary Items',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              if (_itineraryItems.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No items added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                ..._itineraryItems.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${item.order + 1}'),
                        ),
                        title: Text(item.placeName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.formattedDate} at ${item.time}'),
                            if (item.notes != null) Text(item.notes!),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () => _selectTime(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(item),
                            ),
                          ],
                        ),
                      ),
                    )),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
