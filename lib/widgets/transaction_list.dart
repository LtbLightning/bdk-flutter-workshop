import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:bdk_flutter_workshop/view_models/transaction_list_item_view_model.dart';
import 'package:bdk_flutter_workshop/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.transactions});

  final List<TransactionListItemViewModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap:
              true, // To set constraints on the ListView in an infinite height parent (ListView in HomeScreen)
          physics:
              const NeverScrollableScrollPhysics(), // Scrolling is handled by the parent (ListView in HomeScreen)
          itemBuilder: (ctx, index) {
            return TransactionListItem(
              isIncoming: transactions[index].isIncoming,
              timestamp: transactions[index].formattedTimestamp,
              amountBtc: transactions[index].amountBtc,
            );
          },
          itemCount: transactions.length,
        ),
      ],
    );
  }
}
