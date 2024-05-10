class WeakKey<T extends Object> {
  final WeakReference<T> _ref;

  WeakKey(this._ref);

  @override
  bool operator ==(Object other) {
    return other is WeakKey && _ref.target == other._ref.target;
  }

  @override
  int get hashCode => _ref.target.hashCode;
}
