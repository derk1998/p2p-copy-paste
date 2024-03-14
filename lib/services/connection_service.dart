import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class DataTransceiver {
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener);

  void sendData(String data);
}

abstract class AbstractConnectionService implements DataTransceiver {
  AbstractConnectionService();

  void Function()? _onConnectedListener;
  void Function(String data)? _onReceiveDataListener;
  RTCDataChannel? dataChannel;

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
    if (_onConnectedListener != null) {
      _onConnectedListener!.call();
    }
  }

  void setOnConnectedListener(void Function() onConnectedListener) {
    _onConnectedListener = onConnectedListener;
  }
}
