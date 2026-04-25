import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/base_async_notifier.dart';
import '../models/ticket_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/api_service_provider.dart';

class TicketsNotifier extends BaseAsyncNotifier<TicketModel> {
  TicketsNotifier(ApiService apiService) : super(apiService, '/tickets');

  @override
  TicketModel fromJson(Map<String, dynamic> json) => TicketModel.fromJson(json);

  Future<void> fetchTickets() async {
    await fetchData();
  }

  // الدالة الخاصة لإنشاء التذكرة المعقدة التي تستخدم Transaction
  Future<bool> bookTicket(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    try {
      await apiService.post('/tickets/book', data: payload);
      await fetchTickets(); // إعادة جلب البيانات
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final ticketsProvider = StateNotifierProvider<TicketsNotifier, AsyncValue<List<TicketModel>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TicketsNotifier(apiService);
});
