import 'package:bdk_flutter_workshop/entities/transaction_entity.dart';

abstract class WalletService {
  bool get hasWallet;
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<void> sync();
  Future<int> getSpendableBalanceSat();
  Future<String> generateInvoice();
  Future<List<TransactionEntity>> getTransactions();
  Future<String> pay(
    String invoice, {
    required int amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  });
}
