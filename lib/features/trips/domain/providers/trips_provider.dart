import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/base_async_notifier.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/api_service_provider.dart';
import '../models/trip_model.dart';

class TripsNotifier extends BaseAsyncNotifier<TripModel> {
  TripsNotifier(ApiService apiService) : super(apiService, '/trips');

  @override
  TripModel fromJson(Map<String, dynamic> json) => TripModel.fromJson(json);

  Future<void> fetchTrips() async {
    await fetchData();
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, AsyncValue<List<TripModel>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TripsNotifier(apiService);
});
