import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

T? cast<T>(x) => x is T ? x : null;

class Invite {
  Invite(this.creator);

  String creator;
  String? joiner;
  DateTime? timestamp;
  bool? acceptedByCreator;
  bool? acceptedByJoiner;

  //todo: maybe split invite in two so joiner doesn't see these weird methods
  void acceptByCreator() {
    acceptedByCreator = true;
  }

  void declineByCreator() {
    acceptedByCreator = false;
  }

  //todo: maybe split invite in two so creator doesn't see this weird method
  void acceptByJoiner() {
    acceptedByJoiner = true;
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

    if (data.containsKey('acceptedByCreator')) {
      acceptedByCreator = data['acceptedByCreator'];
    }

    if (data.containsKey('acceptedByJoiner')) {
      acceptedByJoiner = data['acceptedByJoiner'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'creator': creator,
      if (joiner != null) 'joiner': joiner,
      if (timestamp != null) 'timestamp': timestamp,
      if (acceptedByCreator != null) 'acceptedByCreator': acceptedByCreator,
      if (acceptedByJoiner != null) 'acceptedByJoiner': acceptedByJoiner,
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
