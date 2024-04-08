import 'package:firebase_core/firebase_core.dart';
import 'package:p2p_copy_paste/firebase_options.dart';
import 'package:p2p_copy_paste/services/storage.dart';

class FirebaseStorageService extends IStorageService {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
