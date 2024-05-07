import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/firebase_options.dart';
import 'package:p2p_copy_paste/main_flow.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/screens/flow.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/view_models/flow.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  getIt.registerSingleton<INavigator>(NavigationManager());

  final inviteRepository = FirestoreInviteRepository();
  final connectionInfoRepository = FirestoreConnectionInfoRepository();

  getIt.registerLazySingleton<IInviteRepository>(() => inviteRepository);
  getIt.registerLazySingleton<IConnectionInfoRepository>(
      () => connectionInfoRepository);

  getIt.registerSingleton<IAuthenticationService>(
      FirebaseAuthenticationService());

  runApp(P2PCopyPaste(serviceLocator: getIt));
}

class P2PCopyPaste extends StatelessWidget {
  const P2PCopyPaste({super.key, required this.serviceLocator});

  final GetIt serviceLocator;
  final String title = 'P2P Copy Paste';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: getIt.get<INavigator>().getNavigatorKey(),
      home: FlowScreen(
          viewModel: FlowScreenViewModel(MainFlow(
              fileService: FileService(),
              clipboardService: ClipboardService(),
              connectionInfoRepository: getIt.get<IConnectionInfoRepository>(),
              inviteRepository: getIt.get<IInviteRepository>(),
              navigator: getIt.get<INavigator>(),
              authenticationService: getIt.get<IAuthenticationService>()))),
    );
  }
}
