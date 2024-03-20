import 'package:bdk_flutter_workshop/view_models/transaction_list_item_view_model.dart';
import 'package:bdk_flutter_workshop/view_models/wallet_card_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletCard,
    this.transactions,
  });

  final WalletCardViewModel? walletCard;
  final List<TransactionListItemViewModel>? transactions;

  HomeState copyWith({
    WalletCardViewModel? walletCard,
    bool clearWalletCard = false,
    List<TransactionListItemViewModel>? transactions,
  }) {
    return HomeState(
      walletCard: clearWalletCard ? null : walletCard ?? this.walletCard,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
        walletCard,
        transactions,
      ];
}
