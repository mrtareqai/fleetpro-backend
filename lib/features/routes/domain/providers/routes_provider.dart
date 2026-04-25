import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/api_service_provider.dart';
import '../../../../core/providers/base_async_notifier.dart';
import '../models/route_model.dart';

class RoutesNotifier extends BaseAsyncNotifier<RouteModel> {
  RoutesNotifier(ApiService apiService) : super(apiService, '/routes');

  @override
  RouteModel fromJson(Map<String, dynamic> json) => RouteModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(RouteModel item) => item.toJson();
}

final routesProvider = StateNotifierProvider<RoutesNotifier, AsyncValue<List<RouteModel>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RoutesNotifier(apiService);
});
