import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:campusconnect/core/services/firebase_service.dart';
import 'package:campusconnect/shared/models/user_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseService.messaging;
  String? _fcmToken;

  // Initialize notifications
  Future<void> initializeNotifications() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      print('FCM Token refreshed: $token');
      // TODO: Update token in Firestore
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Show in-app notification
      _showInAppNotification(
        title: notification.title ?? 'Nouvelle notification',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }

  // Handle background messages (static method)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // TODO: Handle background message
  }

  // Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('App opened from notification: ${message.notification?.title}');
    // TODO: Navigate to appropriate screen based on message data
  }

  // Show in-app notification
  void _showInAppNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    // TODO: Implement in-app notification UI
    print('In-app notification: $title - $body');
  }

  // Send notification to specific user
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) return;

      // Create notification payload
      final notificationPayload = {
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data ?? {},
        'token': fcmToken,
      };

      // Send notification via Firebase Cloud Messaging
      // TODO: Implement server-side notification sending
      print('Notification sent to user $userId: $title');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send notification to multiple users
  static Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    for (final userId in userIds) {
      await sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  // Send notification to all users with specific role
  static Future<void> sendNotificationToRole({
    required UserRole role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: role.name)
          .get();

      final userIds = querySnapshot.docs.map((doc) => doc.id).toList();

      await sendNotificationToUsers(
        userIds: userIds,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error sending notification to role: $e');
    }
  }

  // Update user's FCM token
  Future<void> updateUserToken(UserModel user) async {
    if (_fcmToken == null) return;

    try {
      await FirebaseService.firestore
          .collection('users')
          .doc(user.id)
          .update({'fcmToken': _fcmToken});
    } catch (e) {
      print('Error updating user token: $e');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Get current FCM token
  String? get fcmToken => _fcmToken;
}
