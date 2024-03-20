# Solutions

Here you can find the completed functions for the `BitcoinWalletService` class. If you get stuck, take a look at the solutions to get an idea of how to proceed or compare your solution with the provided one. Of course in software development there are many ways to code a solution, so your solution might look different from the provided one and still be correct.

## Generate a new private key

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

## Initialize a BIP84 (Native SegWit) wallet

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

## Initialize a Blockchain data source

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

## Sync the wallet

```dart
@override
Future<void> sync() async {
    if (!hasWallet) return;

    // 7. Sync the wallet with the blockchain
    await _wallet!.sync(_blockchain);
}
```

## Get the spendable balance

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
