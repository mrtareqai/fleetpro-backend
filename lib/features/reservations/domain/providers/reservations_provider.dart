import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppReservation {
  final int id;
  final String clientName;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String destination;
  final String status;

  AppReservation({
    required this.id,
    required this.clientName,
    required this.pickupDate,
    required this.returnDate,
    required this.destination,
    required this.status,
  });

  factory AppReservation.fromJson(Map<String, dynamic> json) {
    return AppReservation(
      id: json['id'],
      clientName: json['clientName'] ?? '',
      pickupDate: DateTime.parse(json['pickupDate']),
      returnDate: DateTime.parse(json['returnDate']),
      destination: json['destination'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'pickupDate': pickupDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'destination': destination,
      'status': status,
    };
  }
}

class ReservationsNotifier extends StateNotifier<AsyncValue<List<AppReservation>>> {
  final Ref ref;

  ReservationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/bookings');
      final List<AppReservation> reservations = (response.data as List)
          .map((e) => AppReservation.fromJson(e))
          .toList();
      state = AsyncValue.data(reservations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReservation(AppReservation reservation) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/bookings', data: reservation.toJson());
    await fetchReservations();
  }

  Future<void> updateReservation(int id, AppReservation reservation) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/bookings/$id', data: reservation.toJson());
    await fetchReservations();
  }

  Future<void> deleteReservation(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/bookings/$id');
    await fetchReservations();
  }
}

final reservationsProvider = StateNotifierProvider<ReservationsNotifier, AsyncValue<List<AppReservation>>>((ref) {
  return ReservationsNotifier(ref);
});
