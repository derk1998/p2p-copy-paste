import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/firebase_options.dart';
import 'package:p2p_copy_paste/main_flow.dart';
import 'package:p2p_copy_paste/system_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(P2PCopyPaste(
      navigator: NavigationManager(), systemManager: SystemManager()));
}

class P2PCopyPaste extends StatelessWidget {
  const P2PCopyPaste(
      {super.key, required this.navigator, required this.systemManager});

  final String title = 'P2P Copy Paste';
  final INavigator navigator;
  final ISystemManager systemManager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigator.getNavigatorKey(),
      home: FlowScreen(
          viewModel: FlowScreenViewModel(
              MainFlow(systemManager: systemManager, navigator: navigator))),
    );
  }
}
