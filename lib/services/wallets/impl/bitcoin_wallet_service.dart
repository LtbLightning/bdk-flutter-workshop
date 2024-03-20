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
  Future<int> getSpendableBalanceSat() async {
    if (!hasWallet) return 0;

    // 8. Get the balance of the wallet and return the spendable part of it.
    //  For testing purposes, you can just print out the other parts of the balance as well.
    return 0;
  }

  @override
  Future<String> generateInvoice() async {
    final invoice = await _wallet!.getAddress(
      addressIndex: const AddressIndex(),
    );

    return invoice.address;
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final transactions = await _wallet!.listTransactions(true);

    return transactions.map((tx) {
      return TransactionEntity(
        id: tx.txid,
        receivedAmountSat: tx.received,
        sentAmountSat: tx.sent,
        timestamp: tx.confirmationTime?.timestamp,
      );
    }).toList();
  }

  @override
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  }) async {
    if (amountSat == null) {
      throw Exception('Amount is required for a bitcoin on-chain transaction!');
    }

    // Convert the invoice to an address
    final address = await Address.create(address: invoice);
    final script = await address
        .scriptPubKey(); // Creates the output scripts so that the wallet that generated the address can spend the funds
    var txBuilder = TxBuilder().addRecipient(script, amountSat);

    // Set the fee rate for the transaction
    if (satPerVbyte != null) {
      txBuilder = txBuilder.feeRate(satPerVbyte);
    } else if (absoluteFeeSat != null) {
      txBuilder = txBuilder.feeAbsolute(absoluteFeeSat);
    }

    final txBuilderResult = await txBuilder.finish(_wallet!);
    final sbt = await _wallet!.sign(psbt: txBuilderResult.psbt);
    final tx = await sbt.extractTx();
    await _blockchain.broadcast(tx);

    return tx.txid();
  }

  @override
  Future<void> sync() async {
    if (!hasWallet) return;

    // 7. Sync the wallet with the blockchain
  }

  Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    final [highPriority, mediumPriority, lowPriority, noPriority] =
        await Future.wait(
      [
        _blockchain.estimateFee(5),
        _blockchain.estimateFee(144),
        _blockchain.estimateFee(504),
        _blockchain.estimateFee(1008),
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
