importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCKlhMnCMrsA8NcjR8ao4s0t5h6_EQChYA',
    appId: '1:960807885850:web:c569809eb87aca049b85a3',
    messagingSenderId: '960807885850',
    projectId: 'absensi-ce8e2',
    authDomain: 'absensi-ce8e2.firebaseapp.com',
    storageBucket: 'absensi-ce8e2.firebasestorage.app',
    measurementId: 'G-HTF7SHLD58',
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/icon-192x192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
}); 