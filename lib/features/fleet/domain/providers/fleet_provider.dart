import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppVehicle {
  final int id;
  final String model;
  final DateTime manufactureDate;
  final String plateNumber;
  final String baseNumber;
  final String cardNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String status;

  AppVehicle({
    required this.id,
    required this.model,
    required this.manufactureDate,
    required this.plateNumber,
    required this.baseNumber,
    required this.cardNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
  });

  factory AppVehicle.fromJson(Map<String, dynamic> json) {
    return AppVehicle(
      id: json['id'],
      model: json['model'] ?? '',
      manufactureDate: DateTime.parse(json['manufactureDate']),
      plateNumber: json['plateNumber'] ?? '',
      baseNumber: json['baseNumber'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'manufactureDate': manufactureDate.toIso8601String(),
      'plateNumber': plateNumber,
      'baseNumber': baseNumber,
      'cardNumber': cardNumber,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
    };
  }
}

class FleetNotifier extends StateNotifier<AsyncValue<List<AppVehicle>>> {
  final Ref ref;

  FleetNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/vehicles');
      final List<AppVehicle> vehicles = (response.data as List)
          .map((e) => AppVehicle.fromJson(e))
          .toList();
      state = AsyncValue.data(vehicles);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addVehicle(AppVehicle vehicle) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/vehicles', data: vehicle.toJson());
    await fetchVehicles();
  }

  Future<void> updateVehicle(int id, AppVehicle vehicle) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/vehicles/$id', data: vehicle.toJson());
    await fetchVehicles();
  }

  Future<void> deleteVehicle(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/vehicles/$id');
    await fetchVehicles();
  }
}

final fleetProvider = StateNotifierProvider<FleetNotifier, AsyncValue<List<AppVehicle>>>((ref) {
  return FleetNotifier(ref);
});
