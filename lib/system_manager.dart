import 'dart:async';
import 'dart:developer';

import 'package:p2p_copy_paste/conditional_object.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/join/services/join_connection.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/firebase_authentication.dart';

abstract class ISystemManager {
  Stream<ICreateInviteService> createInviteServiceStream();
  Stream<ICreateConnectionService> createConnectionServiceStream();

  Stream<IJoinInviteService> joinInviteServiceStream();
  Stream<IJoinConnectionService> joinConnectionServiceStream();

  Stream<IAuthenticationService> authenticationServiceStream();

  Stream<IFileService> fileServiceStream();
  Stream<IClipboardService> clipboardServiceStream();
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
  Stream<ICreateInviteService> createInviteServiceStream() {
    return _createInviteService.stream();
  }

  @override
  Stream<ICreateConnectionService> createConnectionServiceStream() {
    return _createConnectionService.stream();
  }

  @override
  Stream<IJoinInviteService> joinInviteServiceStream() {
    return _joinInviteService.stream();
  }

  @override
  Stream<IJoinConnectionService> joinConnectionServiceStream() {
    return _joinConnectionService.stream();
  }

  @override
  Stream<IAuthenticationService> authenticationServiceStream() {
    return _authenticationService.stream();
  }

  @override
  Stream<IClipboardService> clipboardServiceStream() {
    return _clipboardService.stream();
  }

  @override
  Stream<IFileService> fileServiceStream() {
    return _fileService.stream();
  }
}
