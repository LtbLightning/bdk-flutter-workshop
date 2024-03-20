import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:bdk_flutter_workshop/view_models/wallet_card_view_model.dart';
import 'package:bdk_flutter_workshop/widgets/new_wallet_card.dart';
import 'package:bdk_flutter_workshop/widgets/wallet_card.dart';
import 'package:flutter/material.dart';

class WalletCardList extends StatelessWidget {
  const WalletCardList(
    this.walletCard, {
    required this.onAddNewWallet,
    required this.onDeleteWallet,
    super.key,
  });

  final WalletCardViewModel? walletCard;
  final VoidCallback onAddNewWallet;
  final VoidCallback onDeleteWallet;

  @override
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 1,
      itemExtent: Sizes.p160,
      itemBuilder: (BuildContext context, int index) {
        if (walletCard == null) {
          return NewWalletCard(onPressed: onAddNewWallet);
        } else {
          return WalletCard(
            label: walletCard!.label,
            balanceBtc: walletCard!.balanceBtc,
            onDelete: onDeleteWallet,
          );
        }
      },
    );
  }
}
