import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  static FirebaseAuth? auth;
  static FirebaseFirestore? firestore;
  static FirebaseDatabase? database;
  static FirebaseStorage? storage;
  static FirebaseMessaging? messaging;

  static DatabaseReference get databaseRef => database!.ref();

  static Future<void> initialize() async {
    try {
      // For web, we need explicit Firebase options
      if (kIsWeb) {
        // TODO: Get the web appId from Firebase Console:
        // 1. Go to: https://console.firebase.google.com/project/amrutha-academy/settings/general
        // 2. Scroll to "Your apps" section
        // 3. If no Web app exists, click "Add app" → Select Web (</>)
        // 4. Register the app and copy the "appId" from the config
        // 5. Replace "YOUR_WEB_APP_ID" below with the actual appId
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyBQ1x6bwLTxKn3WGHtTc3ClD451JiSuciw",
            appId: "1:349596859394:web:8038398eb110ef689c7b1b",
            messagingSenderId: "349596859394",
            projectId: "amrutha-academy",
            authDomain: "amrutha-academy.firebaseapp.com",
            storageBucket: "amrutha-academy.firebasestorage.app",
            databaseURL: "https://amrutha-academy-default-rtdb.firebaseio.com",
          ),
        );
      } else {
        // For mobile platforms, use default initialization
        await Firebase.initializeApp();
      }
      
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

