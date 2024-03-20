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
      print('Wallet with mnemonic $mnemonic found, initialized and synced!');
    } else {
      print('No wallet found!');
    }
  }

  @override
  bool get hasWallet => _wallet != null;

  @override
  Future<void> addWallet() async {
    final mnemonic = await Mnemonic.create(WordCount.Words12);
    await _mnemonicRepository.setMnemonic(mnemonic.asString());
    await _initWallet(mnemonic);
    print(
        'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!');
  }

  @override
  Future<void> deleteWallet() async {
    await _mnemonicRepository.deleteMnemonic();
    _wallet = null;
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (!hasWallet) return 0;

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
    await _wallet!.sync(_blockchain);
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

  Future<void> _initBlockchain() async {
    _blockchain = await Blockchain.create(
      config: const BlockchainConfig.esplora(
        config: EsploraConfig(
          baseUrl: 'https://mutinynet.com/api/',
          stopGap: 10,
        ),
      ),
    );
  }

  Future<void> _initWallet(Mnemonic mnemonic) async {
    // Create the master secret key from the mnemonic
    final secretKey = await DescriptorSecretKey.create(
      network: Network.Signet,
      mnemonic: mnemonic,
    );

    // Get BIP84 template descriptors to derive Native SegWit addresses from the secret key
    final receivingDescriptor = await Descriptor.newBip84(
      secretKey: secretKey,
      network: Network.Signet,
      keychain: KeychainKind.External,
    );
    final changeDescriptor = await Descriptor.newBip84(
      secretKey: secretKey,
      network: Network.Signet,
      keychain: KeychainKind.Internal,
    );

    // Create the wallet with the descriptors
    _wallet = await Wallet.create(
      descriptor: receivingDescriptor,
      changeDescriptor: changeDescriptor,
      network: Network.Signet,
      databaseConfig: const DatabaseConfig
          .memory(), // Txs and UTXOs related to the wallet will be stored in memory
    );
  }
}
