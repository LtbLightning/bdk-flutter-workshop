# Solutions

Here you can find the completed functions for the `BitcoinWalletService` class. If you get stuck, take a look at the solutions to get an idea of how to proceed or compare your solution with the provided one. Of course in software development there are many ways to code a solution, so your solution might look different from the provided one and still be correct.

## 1. Generate a new private key

```dart
@override
Future<void> addWallet() async {
    // 1. Replace the hardcoded test mnemonic with the code to create a new
    //   mnemonic with 12 words every time this function is called.
    final mnemonic = await Mnemonic.create(WordCount.Words12);

    await _mnemonicRepository.setMnemonic(mnemonic.asString());

    await _initWallet(mnemonic);

    print(
        'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!',
    );
}
```

## 2-5. Initialize a BIP84 (Native SegWit) wallet

```dart
Future<void> _initWallet(Mnemonic mnemonic) async {
    // 2. Create the master secret key from the mnemonic
    final secretKey = await DescriptorSecretKey.create(
      network: Network.Signet,
      mnemonic: mnemonic,
    );

    // 3. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive external funds (external keychain)
    final receivingDescriptor = await Descriptor.newBip84(
      secretKey: secretKey,
      network: Network.Signet,
      keychain: KeychainKind.External,
    );
    // 4. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive change (internal keychain)
    final changeDescriptor = await Descriptor.newBip84(
      secretKey: secretKey,
      network: Network.Signet,
      keychain: KeychainKind.Internal,
    );

    // 5. Create a `Wallet` instance with the descriptors to initialize the `_wallet` field
    //  Use an in-memory database for testing purposes.
    _wallet = await Wallet.create(
      descriptor: receivingDescriptor,
      changeDescriptor: changeDescriptor,
      network: Network.Signet,
      databaseConfig: const DatabaseConfig
          .memory(),
    );
}
```

## 6. Initialize a Blockchain data source

```dart
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
```

## 7. Sync the wallet

```dart
@override
Future<void> sync() async {
    if (!hasWallet) return;

    // 7. Sync the wallet with the blockchain
    await _wallet!.sync(_blockchain);
}
```

## 8. Get the spendable balance

```dart
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
```

## 9. Generate a new address

```dart
@override
Future<String> generateInvoice() async {
    // 9. Get a new unused address from the wallet and return it as a String.
    final invoice = await _wallet!.getAddress(
      addressIndex: const AddressIndex(),
    );

    return invoice.address;
}
```

## 10. Get the transaction history

```dart
@override
Future<List<TransactionEntity>> getTransactions() async {
    // 10. Get the list of transactions from the wallet and return them as a list of `TransactionEntity` instances.
    final transactions = await _wallet!.listTransactions(false);

    return transactions.map((tx) {
      return TransactionEntity(
        id: tx.txid,
        receivedAmountSat: tx.received,
        sentAmountSat: tx.sent,
        timestamp: tx.confirmationTime?.timestamp,
      );
    }).toList();
}
```

## 11-21. Pay to an address

```dart
@override
Future<String> pay(
String invoice, {
required int amountSat,
double? satPerVbyte,
int? absoluteFeeSat,
}) async {
    // 11. Convert the invoice String to a BDK Address type
    final address = await Address.create(address: invoice);

    // 12. Use the address to get the script that would lock a transaction output to the address
    final script = await address
        .scriptPubKey(); // Creates the output scripts so that the wallet that generated the address can spend the funds

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
    final txBuilderResult = await txBuilder.finish(_wallet!);

    // 18. Sign the transaction with the wallet
    final sbt = await _wallet!.sign(psbt: txBuilderResult.psbt);

    // 19. Extract the transaction as bytes from the finalized and signed PSBT
    final tx = await sbt.extractTx();

    // 20. Broadcast the transaction to the network with the `Blockchain` instance
    await _blockchain.broadcast(tx);

    // 21. Return the transaction id
    return tx.txid();
}
```
