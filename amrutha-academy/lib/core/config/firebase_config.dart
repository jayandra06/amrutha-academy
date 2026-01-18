import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static FirebaseAuth? auth;
  static FirebaseFirestore? firestore;
  static FirebaseDatabase? database;
  static FirebaseStorage? storage;
  static FirebaseMessaging? messaging;

  static DatabaseReference get databaseRef => database!.ref();

  static Future<void> initialize() async {
    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      database = FirebaseDatabase.instance;
      storage = FirebaseStorage.instance;
      messaging = FirebaseMessaging.instance;

      // Request notification permissions
      try {
        await messaging!.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        // Notification permission request can fail, but it's not critical
        print('Warning: Could not request notification permissions: $e');
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow; // Re-throw to let main.dart handle it
    }
  }

  static Future<String?> getFCMToken() async {
    return await messaging?.getToken();
  }
}

