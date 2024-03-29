import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

T? cast<T>(x) => x is T ? x : null;

class Invite {
  Invite(this.creator);

  String creator;
  String? joiner;
  DateTime? timestamp;
  bool? accepted;

  void accept() {
    accepted = true;
  }

  void decline() {
    accepted = false;
  }

  Invite.fromMap(Map<String, dynamic> data) : creator = data['creator'] {
    if (data.containsKey('joiner')) {
      joiner = data['joiner'];
    }

    if (data.containsKey('timestamp')) {
      final tmp = cast<Timestamp>(data['timestamp']);
      if (tmp != null) {
        timestamp = tmp.toDate();
      }
    }

    if (data.containsKey('accepted')) {
      accepted = data['accepted'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'creator': creator,
      if (joiner != null) 'joiner': joiner,
      if (timestamp != null) 'timestamp': timestamp,
      if (accepted != null) 'accepted': accepted,
    };
  }

  String toJson() {
    return json.encode(
      toMap(),
      toEncodable: (object) {
        if (object is DateTime) {
          return object.toIso8601String();
        }
        return object;
      },
    );
  }
}
