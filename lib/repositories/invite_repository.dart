import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2p_copy_paste/disposable.dart';
import 'package:p2p_copy_paste/models/invite.dart';

abstract class IInviteRepository extends Disposable {
  Future<Invite> addInvite(Invite invite);
  Future<Invite> getInvite(String creator);
  Future<void> updateInvite(Invite invite);
  Stream<Invite?> snapshots(String creator);
}

class FirestoreInviteRepository extends IInviteRepository {
  final _collection = FirebaseFirestore.instance.collection('invites');

  @override
  Future<Invite> addInvite(Invite invite) async {
    final ref = _collection.doc(invite.creator);
    final data = invite.toMap();
    data['timestamp'] = FieldValue.serverTimestamp();
    await ref.set(data);
    log('Adding invite: ${invite.toMap().toString()}');
    return invite;
  }

  @override
  Future<Invite> getInvite(String creator) async {
    final ref = _collection.doc(creator);

    final snapshot = await ref.get();
    return Invite.fromMap(snapshot.data()!);
  }

  @override
  Future<void> updateInvite(Invite invite) async {
    final ref = _collection.doc(invite.creator);
    final data = invite.toMap();
    await ref.set(data);
    log('Updating invite: ${invite.toMap().toString()}');
  }

  @override
  Stream<Invite?> snapshots(String creator) {
    return _collection.doc(creator).snapshots().map((snapshot) =>
        snapshot.data() != null ? Invite.fromMap(snapshot.data()!) : null);
  }

  @override
  void dispose() {
    log('dispose invite repository');
  }
}
