class TransferDataSingleton {
  static final TransferDataSingleton _instanceTransfer =
      TransferDataSingleton._internal();

  var transData;

  factory TransferDataSingleton() {
    return _instanceTransfer;
  }

  TransferDataSingleton._internal();

}
