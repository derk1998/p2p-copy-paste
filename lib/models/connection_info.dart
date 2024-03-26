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
  final List<RTCIceCandidate> iceCandidatesB = [];
  final List<RTCIceCandidate> iceCandidatesA = [];

  String? id;

  void addIceCandidateB(RTCIceCandidate candidate) {
    iceCandidatesB.add(candidate);
  }

  void addIceCandidateA(RTCIceCandidate candidate) {
    iceCandidatesA.add(candidate);
  }

  ConnectionInfo.fromMap(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      if (entry.key == 'offer') {
        offer = RTCSessionDescription(entry.value['sdp'], entry.value['type']);
      } else if (entry.key == 'answer') {
        answer = RTCSessionDescription(entry.value['sdp'], entry.value['type']);
      } else if (entry.key == 'ice_candidates_b') {
        for (final value in entry.value as List<dynamic>) {
          addIceCandidateB(RTCIceCandidate(
              value['candidate'], value['sdpMid'], value['sdpMLineIndex']));
        }
      } else if (entry.key == 'ice_candidates_a') {
        for (final value in entry.value as List<dynamic>) {
          addIceCandidateA(RTCIceCandidate(
              value['candidate'], value['sdpMid'], value['sdpMLineIndex']));
        }
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (offer != null) 'offer': offer?.toMap(),
      if (answer != null) 'answer': answer?.toMap(),
      'ice_candidates_b':
          iceCandidatesB.map((candidate) => candidate.toMap()).toList(),
      'ice_candidates_a':
          iceCandidatesA.map((candidate) => candidate.toMap()).toList(),
    };
  }
}
