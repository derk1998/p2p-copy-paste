abstract class CloseConnectionUseCase {
  void close();

  void setOnConnectionClosedListener(
      void Function() onConnectionClosedListener);
}
