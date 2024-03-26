mixin LifeTime {
  bool get expired {
    return _expired;
  }

  void expire() {
    _expired = true;
    _onExpiringListener?.call();
  }

  void setOnExpiringListener(void Function() onExpiringListener) {
    _onExpiringListener = onExpiringListener;
  }

  bool _expired = false;
  void Function()? _onExpiringListener;
}
