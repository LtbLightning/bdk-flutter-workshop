import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bdk_flutter_workshop/entities/recommended_fee_rates_entity.dart';
import 'package:bdk_flutter_workshop/entities/transaction_entity.dart';
import 'package:bdk_flutter_workshop/repositories/mnemonic_repository.dart';
import 'package:bdk_flutter_workshop/services/wallets/wallet_service.dart';

class BitcoinWalletService implements WalletService {
  final MnemonicRepository _mnemonicRepository;
  Wallet? _wallet;
  late Blockchain _blockchain;

  BitcoinWalletService({required MnemonicRepository mnemonicRepository})
      : _mnemonicRepository = mnemonicRepository;

  Future<void> init() async {
    print('Initializing BitcoinWalletService...');
    await _initBlockchain();
    print('Blockchain initialized!');

    final mnemonic = await _mnemonicRepository.getMnemonic();
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _initWallet(await Mnemonic.fromString(mnemonic));
      await sync();
      print('Wallet with mnemonic "$mnemonic" found, initialized and synced!');
    } else {
      print('No wallet found!');
    }
  }

  @override
  bool get hasWallet => _wallet != null;

  @override
  Future<void> addWallet() async {
    // 1. Replace the hardcoded test mnemonic with the code to create a new
    //   mnemonic with 12 words every time this function is called.
    final mnemonic = await Mnemonic.fromString(
      'test test test test test test test test test test test test',
    );

    await _mnemonicRepository.setMnemonic(mnemonic.asString());

    await _initWallet(mnemonic);

    print(
      'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!',
    );
  }

  @override
  Future<void> deleteWallet() async {
    await _mnemonicRepository.deleteMnemonic();
    _wallet = null;
  }

  @override
  Future<void> sync() async {
    if (!hasWallet) return;

    // 7. Sync the wallet with the blockchain
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (!hasWallet) return 0;

    // 8. Get the balance of the wallet and return the spendable part of it.
    //  For testing purposes, you can just print out the other parts of the balance as well.
    return 0;
  }

  @override
  Future<String> generateInvoice() async {
    // 9. Get a new unused address from the wallet and return it as a String.

    return '';
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    // 10. Get the list of transactions from the wallet and return them as a list of `TransactionEntity` instances.

    return [];
  }

  @override
  Future<String> pay(
    String invoice, {
    required int amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  }) async {
    // 11. Convert the invoice String to a BDK Address type

    // 12. Use the address to get the script that would lock a transaction output to the address

    // 13. Initialize a `TxBuilder` instance.

    // 14. Add the recipient and the amount to send to the transaction builder.

    // 15. Set the fee rate for the transaction based on the provided fee rate or absolute fee on the transaction builder.

    // 16. Enable RBF (Replace-By-Fee) on the transaction builder

    // 17. Finish the transaction building

    // 18. Sign the transaction with the wallet

    // 19. Extract the transaction as bytes from the finalized and signed PSBT

    // 20. Broadcast the transaction to the network with the `Blockchain` instance

    // 21. Return the transaction id
    return '';
  }

  Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    final [highPriority, mediumPriority, lowPriority, noPriority] =
        await Future.wait(
      [
        _blockchain.estimateFee(1),
        _blockchain.estimateFee(2),
        _blockchain.estimateFee(3),
        _blockchain.estimateFee(4),
      ],
    );

    return RecommendedFeeRatesEntity(
      highPriority: highPriority.asSatPerVb(),
      mediumPriority: mediumPriority.asSatPerVb(),
      lowPriority: lowPriority.asSatPerVb(),
      noPriority: noPriority.asSatPerVb(),
    );
  }

  Future<void> _initWallet(Mnemonic mnemonic) async {
    // 2. Create the master secret key from the mnemonic

    // 3. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive external funds (external keychain)

    // 4. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive change (internal keychain)

    // 5. Create a `Wallet` instance with the descriptors to initialize the `_wallet` field
    //  Use an in-memory database for testing purposes.
  }

  Future<void> _initBlockchain() async {
    // 6. Initialize the `_blockchain` field by creating a new instance of the
    //  `Blockchain` class and configuring it to use an Esplora server on Signet.
    //  For testing purposes, you can use the following Esplora server url:
    //  https://mutinynet.com/api
  }
}
