class CustomerError implements Exception {
  final String message;
  CustomerError(this.message);

  @override
  String toString() => 'CustomerError: $message';
}
