import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppTransaction {
  final int id;
  final String type; // 'income', 'expense'
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  AppTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'],
      type: json['type'] ?? 'income',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}

class TransactionsNotifier extends StateNotifier<AsyncValue<List<AppTransaction>>> {
  final Ref ref;

  TransactionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/transactions');
      final List<AppTransaction> transactions = (response.data as List)
          .map((e) => AppTransaction.fromJson(e))
          .toList();
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/transactions', data: transaction.toJson());
    await fetchTransactions();
  }

  Future<void> updateTransaction(int id, AppTransaction transaction) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/transactions/$id', data: transaction.toJson());
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/transactions/$id');
    await fetchTransactions();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<AppTransaction>>>((ref) {
  return TransactionsNotifier(ref);
});
