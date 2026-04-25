import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppExpense {
  final int id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final int? vehicleId;
  final int? branchId;

  AppExpense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.vehicleId,
    this.branchId,
  });

  factory AppExpense.fromJson(Map<String, dynamic> json) {
    return AppExpense(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      vehicleId: json['vehicleId'],
      branchId: json['branchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'vehicleId': vehicleId,
      'branchId': branchId,
    };
  }
}

class ExpensesNotifier extends StateNotifier<AsyncValue<List<AppExpense>>> {
  final Ref ref;

  ExpensesNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/expenses');
      final List<AppExpense> expenses = (response.data as List)
          .map((e) => AppExpense.fromJson(e))
          .toList();
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addExpense(AppExpense expense) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/expenses', data: expense.toJson());
    await fetchExpenses();
  }

  Future<void> updateExpense(int id, AppExpense expense) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/expenses/$id', data: expense.toJson());
    await fetchExpenses();
  }

  Future<void> deleteExpense(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/expenses/$id');
    await fetchExpenses();
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<AppExpense>>>((ref) {
  return ExpensesNotifier(ref);
});
