# Carbon Foot Printer

A Flutter app to track, visualize, and compete on personal carbon footprints.

---

## Overview
Carbon Foot Printer is a mobile app designed to help users monitor and reduce their carbon emissions. Users can log in, record their transport habits, view weekly emissions, and compare their carbon footprint on a leaderboard. The app combines social features, gamification, and eco-awareness in one platform.

---

## Features

### User Authentication
- Sign up / Login with email and password using Firebase Authentication.
- Persistent login using Firebase streams (authStateChanges()).
- Password show/hide functionality.
- Forgot password (placeholder implemented).

### Profile & Settings
- View and edit profile:
  - Username
  - Email
  - Profile picture selection
- Dark mode toggle (UI feature)
- Notifications toggle (UI placeholder)
- Logout functionality

### Leaderboard
- Compare carbon emissions with other users.
- Top 10 users displayed.
- Shows:
  - Username & avatar
  - Country & transportation
  - Carbon emissions (kg CO₂)

### Home & News
- HomeScreen: Displays personal carbon stats (planned graph visualizations).
- NewsScreen: Eco-related news updates (placeholder).

### Public Profile
- View other users’ profiles.
- Displays weekly carbon emissions.

---

## Tech Stack
- Flutter – Frontend UI
- Firebase Auth – Authentication
- Cloud Firestore – Database for user profiles & emissions
- Firebase Core – Backend integration
- Dart – Programming language

---

## Project Structure
lib/
│
├── main.dart              # App entry, bottom navigation & Firebase initialization
├── login.dart             # Login screen & persistent login
├── signup.dart            # Sign up screen
├── profile_screen.dart    # Edit user profile
├── publicprofile_screen.dart # Public profile view
├── settings_screen.dart   # App settings & logout
├── leader_screen.dart     # Leaderboard with top users
├── home_screen.dart       # Main user dashboard
├── news_screen.dart       # Eco-news feed
└── firebase_service.dart  # Firebase Auth & Firestore integration

---

## Firebase Integration
1. Authentication – Email/password login.
2. Firestore Structure:
users (collection)
│
└── {uid} (document)
     ├── displayName: string
     ├── email: string
     ├── pfp: int
     ├── carbonEmission: double
     ├── createdAt: timestamp

---

## Screenshots / Mockups
(Add screenshots from the app if available for hackathon submission.)

---

## Installation & Setup
1. Clone the repository:
git clone https://github.com/your-repo/carbon-foot-printer.git
2. Install dependencies:
flutter pub get
3. Set up Firebase:
   - Create a Firebase project.
   - Enable Authentication and Firestore.
   - Download google-services.json or GoogleService-Info.plist.
   - Update firebase_options.dart.
4. Run the app:
flutter run

---

## Future Features
- Weekly carbon emission charts & analytics.
- Transport activity logging.
- Push notifications for eco-tips.
- Social sharing and friends leaderboard.

---

## Contributors
- JadeFootprint
  - Amar Razzaq – Lead developer, Firebase integration, UI/UX, Graphic Design
  - Chris Padleski - Lead developer, Firebase integration, Auth Dev, CRUD API, Backend Dev, ADK
  - David Gomez - Lead developer, UI/UX, Graphic Design, Figma
  - Iadd Chehaeb - ADK Agent Engineer

---

## License
MIT License
