import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class DataTransceiver {
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener);

  void sendData(String data);
}

enum ConnectionState { connected, disconnected }

abstract class AbstractConnectionService implements DataTransceiver {
  AbstractConnectionService();

  void Function()? _onConnectedListener;
  void Function()? _onDisconnectedListener;
  void Function(String data)? _onReceiveDataListener;
  RTCDataChannel? dataChannel;
  ConnectionState _connectionState = ConnectionState.disconnected;

  @override
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener) {
    _onReceiveDataListener = onReceiveDataListener;

    dataChannel!.onMessage = (data) {
      _onReceiveDataListener!(data.text);
    };
  }

  @override
  void sendData(String data) {
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

  void setOnConnectedListener(void Function() onConnectedListener) {
    _onConnectedListener = onConnectedListener;
  }

  void setOnDisconnectedListener(void Function() onDisconnectedListener) {
    _onDisconnectedListener = onDisconnectedListener;
  }
}
