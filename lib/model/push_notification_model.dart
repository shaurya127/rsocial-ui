import 'package:flutter/material.dart';

enum NotificationType { Post, Profile }

class PushNotificationMessage {
  final String title;
  final String body;
  final NotificationType notificationType;
  final String id;
  PushNotificationMessage(
      {@required this.title,
      @required this.body,
      @required this.notificationType,
      @required this.id});
}
