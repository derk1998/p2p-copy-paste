import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/ice_server_configuration.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/use_cases/close_connection.dart';

class JoinConnectionService extends AbstractConnectionService
    implements CloseConnectionUseCase {
  JoinConnectionService(this.ref);

  final Ref ref;
  ConnectionInfo? _connectionInfo;
  RTCPeerConnection? _peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;

  void Function()? _onConnectionClosedListener;

  Future<void> joinConnection(String connectionId) async {
    if (_subscription != null) {
      await _subscription!.cancel();
    }

    //signaling
    _connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .getRoomById(connectionId);

    //local config
    _peerConnection = await createPeerConnection(iceServerConfiguration);

    _peerConnection!.onDataChannel = (channel) {
      setDataChannel(channel);

      channel.onDataChannelState = (state) {
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          //Workaround for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
          if (_onConnectionClosedListener != null) {
            _onConnectionClosedListener!.call();
          }
        }

        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          callOnConnectedListener();
        }
      };

      //When the peer is disconnected due to closing the app
      _peerConnection!.onIceConnectionState = (state) {
        if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          _onConnectionClosedListener?.call();
        }
      };

      //Works on android
      //not for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
      _peerConnection!.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed &&
            _onConnectionClosedListener != null) {
          _onConnectionClosedListener!.call();
        }
      };
    };

    _peerConnection!.onIceCandidate = (candidate) {
      _connectionInfo!.addIceCandidateB(candidate);
      ref.read(connectionInfoRepositoryProvider).updateRoom(_connectionInfo!);
    };

    _peerConnection!.setRemoteDescription(_connectionInfo!.offer!);

    _subscription = ref
        .read(connectionInfoRepositoryProvider)
        .roomSnapshots(_connectionInfo!.id!)
        .listen((snapshot) {
      if (_connectionInfo!.iceCandidatesA.isNotEmpty) {
        for (final iceCandidate in _connectionInfo!.iceCandidatesA) {
          _peerConnection!.addCandidate(iceCandidate);
        }
      }
    });

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    //signaling
    _connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .updateRoom(
            ConnectionInfo.join(id: _connectionInfo!.id!, answer: answer));
  }

  //todo: move to base
  @override
  void close() async {
    if (_peerConnection != null) {
      await _peerConnection!.close();
    }
  }

  @override
  void setOnConnectionClosedListener(
      void Function() onConnectionClosedListener) {
    _onConnectionClosedListener = onConnectionClosedListener;
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
JoinConnectionService? _connectionService;

final joinConnectionServiceProvider = Provider<JoinConnectionService>((ref) {
  _connectionService ??= JoinConnectionService(ref);
  return _connectionService!;
});
