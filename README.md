# Smart Travel Planner

A Flutter-based mobile application designed to help users plan their trips easily. The application provides information about tourist destinations, basic weather details, and a simple itinerary planner.

## Features

- **Destination Discovery**: Explore tourist places using OpenTripMap API
- **Weather Information**: Get current weather details for destinations using OpenWeatherMap API
- **Itinerary Planning**: Create and manage detailed trip itineraries
- **Offline Access**: Save trips locally for offline access
- **User Authentication**: Simple login system with local storage
- **Saved Trips**: View and manage all your saved trips

## Screens

1. **Login Screen**: User authentication
2. **Home Screen**: Dashboard with quick actions and app overview
3. **Place List Screen**: Browse and search tourist destinations
4. **Place Detail Screen**: View detailed information about a place including weather
5. **Itinerary Screen**: Create and edit trip itineraries
6. **Saved Trips Screen**: View all saved trips
7. **Itinerary Detail Screen**: View detailed itinerary for a saved trip

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android/iOS emulator or physical device

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd "Smart Travel Planner"
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API Keys:
   - The app includes API keys in `lib/utils/constants.dart` for demo purposes
   - For production use, replace the API keys with your own:
     - Get OpenWeatherMap API key from [OpenWeatherMap](https://openweathermap.org/api)
     - Get Unsplash API key from [Unsplash](https://unsplash.com/developers)
     - Get OpenTripMap API key from [OpenTripMap](https://opentripmap.io/docs)
   - See `lib/utils/constants.dart.example` for the template structure
   
   **Note**: The app will work with the included demo keys, but for production use, you should use your own API keys.

4. Run the app:
```bash
flutter run
```

## API Configuration

### OpenTripMap API
- Currently using a demo API key
- No additional configuration needed for basic usage

### OpenWeatherMap API
1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Get your free API key
3. Replace `YOUR_OPENWEATHER_API_KEY` in `lib/utils/constants.dart`

### Unsplash API
1. Sign up at [Unsplash Developers](https://unsplash.com/developers)
2. Create an application and get your access key
3. Replace `YOUR_UNSPLASH_ACCESS_KEY` in `lib/utils/constants.dart`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── place.dart
│   ├── weather.dart
│   ├── itinerary_item.dart
│   └── trip.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── place_list_screen.dart
│   ├── place_detail_screen.dart
│   ├── itinerary_screen.dart
│   ├── saved_trips_screen.dart
│   └── itinerary_detail_screen.dart
├── services/                 # API and storage services
│   ├── api_service.dart
│   └── local_storage_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── trip_provider.dart
└── utils/                    # Utilities
    ├── app_theme.dart
    └── constants.dart
```

## Usage

1. **Login**: Enter any email and password (minimum 6 characters) to login
2. **Explore Places**: Browse tourist destinations from the Explore tab
3. **View Details**: Tap on any place to see details and weather information
4. **Create Itinerary**: 
   - Go to Create Itinerary
   - Enter trip name and destination
   - Select start and end dates
   - Add places to your itinerary
   - Save the trip
5. **View Saved Trips**: Access all your saved trips from the Saved tab

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **HTTP**: API calls
- **SQFlite**: Local database for offline storage
- **SharedPreferences**: User preferences storage
- **Google Fonts**: Typography

## Limitations

- Free APIs have limited data and rate limits
- No online booking feature
- Internet required for initial data load
- Weather API requires valid API key for real data

## Future Enhancements

- Google Maps integration
- Hotel and transport booking links
- Multi-language support
- User reviews and ratings
- Social sharing features
- Trip cost estimation

## License

This project is created for educational purposes as a college-level project.


## Acknowledgments

- OpenTripMap API for destination data
- OpenWeatherMap API for weather information
- Unsplash API for destination images


