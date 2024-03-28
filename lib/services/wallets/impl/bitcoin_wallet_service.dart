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
    final mnemonic = await Mnemonic.create(WordCount.words12);

    await _mnemonicRepository.setMnemonic(
      await mnemonic.asString(),
    );

    await _initWallet(mnemonic);

    print(
      'Wallet added with mnemonic: ${await mnemonic.asString()} and initialized!',
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
    await _wallet!.sync(
      blockchain: _blockchain,
    );
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (!hasWallet) return 0;

    // 8. Get the balance of the wallet and return the spendable part of it.
    //  For testing purposes, you can just print out the other parts of the balance as well.
    final balance = await _wallet!.getBalance();

    print('Confirmed balance: ${balance.confirmed}');
    print('Spendable balance: ${balance.spendable}');
    print('Unconfirmed balance: ${balance.immature}');
    print('Trusted pending balance: ${balance.trustedPending}');
    print('Pending balance: ${balance.untrustedPending}');
    print('Total balance: ${balance.total}');

    return balance.spendable;
  }

  @override
  Future<String> generateInvoice() async {
    // 9. Get a new unused address from the wallet and return it as a String.
    final invoice = await _wallet!.getAddress(
      addressIndex: const AddressIndex.increase(),
    );

    return invoice.address;
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    // 10. Get the list of transactions from the wallet and return them as a list of `TransactionEntity` instances.
    final transactions = await _wallet!.listTransactions(includeRaw: false);

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
    required int amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  }) async {
    // 11. Convert the invoice String to a BDK Address type
    final address = await Address.fromString(
      s: invoice,
      network: Network.signet,
    );

    // 12. Use the address to get the script that would lock a transaction output to the address
    final script = await address
        .scriptPubkey(); // Creates the output scripts so that the wallet that generated the address can spend the funds

    // 13. Initialize a `TxBuilder` instance.
    final txBuilder = TxBuilder();

    // 14. Add the recipient and the amount to send to the transaction builder.
    txBuilder.addRecipient(script, amountSat);

    // 15. Set the fee rate for the transaction based on the provided fee rate or absolute fee on the transaction builder.
    if (satPerVbyte != null) {
      txBuilder.feeRate(satPerVbyte);
    } else if (absoluteFeeSat != null) {
      txBuilder.feeAbsolute(absoluteFeeSat);
    }

    // 16. Enable RBF (Replace-By-Fee) on the transaction builder
    txBuilder.enableRbf();

    // 17. Finish the transaction building
    final (psbt, _) = await txBuilder.finish(_wallet!);

    // 18. Sign the transaction with the wallet
    await _wallet!.sign(psbt: psbt);

    // 19. Extract the transaction as bytes from the finalized and signed PSBT
    final tx = await psbt.extractTx();

    // 20. Broadcast the transaction to the network with the `Blockchain` instance,
    //  this should return the transaction id.
    final txId = await _blockchain.broadcast(transaction: tx);

    print('Transaction broadcasted: $txId');

    return txId;
  }

  Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    final [highPriority, mediumPriority, lowPriority, noPriority] =
        await Future.wait(
      [
        _blockchain.estimateFee(target: 1),
        _blockchain.estimateFee(target: 2),
        _blockchain.estimateFee(target: 3),
        _blockchain.estimateFee(target: 4),
      ],
    );

    return RecommendedFeeRatesEntity(
      highPriority: highPriority.satPerVb,
      mediumPriority: mediumPriority.satPerVb,
      lowPriority: lowPriority.satPerVb,
      noPriority: noPriority.satPerVb,
    );
  }

  Future<void> _initWallet(Mnemonic mnemonic) async {
    // 2. Create the master secret key from the mnemonic
    final secretKey = await DescriptorSecretKey.create(
      network: Network.signet,
      mnemonic: mnemonic,
    );

    // 3. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive external funds (external keychain)
    final receivingDescriptor = await Descriptor.newBip84(
      secretKey: secretKey,
      network: Network.signet,
      keychain: KeychainKind.externalChain,
    );
    // 4. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive change (internal keychain)
    final changeDescriptor = await Descriptor.newBip84(
      secretKey: secretKey,
      network: Network.signet,
      keychain: KeychainKind.internalChain,
    );

    // 5. Create a `Wallet` instance with the descriptors to initialize the `_wallet` field
    //  Use an in-memory database for testing purposes.
    _wallet = await Wallet.create(
      descriptor: receivingDescriptor,
      changeDescriptor: changeDescriptor,
      network: Network.signet,
      databaseConfig: const DatabaseConfig.memory(),
    );
  }

  Future<void> _initBlockchain() async {
    // 6. Initialize the `_blockchain` field by creating a new instance of the
    //  `Blockchain` class and configuring it to use an Esplora server on Signet.
    //  For testing purposes, you can use the following Esplora server url:
    //  https://mutinynet.com/api
    _blockchain = await Blockchain.create(
      config: const BlockchainConfig.esplora(
        config: EsploraConfig(
          baseUrl: 'https://mutinynet.com/api/',
          stopGap: 10,
        ),
      ),
    );
  }
}
