import 'package:flutter/material.dart';

class PushNotificationMessage {
  final String title;
  final String body;
  final String notificationType;
  PushNotificationMessage(
      {@required this.title,
      @required this.body,
      @required this.notificationType});
}
