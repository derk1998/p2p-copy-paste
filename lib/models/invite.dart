import 'package:cloud_firestore/cloud_firestore.dart';

class Invite {
  Invite(this.creator);

  String creator;
  String? joiner;
  DateTime? timestamp;

  Invite.fromMap(Map<String, dynamic> data) : creator = data['creator'] {
    if (data.containsKey('joiner')) {
      joiner = data['joiner'];
    }

    if (data.containsKey('timestamp')) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'creator': creator,
      if (joiner != null) 'joiner': joiner,
      if (timestamp != null) 'timestamp': timestamp
    };
  }
}
