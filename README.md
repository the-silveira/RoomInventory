# RoomInventory

RoomInventory is a cross-platform Flutter application for managing room inventories, including items, fixtures, DMX outputs, and event management. The project features Firebase authentication (including Google Sign-In), QR code generation and scanning, and a modern, responsive UI with Cupertino (iOS-style) widgets.

---

## Features

- **Inventory Management:**  
  Add, edit, and manage items, fixtures, and DMX outputs for rooms and events.

- **Event Management:**  
  Create and manage events, assign items, and track event details.

- **QR Code Integration:**  
  Generate and scan QR codes for inventory items.

- **Firebase Integration:**  
  Authentication (Google Sign-In), cloud storage, and real-time updates.

- **Responsive UI:**  
  Cupertino (iOS-style) widgets for a native iOS look and feel.

- **Theming:**  
  Light and dark mode support with persistent user preferences.

- **Backend API:**  
  PHP-based backend with MySQL database for data storage and management.

---

## Project Structure

```
roominventory/
├── android/           # Android native project
├── backend/           # PHP API and SQL scripts
├── ios/               # iOS native project
├── lib/               # Flutter/Dart source code
│   ├── main.dart
│   ├── classes/    
│   ├── globalWidgets/
│   └── pages/
├── linux/             # Linux desktop support
├── macos/             # macOS desktop support
├── web/               # Web support
├── windows/           # Windows desktop support
├── pubspec.yaml       # Flutter dependencies
└── README.md          # Project documentation
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://console.firebase.google.com/)
- [MySQL](https://www.mysql.com/) (for backend)
- [PHP 8+](https://www.php.net/) (for backend API)

### Setup

1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd roominventory
   ```

2. **Install Flutter dependencies:**
   ```sh
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` in `android/app/`.
   - Place your `GoogleService-Info.plist` in `ios/Runner/`.

4. **Backend Setup:**
   - Import `backend/roominventory.sql` into your MySQL server.
   - Configure your PHP backend (see `backend/api/`).

5. **Run the app:**
   ```sh
   flutter run
   ```

---

## Development Notes

- **Kotlin Version:**  
  Ensure your Android project uses Kotlin 2.1.0+ for compatibility with the latest Flutter and plugins.

- **Namespace Requirement:**  
  All Android modules and plugins must specify a `namespace` in their `build.gradle` files.

- **Google Sign-In:**  
  Make sure your Firebase project is configured for Google authentication and your SHA1 is registered.

- **QR Code Scanner:**  
  If you encounter build errors, update the `qr_code_scanner` plugin and ensure the `namespace` is set.

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the MIT License.

---

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [qr_code_scanner](https://pub.dev/packages/qr_code_scanner)
- [provider](https://pub.dev/packages/provider)