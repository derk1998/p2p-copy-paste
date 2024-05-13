import 'dart:developer';

import 'package:fd_dart/fd_dart.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/join/services/join_connection.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';

abstract class ISystemManager {
  void addCreateInviteServiceListener(
      Listener<void Function(WeakReference<ICreateInviteService>)> listener);

  void removeCreateInviteServiceListener(WeakReference<Context> context);

  void addCreateConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener);

  void removeCreateConnectionServiceListener(WeakReference<Context> context);

  void addJoinInviteServiceListener(
      Listener<void Function(WeakReference<IJoinInviteService>)> listener);

  void removeJoinInviteServiceListener(WeakReference<Context> context);

  void addJoinConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener);

  void removeJoinConnectionServiceListener(WeakReference<Context> context);

  void addAuthenticationServiceListener(
      Listener<void Function(WeakReference<IAuthenticationService>)> listener);

  void removeAuthenticationServiceListener(WeakReference<Context> context);

  void addFileServiceListener(
      Listener<void Function(WeakReference<IFileService>)> listener);

  void removeFileServiceListener(WeakReference<Context> context);

  void addClipboardServiceListener(
      Listener<void Function(WeakReference<IClipboardService>)> listener);

  void removeClipboardServiceListener(WeakReference<Context> context);
}

class SystemManager extends ISystemManager {
  final _authenticationService =
      ConditionalObject<FirebaseAuthenticationService>(
          (List<dynamic>? dependencies) {
    log('Creating authentication service...');

    return FirebaseAuthenticationService();
  });

  final _inviteRepository = ConditionalObject<FirestoreInviteRepository>(
      (List<dynamic>? dependencies) {
    log('Creating invite repository...');

    return FirestoreInviteRepository();
  });

  final _connectionInfoRepository =
      ConditionalObject<FirestoreConnectionInfoRepository>(
          (List<dynamic>? dependencies) {
    log('Creating connection info repository...');

    return FirestoreConnectionInfoRepository();
  });

  final _fileService =
      ConditionalObject<FileService>((List<dynamic>? dependencies) {
    log('Creating file service...');
    return FileService();
  });

  final _clipboardService =
      ConditionalObject<ClipboardService>((List<dynamic>? dependencies) {
    log('Creating clipboard service...');
    return ClipboardService();
  });

  late ConditionalObject<CreateInviteService> _createInviteService;
  late ConditionalObject<CreateConnectionService> _createConnectionService;
  late ConditionalObject<JoinInviteService> _joinInviteService;
  late ConditionalObject<JoinConnectionService> _joinConnectionService;

  SystemManager() {
    _createInviteService =
        ConditionalObject<CreateInviteService>((dependencies) {
      log('Creating create invite service...');
      return CreateInviteService(
          authenticationService: dependencies![0],
          inviteRepository: dependencies[1]);
    }, dependencies: [_authenticationService, _inviteRepository]);

    _createConnectionService =
        ConditionalObject<CreateConnectionService>((dependencies) {
      log('Creating create connection service...');
      return CreateConnectionService(
          connectionInfoRepository: dependencies![0]);
    }, dependencies: [_connectionInfoRepository]);

    _joinInviteService = ConditionalObject<JoinInviteService>((dependencies) {
      log('Creating join invite service...');
      return JoinInviteService(
        authenticationService: dependencies![0],
        inviteRepository: dependencies[1],
      );
    }, dependencies: [_authenticationService, _inviteRepository]);

    _joinConnectionService =
        ConditionalObject<JoinConnectionService>((dependencies) {
      log('Creating join connection service...');
      return JoinConnectionService(connectionInfoRepository: dependencies![0]);
    }, dependencies: [_connectionInfoRepository]);
  }

  @override
  void addClipboardServiceListener(
      Listener<void Function(WeakReference<IClipboardService>)> listener) {
    _clipboardService.addListener(listener);
  }

  @override
  void removeClipboardServiceListener(WeakReference<Context> context) {
    _clipboardService.removeListener(context);
  }

  @override
  void addFileServiceListener(
      Listener<void Function(WeakReference<IFileService>)> listener) {
    _fileService.addListener(listener);
  }

  @override
  void removeFileServiceListener(WeakReference<Context> context) {
    _fileService.removeListener(context);
  }

  @override
  void addAuthenticationServiceListener(
      Listener<void Function(WeakReference<IAuthenticationService>)> listener) {
    log('Add authentication service listener');

    _authenticationService.addListener(listener);
  }

  @override
  void removeAuthenticationServiceListener(WeakReference<Context> context) {
    _authenticationService.removeListener(context);
  }

  @override
  void addCreateInviteServiceListener(
      Listener<void Function(WeakReference<ICreateInviteService>)> listener) {
    _createInviteService.addListener(listener);
  }

  @override
  void removeCreateInviteServiceListener(WeakReference<Context> context) {
    _createInviteService.removeListener(context);
  }

  @override
  void addCreateConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener) {
    _createConnectionService.addListener(listener);
  }

  @override
  void removeCreateConnectionServiceListener(WeakReference<Context> context) {
    _createConnectionService.removeListener(context);
  }

  @override
  void addJoinInviteServiceListener(
      Listener<void Function(WeakReference<IJoinInviteService>)> listener) {
    _joinInviteService.addListener(listener);
  }

  @override
  void removeJoinInviteServiceListener(WeakReference<Context> context) {
    _joinInviteService.removeListener(context);
  }

  @override
  void addJoinConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener) {
    _joinConnectionService.addListener(listener);
  }

  @override
  void removeJoinConnectionServiceListener(WeakReference<Context> context) {
    _joinConnectionService.removeListener(context);
  }
}
