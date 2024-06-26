import 'dart:developer';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/features/clipboard.dart';
import 'package:p2p_copy_paste/features/create.dart';
import 'package:p2p_copy_paste/features/join.dart';
import 'package:p2p_copy_paste/join/services/join_connection.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';

abstract class ISystemManager
    implements ClipboardFeature, CreateFeature, JoinFeature {
  void addAuthenticationServiceListener(
      Listener<void Function(WeakReference<IAuthenticationService>)> listener);

  void removeAuthenticationServiceListener(WeakReference<Context> context);

  void addFileServiceListener(
      Listener<void Function(WeakReference<IFileService>)> listener);

  void removeFileServiceListener(WeakReference<Context> context);
}

class SystemManager extends ISystemManager {
  final _authenticationService =
      ConditionalObject<FirebaseAuthenticationService>(
          (List<dynamic>? dependencies) {
    return FirebaseAuthenticationService();
  });

  final _inviteRepository = ConditionalObject<FirestoreInviteRepository>(
      (List<dynamic>? dependencies) {
    return FirestoreInviteRepository();
  });

  final _connectionInfoRepository =
      ConditionalObject<FirestoreConnectionInfoRepository>(
          (List<dynamic>? dependencies) {
    return FirestoreConnectionInfoRepository();
  });

  final _fileService =
      ConditionalObject<FileService>((List<dynamic>? dependencies) {
    return FileService();
  });

  final _clipboardService =
      ConditionalObject<ClipboardService>((List<dynamic>? dependencies) {
    return ClipboardService();
  });

  late ConditionalObject<CreateInviteService> _createInviteService;
  late ConditionalObject<CreateConnectionService> _createConnectionService;
  late ConditionalObject<JoinInviteService> _joinInviteService;
  late ConditionalObject<JoinConnectionService> _joinConnectionService;

  SystemManager() {
    _createInviteService =
        ConditionalObject<CreateInviteService>((dependencies) {
      return CreateInviteService(
          authenticationService: dependencies![0],
          inviteRepository: dependencies[1]);
    }, dependencies: [_authenticationService, _inviteRepository]);

    _createConnectionService =
        ConditionalObject<CreateConnectionService>((dependencies) {
      return CreateConnectionService(
          connectionInfoRepository: dependencies![0]);
    }, dependencies: [_connectionInfoRepository]);

    _joinInviteService = ConditionalObject<JoinInviteService>((dependencies) {
      return JoinInviteService(
        authenticationService: dependencies![0],
        inviteRepository: dependencies[1],
      );
    }, dependencies: [_authenticationService, _inviteRepository]);

    _joinConnectionService =
        ConditionalObject<JoinConnectionService>((dependencies) {
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
    log('add listener join invite service');

    _joinInviteService.addListener(listener);
  }

  @override
  void removeJoinInviteServiceListener(WeakReference<Context> context) {
    _joinInviteService.removeListener(context);
  }

  @override
  void addJoinConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener) {
    log('add listener join connection service');
    _joinConnectionService.addListener(listener);
  }

  @override
  void removeJoinConnectionServiceListener(WeakReference<Context> context) {
    _joinConnectionService.removeListener(context);
  }
}
