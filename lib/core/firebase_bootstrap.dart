import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Starts Firebase initialization without blocking Flutter from drawing its
/// first frame. The splash screen waits for this future before opening the
/// onboarding flow, so the user never sees an unnecessary blank screen.
late final Future<FirebaseApp> firebaseReady;

void startFirebaseInitialization() {
  firebaseReady = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
