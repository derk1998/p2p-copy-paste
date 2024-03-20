import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/models/invite.dart';

class FirestoreInviteRepository {
  final _collection = FirebaseFirestore.instance.collection('invites');

  Future<Invite> addInvite(Invite invite) async {
    final ref = _collection.doc(invite.creator);
    final data = invite.toMap();
    data['timestamp'] = FieldValue.serverTimestamp();
    await ref.set(data);
    log('Adding invite: ${invite.toMap().toString()}');

    //For setting timestamp on invite
    // final inviteWithTimestamp =
    //     await ref.get(const GetOptions(source: Source.server));
    // return Invite.fromMap(inviteWithTimestamp.data()!);
    return invite;
  }

  Future<Invite> getInvite(String creator) async {
    final ref = _collection.doc(creator);

    final snapshot = await ref.get();
    return Invite.fromMap(snapshot.data()!);
  }

  void updateInvite(Invite invite) async {
    final ref = _collection.doc(invite.creator);
    final data = invite.toMap();
    await ref.set(data);
    log('Updating invite: ${invite.toMap().toString()}');
  }

  Stream<Invite?> snapshots(String creator) {
    return _collection.doc(creator).snapshots().map((snapshot) =>
        snapshot.data() != null ? Invite.fromMap(snapshot.data()!) : null);
  }
}

final invitesRepositoryProvider =
    Provider<FirestoreInviteRepository>((ref) => FirestoreInviteRepository());
