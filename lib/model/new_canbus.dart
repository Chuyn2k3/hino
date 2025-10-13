class NewCanbus {
  final String? AdBlueTankLevel;
  final String? Brake;
  final String? Cluth;
  final String? EngineHour;
  final String? EngineLoad;
  final String? FuelConsumption;
  final double? FuelConsumption_Lper100km;
  final double? FuelEfficiency_kmPerL;
  final String? FuelLevel;
  final String? Temp;
  final String? TotalFuelUse;
  final String? accelerator;
  final String? odo;
  final String? rpm;
  final String? speed;

  NewCanbus({
    this.AdBlueTankLevel,
    this.Brake,
    this.Cluth,
    this.EngineHour,
    this.EngineLoad,
    this.FuelConsumption,
    this.FuelConsumption_Lper100km,
    this.FuelEfficiency_kmPerL,
    this.FuelLevel,
    this.Temp,
    this.TotalFuelUse,
    this.accelerator,
    this.odo,
    this.rpm,
    this.speed,
  });

  factory NewCanbus.fromJson(Map<String, dynamic> json) {
    return NewCanbus(
      AdBlueTankLevel: json['AdBlueTankLevel'],
      Brake: json['Brake'],
      Cluth: json['Cluth'],
      EngineHour: json['EngineHour'],
      EngineLoad: json['EngineLoad'],
      FuelConsumption: json['FuelConsumption'],
      FuelConsumption_Lper100km: json['FuelConsumption_Lper100km']?.toDouble(),
      FuelEfficiency_kmPerL: json['FuelEfficiency_kmPerL']?.toDouble(),
      FuelLevel: json['FuelLevel'],
      Temp: json['Temp'],
      TotalFuelUse: json['TotalFuelUse'],
      accelerator: json['accelerator'],
      odo: json['odo'],
      rpm: json['rpm'],
      speed: json['speed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AdBlueTankLevel': AdBlueTankLevel,
      'Brake': Brake,
      'Cluth': Cluth,
      'EngineHour': EngineHour,
      'EngineLoad': EngineLoad,
      'FuelConsumption': FuelConsumption,
      'FuelConsumption_Lper100km': FuelConsumption_Lper100km,
      'FuelEfficiency_kmPerL': FuelEfficiency_kmPerL,
      'FuelLevel': FuelLevel,
      'Temp': Temp,
      'TotalFuelUse': TotalFuelUse,
      'accelerator': accelerator,
      'odo': odo,
      'rpm': rpm,
      'speed': speed,
    };
  }
}