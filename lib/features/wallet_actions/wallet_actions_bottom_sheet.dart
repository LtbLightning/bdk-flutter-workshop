import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:bdk_flutter_workshop/features/wallet_actions/pay/pay_tab.dart';
import 'package:bdk_flutter_workshop/features/wallet_actions/request/request_tab.dart';
import 'package:bdk_flutter_workshop/services/wallets/wallet_service.dart';
import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({
    required WalletService bitcoinWalletService,
    super.key,
  }) : _bitcoinWalletService = bitcoinWalletService;

  final WalletService _bitcoinWalletService;

  static const List<Tab> actionTabs = <Tab>[
    Tab(
      icon: Icon(Icons.arrow_downward),
      text: 'Request',
    ),
    Tab(
      icon: Icon(Icons.arrow_upward),
      text: 'Pay',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: actionTabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: const [
            CloseButton(),
          ],
          bottom: const TabBar(
            tabs: actionTabs,
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(Sizes.p32),
          child: TabBarView(
            children: [
              RequestTab(
                bitcoinWalletService: _bitcoinWalletService,
              ),
              PayTab(
                bitcoinWalletService: _bitcoinWalletService,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
