class ProductionRoll {
  final String machine;
  final String rollNumber;
  final String status;
  final String sqm;
  final String width;
  final String etchedProd;
  final String finalProd;
  final String startTime;
  final String endTime;
  final String customer;
  final String order;
  final String location;
  final String azeta;
  final String speed;
  final String speedC;
  final String baseVolts;
  final String volts;
  final String notes;

  ProductionRoll({
    required this.machine,
    required this.rollNumber,
    required this.status,
    required this.sqm,
    required this.width,
    required this.etchedProd,
    required this.finalProd,
    required this.startTime,
    required this.endTime,
    required this.customer,
    required this.order,
    required this.location,
    required this.azeta,
    required this.speed,
    required this.speedC,
    required this.baseVolts,
    required this.volts,
    required this.notes,
  });

  factory ProductionRoll.fromJson(Map<String, dynamic> json) {
    return ProductionRoll(
      machine: json['Machine'] ?? '',
      rollNumber: json['Roll Number'] ?? '',
      status: json['Status'] ?? '',
      sqm: json['Sqm'] ?? '',
      width: json['Width'] ?? '',
      etchedProd: json['EtchedProd.'] ?? '',
      finalProd: json['FinalProd.'] ?? '',
      startTime: json['StartTime'] ?? '',
      endTime: json['EndTime'] ?? '',
      customer: json['Customer'] ?? '',
      order: json['Order'] ?? '',
      location: json['Location'] ?? '',
      azeta: json['Azeta'] ?? '',
      speed: json['Speed'] ?? '',
      speedC: json['SpeedC'] ?? '',
      baseVolts: json['Base/Volts'] ?? '',
      volts: json['Volts'] ?? '',
      notes: json['Notes'] ?? '',
    );
  }
}
