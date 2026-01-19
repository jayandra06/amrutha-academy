// Import Firebase scripts - this will be handled by Flutter's web build
// The service worker needs to be in the web root directory

// Firebase Cloud Messaging Service Worker
// This file handles background push notifications on web platforms

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Firebase configuration (must match firebase_options.dart web config)
const firebaseConfig = {
  apiKey: 'AIzaSyCnsK2ePZBa_iqXa706_BcIBSP-F0SVv70',
  appId: '1:349596859394:web:b83502a2998a28129c7b1b',
  messagingSenderId: '349596859394',
  projectId: 'amrutha-academy',
  authDomain: 'amrutha-academy.firebaseapp.com',
  storageBucket: 'amrutha-academy.firebasestorage.app',
};

// Initialize Firebase in the service worker
firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);
  
  const notificationTitle = payload.notification?.title || 'Amrutha Academy';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new notification',
    icon: payload.notification?.icon || '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.tag || 'notification',
    data: payload.data,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification clicked:', event);
  
  event.notification.close();

  // Focus or open the app
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // If a window is already open, focus it
      for (let client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      // Otherwise, open a new window
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});


