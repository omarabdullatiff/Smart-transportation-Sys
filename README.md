# Smart Transportation System

A comprehensive mobile application for managing and tracking public transportation services, built with Flutter.

## Features

### User Features
- **User Authentication**
  - Secure login and registration
  - Password recovery with email verification
  - Google Sign-in integration
  - Profile management

- **Bus Tracking**
  - Real-time bus location tracking
  - Interactive map interface
  - Route visualization
  - Estimated arrival times

- **Booking System**
  - Seat selection
  - Route planning
  - Address selection
  - Booking management

- **Lost & Found**
  - Report lost items
  - View found items
  - Contact information for item recovery
  - Item status tracking

### Technical Features
- Deep linking support for password reset
- Real-time location tracking
- Interactive maps integration
- Secure API communication
- Cross-platform support (iOS & Android)

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Android Studio / Xcode
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/omarabdullatiff/Smart-transportation-Sys.git
```

2. Navigate to project directory:
```bash
cd Smart-transportation-Sys
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## API Integration

The app integrates with the following API endpoints:
- Base URL: `http://smarttrackingapp.runasp.net/api`
- Authentication endpoints
- Bus tracking endpoints
- Booking management endpoints
- Lost & Found system endpoints

## Project Structure

```
lib/
├── image/           # Image assets and tracking screen
├── components/      # Reusable UI components
├── screens/         # Main application screens
└── utils/          # Utility functions and helpers
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Security

- Secure password reset flow with email verification
- Protected API endpoints
- Secure data transmission
- User data privacy protection

## Dependencies

- `flutter_map`: For map visualization
- `google_maps_flutter`: Google Maps integration
- `http`: API communication
- `shared_preferences`: Local data storage
- `uni_links`: Deep linking support
- `google_sign_in`: Google authentication

## Authors

- **Omar Abdullatif Mohamed** - *Initial work* - [omarabdullatiff](https://github.com/omarabdullatiff)
- **Abdalla Mohamed** - *Contributor* - [Abdallabola](https://github.com/Abdallabola)

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped shape this project
- The open-source community for their valuable resources
