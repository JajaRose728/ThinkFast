# ThinkFast
[!NOTE]
## Description
ThinkFast is a Flutter-based quiz application that allows users to create, share, and take quizzes with friends. Users can build custom quizzes with multiple-choice questions, categorize them, and share via unique codes for others to import and play.

[!TIP]
## Features
- User authentication with Firebase Auth
- Create and edit quizzes with multiple-choice questions
- Categorize quizzes (General, Science, History, etc.)
- Share quizzes via unique codes
- Import quizzes from codes
- Take quizzes with scoring and feedback
- Creator-only edit/delete permissions
- Secure data storage with Firestore

## Screenshots
Login/Sign Up screen
<img width="1919" height="949" alt="Screenshot 2026-05-10 125646" src="https://github.com/user-attachments/assets/fecef2dd-229c-4d0c-a470-fab1503ed1cb" />

Create Quiz screen
<img width="1919" height="949" alt="Screenshot 2026-05-10 125727" src="https://github.com/user-attachments/assets/8a5d1e21-d4a1-409b-8948-4679a32346e5" />

Home screen
<img width="1919" height="948" alt="Screenshot 2026-05-10 125833" src="https://github.com/user-attachments/assets/e0583eeb-fab5-4fc5-8618-6f9792b901cc" />

Quiz

<img width="1919" height="896" alt="Screenshot 2026-05-10 125839" src="https://github.com/user-attachments/assets/f8f7d870-48a3-4885-bad3-35bf3c9fabff" />
<img width="1919" height="949" alt="Screenshot 2026-05-10 130037" src="https://github.com/user-attachments/assets/a13cc049-f850-4251-bfb7-40e3494f7778" />

[!TIP]
## Security Features (Course Goal 1)
- [x] HTTPS for API calls (Firebase handles secure connections)
- [x] Encrypted storage for sensitive data (Firebase Auth and Firestore)
- [x] Input validation (Form validation in quiz creation and import)
- [x] Secure authentication (Firebase Auth with email/password)

[!TIP]
## Why Flutter? (Course Goal 2)
Flutter was an excellent choice for this project because:
- **Cross-platform benefit**: Single codebase runs on iOS, Android, and Web
- **Hot reload**: Significantly speeded up development and UI iteration
- **Widget system**: Made building complex UIs intuitive and efficient
- **Performance**: Native performance with Dart's compiled code
- **Rich ecosystem**: Extensive packages for Firebase integration and state management

[!TIP]
## Setup Instructions
1. Clone the repository: `git clone <repository-url>`
2. Navigate to project directory: `cd thinkfast`
3. Install dependencies: `flutter pub get`
4. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com/
   - Enable Authentication and Firestore
   - Download `google-services.json` for Android and place in `android/app/`
   - Configure Firebase options in `lib/firebase_options.dart`
5. Run the app: `flutter run`

[!TIP]
## Dependencies
- firebase_core: 2.30.1
- firebase_auth: 4.19.4
- cloud_firestore: 4.17.2
- flutter_secure_storage: ^9.0.0
- provider: ^6.0.5
- flutter_dotenv: ^6.0.1
- cupertino_icons: ^1.0.8

## Author
Your Name - your.email@example.com
