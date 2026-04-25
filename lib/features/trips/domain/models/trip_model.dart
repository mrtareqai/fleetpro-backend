class TripModel {
  final int id;
  final int routeId;
  final int vehicleId;
  final int driverId;
  final DateTime departureTime;
  final int totalSeats;
  final int availableSeats;
  final String status;
  final String tenantId;

  // Embedded related data (from Prisma include)
  final dynamic route;
  final dynamic vehicle;
  final dynamic driver;

  TripModel({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.departureTime,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    required this.tenantId,
    this.route,
    this.vehicle,
    this.driver,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as int,
      routeId: json['routeId'] as int,
      vehicleId: json['vehicleId'] as int,
      driverId: json['driverId'] as int,
      departureTime: DateTime.parse(json['departureTime']),
      totalSeats: json['totalSeats'] as int,
      availableSeats: json['availableSeats'] as int,
      status: json['status'] as String,
      tenantId: json['tenantId'] as String,
      route: json['route'],
      vehicle: json['vehicle'],
      driver: json['driver'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'departureTime': departureTime.toIso8601String(),
      'totalSeats': totalSeats,
    };
  }
}
