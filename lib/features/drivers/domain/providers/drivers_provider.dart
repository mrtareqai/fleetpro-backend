import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppDriver {
  final int id;
  final String name;
  final String phone;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String status;

  AppDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.status,
  });

  factory AppDriver.fromJson(Map<String, dynamic> json) {
    return AppDriver(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      licenseExpiry: DateTime.parse(json['licenseExpiry']),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry.toIso8601String(),
      'status': status,
    };
  }
}

class DriversNotifier extends StateNotifier<AsyncValue<List<AppDriver>>> {
  final Ref ref;

  DriversNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/drivers');
      final List<AppDriver> drivers = (response.data as List)
          .map((e) => AppDriver.fromJson(e))
          .toList();
      state = AsyncValue.data(drivers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDriver(AppDriver driver) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/drivers', data: driver.toJson());
    await fetchDrivers();
  }

  Future<void> updateDriver(int id, AppDriver driver) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/drivers/$id', data: driver.toJson());
    await fetchDrivers();
  }

  Future<void> deleteDriver(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/drivers/$id');
    await fetchDrivers();
  }
}

final driversProvider = StateNotifierProvider<DriversNotifier, AsyncValue<List<AppDriver>>>((ref) {
  return DriversNotifier(ref);
});
