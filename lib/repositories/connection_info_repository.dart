import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fd_dart/fd_dart.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';

abstract class IConnectionInfoRepository extends Disposable {
  Future<ConnectionInfo> addRoom(ConnectionInfo room);
  Future<void> deleteRoom(ConnectionInfo room);
  Future<ConnectionInfo> updateRoom(ConnectionInfo room);
  Future<ConnectionInfo> getRoomById(String id);
  Stream<ConnectionInfo?> roomSnapshots(String id);
}

class FirestoreConnectionInfoRepository implements IConnectionInfoRepository {
  final _collection = FirebaseFirestore.instance.collection('rooms');

  @override
  Future<ConnectionInfo> addRoom(ConnectionInfo room) async {
    final ref = _collection.doc(room.id!);
    final data = room.toMap();
    data['timestamp'] = FieldValue.serverTimestamp();
    await ref.set(data);
    return room;
  }

  @override
  Future<void> deleteRoom(ConnectionInfo room) async {
    final ref = _collection.doc(room.id!);
    await ref.delete();
  }

  @override
  Future<ConnectionInfo> updateRoom(ConnectionInfo room) async {
    addRoom(room);
    return room;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>> _getRoomSnapshot(
      String id) async {
    final room =
        await _collection.where(FieldPath.documentId, isEqualTo: id).get();
    return room.docs.first;
  }

  @override
  Future<ConnectionInfo> getRoomById(String id) async {
    final snapshot = await _getRoomSnapshot(id);
    return ConnectionInfo.fromMap(snapshot.data())..id = id;
  }

  @override
  Stream<ConnectionInfo?> roomSnapshots(String id) {
    return _collection.doc(id).snapshots().map((snapshot) =>
        snapshot.data() != null
            ? ConnectionInfo.fromMap(snapshot.data()!)
            : null);
  }

  @override
  void dispose() {}
}
