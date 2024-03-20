import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:bdk_flutter_workshop/features/home/home_controller.dart';
import 'package:bdk_flutter_workshop/features/home/home_state.dart';
import 'package:bdk_flutter_workshop/features/wallet_actions/wallet_actions_bottom_sheet.dart';
import 'package:bdk_flutter_workshop/services/wallets/wallet_service.dart';
import 'package:bdk_flutter_workshop/widgets/transaction_list.dart';
import 'package:bdk_flutter_workshop/widgets/wallet_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeState _state = const HomeState();
  late HomeController _controller;

  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      getState: () => _state,
      updateState: (HomeState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refresh();
        },
        child: ListView(
          children: [
            SizedBox(
              height: Sizes.p192,
              child: WalletCardList(
                _state.walletCard,
                onAddNewWallet: _controller.addNewWallet,
                onDeleteWallet: _controller.deleteWallet,
              ),
            ),
            TransactionList(
              transactions: _state.transactions ?? [],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => WalletActionsBottomSheet(
            bitcoinWalletService: widget.bitcoinWalletService,
          ),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
      ),
    );
  }
}
