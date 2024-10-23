// firebase_options.dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Aquí deberías tener la configuración correcta según la plataforma
    return const FirebaseOptions(
      apiKey: "AlzaSyClICC9_Hj6tiKqYMoP9Ay4qiq2Ms_rqg1U",
      appId: "1:965610149476:web:801431fd3acb5601217171",
      messagingSenderId: "965610149476",
      projectId: "tareasflutter-4eb09",
      storageBucket: "tareasflutter.appspot.com",
      authDomain: "tareasflutter.firebaseapp.com",
    );
  }
}
