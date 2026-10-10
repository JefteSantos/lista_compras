import '../models/item.dart';

/// Snapshot of the totals used together by a list card or report.
///
/// Hive models are mutable. Consumers may keep this snapshot for a rebuild or
/// use ListasProvider.obterResumoLista, which invalidates it when saving changes.
class ListSummary {
  final int itemCount;
  final int purchasedCount;
  final double total;
  final double purchasedTotal;

  const ListSummary._({
    required this.itemCount,
    required this.purchasedCount,
    required this.total,
    required this.purchasedTotal,
  });

  factory ListSummary.fromItems(List<Item> items) {
    var purchasedCount = 0;
    var total = 0.0;
    var purchasedTotal = 0.0;
    for (final item in items) {
      final amount = item.precoTotal;
      total += amount;
      if (item.comprado) {
        purchasedCount++;
        purchasedTotal += amount;
      }
    }
    return ListSummary._(
      itemCount: items.length,
      purchasedCount: purchasedCount,
      total: total,
      purchasedTotal: purchasedTotal,
    );
  }

  double get pendingTotal => total - purchasedTotal;
}
