class TicketModel {
  final String id;
  final String ticketNumber;
  final String passengerName;
  final String phone;
  final String seatNumber;
  final String trip;
  final DateTime tripDate;
  final String time;
  final String assignedUser;
  final String destination;
  final String status;
  final String tenantId;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.passengerName,
    required this.phone,
    required this.seatNumber,
    required this.trip,
    required this.tripDate,
    required this.time,
    required this.assignedUser,
    required this.destination,
    required this.status,
    required this.tenantId,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      passengerName: json['passengerName'] as String,
      phone: json['phone'] as String,
      seatNumber: json['seatNumber'] as String,
      trip: json['trip'] as String,
      tripDate: DateTime.parse(json['tripDate']),
      time: json['time'] as String,
      assignedUser: json['assignedUser'] as String,
      destination: json['destination'] as String,
      status: json['status'] as String,
      tenantId: json['tenantId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerName': passengerName,
      'phone': phone,
      'seatNumber': seatNumber,
      'destination': destination,
    };
  }
}
