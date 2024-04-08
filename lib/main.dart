import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/screens/startup.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';
import 'package:p2p_copy_paste/services/firebase_storage.dart';
import 'package:p2p_copy_paste/services/storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<IStorageService>(FirebaseStorageService());
  getIt.registerSingleton<IAuthenticationService>(
      FirebaseAuthenticationService());

  await getIt.get<IStorageService>().initialize();

  runApp(const P2PCopyPaste());
}

class P2PCopyPaste extends StatelessWidget {
  const P2PCopyPaste({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      title: 'P2P Copy Paste',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartupScreen(),
    ));
  }
}
