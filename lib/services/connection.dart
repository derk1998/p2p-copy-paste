import 'dart:async';
import 'dart:developer';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/ice_server_configuration.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';

enum ConnectionState { connected, disconnected }

abstract class IConnectionService implements Disposable {
  Future<void> connect(String ownUid, String visitor);
  void close();

  void setOnConnectedListener(void Function() onConnectedListener);
  void setOnDisconnectedListener(void Function() onDisconnectedListener);

  Future<void> setVisitor(String ownUid, String visitor);

  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener);

  void sendData(String data);
}

abstract class AbstractConnectionService implements IConnectionService {
  void Function()? _onConnectedListener;
  void Function()? _onDisconnectedListener;
  void Function(String data)? _onReceiveDataListener;

  ConnectionInfo? ownConnectionInfo;
  RTCPeerConnection? _peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;

  RTCDataChannel? _dataChannel;
  ConnectionState _connectionState = ConnectionState.disconnected;
  final WeakReference<IConnectionInfoRepository> connectionInfoRepository;

  AbstractConnectionService({required this.connectionInfoRepository});

  @override
  Future<void> setVisitor(String ownUid, String visitor) async {
    await connectionInfoRepository.target!
        .deleteRoom(ConnectionInfo(id: ownUid));
    await connectionInfoRepository.target!
        .addRoom(ConnectionInfo(id: ownUid)..visitor = visitor);
  }

  @override
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener) {
    _onReceiveDataListener = onReceiveDataListener;

    _dataChannel!.onMessage = (data) {
      _onReceiveDataListener!(data.text);
    };
  }

  @override
  void sendData(String data) {
    _dataChannel!.send(RTCDataChannelMessage(data));
  }

  void setDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;

    channel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelClosed) {
        //Workaround for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
        callOnDisconnectedListener();
      }

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        callOnConnectedListener();
      }
    };
  }

  Future<RTCPeerConnection> setupPeerConnection(
      String ownUid, String peerUid) async {
    _peerConnection = await createPeerConnection(iceServerConfiguration);
    ownConnectionInfo =
        await connectionInfoRepository.target!.getRoomById(ownUid);

    assert(ownConnectionInfo!.visitor != null);

    //When the peer is disconnected due to closing the app
    _peerConnection!.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        callOnDisconnectedListener();
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        _peerConnection!.restartIce();
      }
    };

    _peerConnection!.onIceCandidate = (candidate) async {
      ownConnectionInfo!.addIceCandidate(candidate);
      await connectionInfoRepository.target!.updateRoom(ownConnectionInfo!);
      log('Ice candidate sent');
    };

    //Works on android
    //not for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
    _peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        callOnDisconnectedListener();
      }
    };

    _subscription =
        connectionInfoRepository.target!.roomSnapshots(peerUid).listen(
      (peerConnectionInfo) {
        onPeerConnectionInfoChanged(peerConnectionInfo, _peerConnection!);
      },
    );

    return _peerConnection!;
  }

  Future<void> onPeerConnectionInfoChanged(
      ConnectionInfo? peerConnectionInfo, RTCPeerConnection peerConnection);

  void callOnConnectedListener() {
    if (_connectionState == ConnectionState.disconnected) {
      _onConnectedListener?.call();
      _connectionState = ConnectionState.connected;
    }
  }

  void callOnDisconnectedListener() {
    if (_connectionState == ConnectionState.connected) {
      _onDisconnectedListener?.call();
      _connectionState = ConnectionState.disconnected;
    }
  }

  @override
  void setOnConnectedListener(void Function() onConnectedListener) {
    _onConnectedListener = onConnectedListener;
  }

  @override
  void setOnDisconnectedListener(void Function() onDisconnectedListener) {
    _onDisconnectedListener = onDisconnectedListener;
  }

  @override
  Future<void> close() async {
    await _peerConnection?.close();
  }

  @override
  void dispose() {
    close();
    _onConnectedListener = null;
    _subscription?.cancel();

    _dataChannel?.close();
    _dataChannel?.onDataChannelState = null;
    _dataChannel = null;

    _peerConnection?.onSignalingState = null;
    _peerConnection?.onConnectionState = null;
    _peerConnection?.onIceConnectionState = null;
    _peerConnection?.onIceCandidate = null;
    _peerConnection?.onRenegotiationNeeded = null;
    _peerConnection?.dispose();
    _peerConnection = null;

    ownConnectionInfo = null;
  }
}
