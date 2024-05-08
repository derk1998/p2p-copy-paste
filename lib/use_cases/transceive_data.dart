import 'package:p2p_copy_paste/disposable.dart';

abstract class TransceiveDataUseCase extends Disposable {
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener);

  void sendData(String data);

  void setOnConnectionClosedListener(
      void Function() onConnectionClosedListener);

  void close();
}
