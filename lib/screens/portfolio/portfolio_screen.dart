import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/services/portfolio_provider.dart';
import 'package:finance_app/screens/sectors/company_detail_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        final items = portfolio.items;

        if (items.isEmpty) {
          return Center(
            child: Text(
              "Portföyüne henüz hisse eklemedin",
              style: TextStyle(
                color: theme.textTheme.bodyMedium!.color,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final change = portfolio.changeForTicker(item.ticker);
            final isNegative = change.contains("-");

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CompanyDetailScreen(
                          companyName: item.companyName,
                          ticker: item.ticker,
                          sector: item.sector,
                        ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      change,
                      style: TextStyle(
                        color:
                            isNegative ? Colors.redAccent : Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.companyName,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${item.ticker} • ${item.sector}",
                            style: TextStyle(
                              color: theme.textTheme.bodySmall!.color,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
