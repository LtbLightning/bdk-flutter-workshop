import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.label,
    required this.balanceBtc,
    required this.onDelete,
  });

  final String label;
  final double balanceBtc;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.p8),
        onTap: () {
          // Todo: Navigate to wallet
          print('Go to wallet');
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: Sizes.p96,
                  width: double.infinity,
                  color: theme.colorScheme.primaryContainer,
                  child: SvgPicture.asset(
                    'assets/icons/bitcoin_savings.svg',
                    fit: BoxFit
                        .none, // Don't scale the SVG, keep it at its original size
                  ),
                ),
                // Expanded to take up all the space of the height the list is constrained to
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.p8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: Sizes.p8),
                        Text(
                          '$balanceBtc BTC',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: CloseButton(
                onPressed: onDelete,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.zero,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: MaterialStateProperty.all(
                    Sizes.p16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
