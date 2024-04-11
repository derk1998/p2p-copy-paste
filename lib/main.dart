import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/firebase_options.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/screens/startup.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/view_models/home.dart';
import 'package:p2p_copy_paste/view_models/login.dart';
import 'package:p2p_copy_paste/view_models/startup.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  getIt.registerSingleton<INavigator>(NavigationManager());

  final inviteRepository = FirestoreInviteRepository();
  final connectionInfoRepository = FirestoreConnectionInfoRepository();

  getIt.registerSingleton<IAuthenticationService>(
      FirebaseAuthenticationService());
  getIt
      .registerLazySingleton<ICreateInviteService>(() => CreateInviteService());
  getIt.registerLazySingleton<ICreateConnectionService>(
      () => CreateConnectionService(connectionInfoRepository));
  getIt.registerLazySingleton<IClipboardService>(() => ClipboardService());
  getIt.registerLazySingleton<IJoinConnectionService>(() =>
      JoinConnectionService(
          connectionInfoRepository: connectionInfoRepository));
  getIt.registerLazySingleton<IJoinInviteService>(() => JoinInviteService(
      authenticationService: getIt.get<IAuthenticationService>(),
      inviteRepository: inviteRepository));
  getIt.registerLazySingleton<IFileService>(() => FileService());

  runApp(P2PCopyPaste(serviceLocator: getIt));
}

class P2PCopyPaste extends StatelessWidget {
  const P2PCopyPaste({super.key, required this.serviceLocator});

  final GetIt serviceLocator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'P2P Copy Paste',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        navigatorKey: getIt.get<INavigator>().getNavigatorKey(),
        home: StartupScreen(
          viewModel: StartupScreenViewModel(
            authenticationService: getIt.get<IAuthenticationService>(),
            homeScreenViewModel: HomeScreenViewModel(GetIt.I),
            loginScreenViewModel: LoginScreenViewModel(
                authenticationService: getIt.get<IAuthenticationService>(),
                fileService: getIt.get<IFileService>(),
                navigator: getIt.get<INavigator>()),
          ),
        ));
  }
}
