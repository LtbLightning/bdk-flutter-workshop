# Instructions

## Starting point

### Head start

To implement a complete app including UI components, state management, controllers, repositories etc. we would need a lot more time and it would take us too far from the Bitcoin and `bdk_flutter` specific code. Therefore you get a head start. All needed widgets, screens, entities, view_models, repositories, controllers and state classes are already implemented and ready for you.

Take a look at the different files and folders in the [`lib`](./lib/) folder. This is the folder where the code of a Flutter/Dart app should be located.

> [!NOTE]
> The minSdkVersion in the [`android/app/build.gradle`](./android/app/build.gradle) file is also changed to 23 already. This is the minimum version required by the `bdk_flutter` package to work on Android.

### Run the app

Start the app to make sure the provided code is working. You should see the user interface of the app, but it is based on hardcoded data and does not really permits you to make any transactions.

### Wallet service

In the [`lib/services/wallets`](./lib/services/wallets) folder you can find the `wallet_service.dart` file. It provides an abstract `WalletService` class with the main functions a wallet service needs. In the [`impl`](./lib/services/wallets/impl/) folder a class `BitcoinWalletService` is provided to add concrete implementations of those functions for a Bitcoin on-chain wallet. We have left some code out of the `BitcoinWalletService` class. The goal of the workshop is for you to complete it yourself.
