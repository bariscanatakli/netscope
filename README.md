# netscope

A Flutter-based application designed to provide network analysis tools.

## Key Features

- Tracerouting integrated with Google Maps
- Network speed tests
- IP address lookup
- User authentication with Firebase
- Database integration with Firestore from Firebase

## System Requirements

- Flutter SDK (3.24.5)
- Dart SDK (3.5.4)
- DevTools (2.37.3)
- Java (23.0.1)

## Supported Platforms

- Android

## Installation Guide

### Step-by-Step Installation Instructions

1. Clone the repository:
   ```
   git clone https://github.com/bariscanatakli/netscope
   ```
2. Navigate to the project directory:
   ```
   cd netscope
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

### Configuration Settings

Ensure the `google-services.json` file is placed in `netscope/android/app`.

## User Guide

### How to Use the Application

- Launch the application.
- Navigate through the pages (Homepage, Favorites, Profile) to access different tools/features.

### How to Use Features

- **Traceroute**: Click the Traceroute icon on the Homepage to access. It takes the user to three features (Map, Hops, Details).
  - **Map**: Press the button on the map to display network nodes. Navigate between the hops by pressing the next or backward buttons.
  - **Hops**: Shows tracerouting hops.
  - **Details**: Displays hop details.
  
- **Speed Test**: Click the Speed Test icon on the Homepage to access. Press the “Start Test” button to begin testing network speed. Results are displayed on the screen, and users can view the history of tests by pressing the “View Results” button.

- **Account Information**: Navigate to the Profile page to access user information. Users can change their username, password, and profile picture.

- **Network Information**: Navigate to the Profile page to view network information (IP Address, connection type).

- **Favorites Tools**: Add/remove features to favorites from the Homepage by pressing the heart icon. View favorites on the Favorites page.

- **Theme**: Change the theme (Light/Dark) by pressing the theme button at the top of the page.


## FAQ

### Common Issues and Solutions

- **Issue**: Application not launching  
  **Solution**: Ensure all dependencies are installed and configured correctly.

### Troubleshooting Tips

- Verify network connectivity.

## Support Information

Contact our support team:  
- bariscan.atakli@hotmail.com  
- bayramgrbz211@gmail.com  
- mnamorsy2004@gmail.com  

## Developer Documentation

### Overview of the Project

NetScope is a network analysis tool built with Flutter.

### Key Tools Used

- Flutter: UI framework
- Dart: Programming language
- Firebase: Backend services
- Firestore: Database
- Google Maps: Traceroute visualization
- Flutter_speedtest: Network speed testing

### Architecture

- **UI**: Built with Flutter widgets.
- **Backend**: Firebase & Firestore for authentication and data storage, Google API for traceroute visualization, Flutter_speedtest for network speed testing.

### Setup

1. Install Flutter SDK.
2. Install Dart SDK (included with Flutter).
3. Install dependencies with `flutter pub get`.

### Codebase Overview

- **lib**: Contains Dart source files.
- **main.dart**: Entry point of the application.
- **screens/**: Contains UI screens.
- **providers/**: Manages authentication state.
- **services/**: Handles network requests and authentication.
- **widgets/**: Contains reusable widgets.
- **models/**: Defines data models.
- **theme/**: Manages application themes.

### API Documentation

- **Base URL**: https://api.siterelic.com
- **Endpoints**: Traceroute, Geolocation, Speed Test.

### Conclusion

NetScope provides essential tools for network analysis, leveraging Flutter's capabilities for a seamless user experience.
