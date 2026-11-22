# hw2

A Flutter message board app using Firebase Authentication and Cloud Firestore.

## Features
- Splash screen while Firebase initializes
- Register and sign in with email and password
- User record saved in Firestore (uid, first name, last name, role, registration datetime)
- Post, edit, and delete messages
- Live message board (updates without refresh)
- Security rules: only the author can edit or delete their messages

## Setup
1. Install Flutter and the Firebase CLI.
2. In Firebase, enable Email/Password sign-in and create a Firestore database.
3. Run:
   ```
   flutter pub get
   flutterfire configure
   firebase deploy --only firestore:rules
   flutter run
   ```
4. Build the release APK:
   ```
   flutter build apk --release
   ```

## Data model
| Document | Fields | Written by |
|---|---|---|
| `users/{uid}` | uid, firstName, lastName, role, registrationDateTime | The user, once, at registration |
| `messages/{id}` | text, authorUid, authorName, createdAt, editedAt | The author |

## Security rules
- `users/{uid}`: only that user can read it; it is created once and never edited by the client.
- `messages`: any signed-in user can read; only the author can create, edit, or delete.

## Code structure
- `AuthService`: all Firebase Auth calls
- `UserService`: the user record
- `BoardService`: all message calls