class RouteModel {
  final int id;
  final String tenantId;
  final String originCity;
  final String destinationCity;
  final int stopsCount;
  final int estimatedDuration;
  final double basePrice;
  final int? branchId;
  final int? agentId;
  final String status;

  RouteModel({
    required this.id,
    required this.tenantId,
    required this.originCity,
    required this.destinationCity,
    this.stopsCount = 0,
    required this.estimatedDuration,
    required this.basePrice,
    this.branchId,
    this.agentId,
    this.status = 'active',
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tenantId: json['tenantId']?.toString() ?? '',
      originCity: json['originCity']?.toString() ?? '',
      destinationCity: json['destinationCity']?.toString() ?? '',
      stopsCount: json['stopsCount'] is int ? json['stopsCount'] : int.tryParse(json['stopsCount']?.toString() ?? '0') ?? 0,
      estimatedDuration: json['estimatedDuration'] is int ? json['estimatedDuration'] : int.tryParse(json['estimatedDuration']?.toString() ?? '0') ?? 0,
      basePrice: json['basePrice'] is num ? (json['basePrice'] as num).toDouble() : double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0.0,
      branchId: json['branchId'] is int ? json['branchId'] : int.tryParse(json['branchId']?.toString() ?? ''),
      agentId: json['agentId'] is int ? json['agentId'] : int.tryParse(json['agentId']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'originCity': originCity,
      'destinationCity': destinationCity,
      'stopsCount': stopsCount,
      'estimatedDuration': estimatedDuration,
      'basePrice': basePrice,
      'branchId': branchId,
      'agentId': agentId,
      'status': status,
    };
  }
}
