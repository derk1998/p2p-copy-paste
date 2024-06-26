import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

T? cast<T>(x) => x is T ? x : null;

class Invite {
  Invite({
    required this.creator,
    this.joiner,
    this.timestamp,
    this.acceptedByCreator,
    this.acceptedByJoiner,
  });

  String creator;
  String? joiner;
  DateTime? timestamp;
  bool? acceptedByCreator;
  bool? acceptedByJoiner;

  Invite.fromMap(Map<String, dynamic> data) : creator = data['creator'] {
    if (data.containsKey('joiner')) {
      joiner = data['joiner'];
    }

    if (data.containsKey('timestamp')) {
      final tmp = cast<Timestamp>(data['timestamp']);
      if (tmp != null) {
        timestamp = tmp.toDate();
      } else {
        final tmp = cast<DateTime>(data['timestamp']);
        if (tmp != null) {
          timestamp = tmp;
        }
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

class JoinerInvite extends Invite {
  JoinerInvite.fromInvite(Invite invite)
      : super(
            creator: invite.creator,
            joiner: invite.joiner,
            acceptedByCreator: invite.acceptedByCreator,
            acceptedByJoiner: invite.acceptedByJoiner);

  void accept() {
    acceptedByJoiner = true;
  }
}

class CreatorInvite extends Invite {
  CreatorInvite.fromInvite(Invite invite)
      : super(
            creator: invite.creator,
            joiner: invite.joiner,
            acceptedByCreator: invite.acceptedByCreator,
            acceptedByJoiner: invite.acceptedByJoiner);

  void accept() {
    acceptedByCreator = true;
  }

  void decline() {
    acceptedByCreator = false;
  }
}
