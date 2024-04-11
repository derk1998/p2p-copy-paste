import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/screens/startup.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';
import 'package:p2p_copy_paste/services/firebase_storage.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/services/storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<INavigator>(NavigationManager());

  getIt.registerLazySingleton<IInviteRepository>(
      () => FirestoreInviteRepository());

  getIt.registerLazySingleton<IConnectionInfoRepository>(
      () => FirestoreConnectionInfoRepository());

  getIt.registerSingleton<IStorageService>(FirebaseStorageService());
  getIt.registerSingleton<IAuthenticationService>(
      FirebaseAuthenticationService());
  getIt
      .registerLazySingleton<ICreateInviteService>(() => CreateInviteService());
  getIt.registerLazySingleton<ICreateConnectionService>(
      () => CreateConnectionService(FirestoreConnectionInfoRepository()));
  getIt.registerLazySingleton<IClipboardService>(() => ClipboardService());
  getIt.registerLazySingleton<IJoinConnectionService>(() =>
      JoinConnectionService(
          connectionInfoRepository: getIt.get<IConnectionInfoRepository>()));
  getIt.registerLazySingleton<IJoinInviteService>(() => JoinInviteService(
      authenticationService: getIt.get<IAuthenticationService>(),
      inviteRepository: getIt.get<IInviteRepository>()));

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
      navigatorKey: getIt.get<INavigator>().getNavigatorKey(),
      home: const StartupScreen(),
    ));
  }
}
