import 'package:flutter/material.dart';

class MonitoredChannel {
  final String username;
  final String displayName;
  final bool isDefault;
  final int signalsReceived;
  final int signalsRelevant;
  final DateTime? lastSignal;
  final bool isActive;

  const MonitoredChannel({
    required this.username,
    required this.displayName,
    this.isDefault = false,
    this.signalsReceived = 0,
    this.signalsRelevant = 0,
    this.lastSignal,
    this.isActive = true,
  });

  double get reliabilityScore {
    if (signalsReceived < 10) return -1;
    return signalsRelevant / signalsReceived;
  }

  String get reliabilityLabel {
    if (reliabilityScore < 0) return 'Novo';
    if (reliabilityScore > 0.3) return 'Visoka';
    if (reliabilityScore > 0.1) return 'Srednja';
    return 'Niska';
  }

  Color get reliabilityColor {
    if (reliabilityScore < 0) return Colors.grey;
    if (reliabilityScore > 0.3) return Colors.green;
    if (reliabilityScore > 0.1) return Colors.orange;
    return Colors.red;
  }

  MonitoredChannel copyWith({
    String? username,
    String? displayName,
    bool? isDefault,
    int? signalsReceived,
    int? signalsRelevant,
    DateTime? lastSignal,
    bool? isActive,
  }) =>
      MonitoredChannel(
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        isDefault: isDefault ?? this.isDefault,
        signalsReceived: signalsReceived ?? this.signalsReceived,
        signalsRelevant: signalsRelevant ?? this.signalsRelevant,
        lastSignal: lastSignal ?? this.lastSignal,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => {
        'username': username,
        'display_name': displayName,
        'is_default': isDefault,
        'signals_received': signalsReceived,
        'signals_relevant': signalsRelevant,
        'last_signal': lastSignal?.toIso8601String(),
        'is_active': isActive,
      };

  factory MonitoredChannel.fromMap(Map<dynamic, dynamic> map) =>
      MonitoredChannel(
        username: map['username'] as String? ?? '',
        displayName: map['display_name'] as String? ?? '',
        isDefault: map['is_default'] as bool? ?? false,
        signalsReceived: map['signals_received'] as int? ?? 0,
        signalsRelevant: map['signals_relevant'] as int? ?? 0,
        lastSignal: map['last_signal'] != null
            ? DateTime.tryParse(map['last_signal'] as String)
            : null,
        isActive: map['is_active'] as bool? ?? true,
      );
}
