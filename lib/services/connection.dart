import 'package:flutter_webrtc/flutter_webrtc.dart';

enum ConnectionState { connected, disconnected }

abstract class AbstractConnectionService {
  void Function()? _onConnectedListener;
  void Function()? _onDisconnectedListener;
  void Function(String data)? _onReceiveDataListener;
  RTCDataChannel? dataChannel;
  ConnectionState _connectionState = ConnectionState.disconnected;

  void setOnReceiveDataListenerImpl(
      void Function(String data) onReceiveDataListener) {
    _onReceiveDataListener = onReceiveDataListener;

    dataChannel!.onMessage = (data) {
      _onReceiveDataListener!(data.text);
    };
  }

  void sendDataImpl(String data) {
    dataChannel!.send(RTCDataChannelMessage(data));
  }

  void setDataChannel(RTCDataChannel channel) {
    dataChannel = channel;
  }

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

  void setOnConnectedListenerImpl(void Function() onConnectedListener) {
    _onConnectedListener = onConnectedListener;
  }

  void setOnDisconnectedListener(void Function() onDisconnectedListener) {
    _onDisconnectedListener = onDisconnectedListener;
  }
}
