import 'package:flutter_webrtc/flutter_webrtc.dart';

class ConnectionInfo {
  ConnectionInfo({this.offer, this.id});

  ConnectionInfo.create({required this.offer});
  ConnectionInfo.join({required this.id, required this.answer});

  void setOffer(RTCSessionDescription offer) {
    this.offer = offer;
  }

  RTCSessionDescription? offer;
  RTCSessionDescription? answer;
  final List<RTCIceCandidate> iceCandidates = [];

  String? id;
  String? visitor;

  void addIceCandidate(RTCIceCandidate candidate) {
    iceCandidates.add(candidate);
  }

  ConnectionInfo.fromMap(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      if (entry.key == 'offer') {
        offer = RTCSessionDescription(entry.value['sdp'], entry.value['type']);
      } else if (entry.key == 'answer') {
        answer = RTCSessionDescription(entry.value['sdp'], entry.value['type']);
      } else if (entry.key == 'ice_candidates') {
        for (final value in entry.value as List<dynamic>) {
          addIceCandidate(RTCIceCandidate(
              value['candidate'], value['sdpMid'], value['sdpMLineIndex']));
        }
      }
    }

    if (data.containsKey('visitor')) {
      visitor = data['visitor'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (offer != null) 'offer': offer?.toMap(),
      if (answer != null) 'answer': answer?.toMap(),
      'ice_candidates':
          iceCandidates.map((candidate) => candidate.toMap()).toList(),
      if (visitor != null) 'visitor': visitor,
    };
  }
}
