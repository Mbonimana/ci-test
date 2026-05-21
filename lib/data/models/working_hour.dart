class WorkingHour {
  const WorkingHour({required this.open, required this.close});

  final String open;
  final String close;

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      open: json['open']?.toString() ?? '',
      close: json['close']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'open': open, 'close': close};
  }
}
