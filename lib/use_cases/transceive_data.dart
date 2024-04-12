abstract class TransceiveDataUseCase {
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener);

  void sendData(String data);
}
