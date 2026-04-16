import 'package:flutter/material.dart';

class MidTermProject {
  final String id;
  final String symbol;
  final String name;
  final String coinGeckoId;
  final String githubRepo;
  final DateTime discoveredAt;
  final MidTermStatus status;

  // Entry plan
  final double? entryPriceTarget;
  final double? entryAmountUsdt;
  final double? stopLossPrice;
  final double? takeProfitPrice;

  // Actuals
  final double? actualEntryPrice;
  final double? actualEntryAmount;
  final DateTime? entryDate;

  // Exit
  final double? exitPrice;
  final DateTime? exitDate;

  // Investment teza
  final String thesis;

  // Kronolo\u0161ke bilje\u0161ke
  final List<MidTermNote> notes;

  // Zadnji Claude MID analysis tekst
  final String? lastClaudeAnalysis;
  final DateTime? lastAnalysisDate;

  const MidTermProject({
    required this.id,
    required this.symbol,
    required this.name,
    this.coinGeckoId = '',
    this.githubRepo = '',
    required this.discoveredAt,
    required this.status,
    this.entryPriceTarget,
    this.entryAmountUsdt,
    this.stopLossPrice,
    this.takeProfitPrice,
    this.actualEntryPrice,
    this.actualEntryAmount,
    this.entryDate,
    this.exitPrice,
    this.exitDate,
    this.thesis = '',
    this.notes = const [],
    this.lastClaudeAnalysis,
    this.lastAnalysisDate,
  });

  bool get isEntered => actualEntryPrice != null && entryDate != null;

  double get potentialReturnPercent {
    final entry = actualEntryPrice ?? entryPriceTarget;
    if (entry == null || entry <= 0 || takeProfitPrice == null) return 0;
    return ((takeProfitPrice! - entry) / entry) * 100;
  }

  int get daysWatching => DateTime.now().difference(discoveredAt).inDays;

  MidTermProject copyWith({
    String? symbol, String? name, String? coinGeckoId, String? githubRepo,
    MidTermStatus? status, double? entryPriceTarget, double? entryAmountUsdt,
    double? stopLossPrice, double? takeProfitPrice, double? actualEntryPrice,
    double? actualEntryAmount, DateTime? entryDate, double? exitPrice,
    DateTime? exitDate, String? thesis, List<MidTermNote>? notes,
    String? lastClaudeAnalysis, DateTime? lastAnalysisDate,
  }) => MidTermProject(
    id: id, discoveredAt: discoveredAt,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    coinGeckoId: coinGeckoId ?? this.coinGeckoId,
    githubRepo: githubRepo ?? this.githubRepo,
    status: status ?? this.status,
    entryPriceTarget: entryPriceTarget ?? this.entryPriceTarget,
    entryAmountUsdt: entryAmountUsdt ?? this.entryAmountUsdt,
    stopLossPrice: stopLossPrice ?? this.stopLossPrice,
    takeProfitPrice: takeProfitPrice ?? this.takeProfitPrice,
    actualEntryPrice: actualEntryPrice ?? this.actualEntryPrice,
    actualEntryAmount: actualEntryAmount ?? this.actualEntryAmount,
    entryDate: entryDate ?? this.entryDate,
    exitPrice: exitPrice ?? this.exitPrice,
    exitDate: exitDate ?? this.exitDate,
    thesis: thesis ?? this.thesis,
    notes: notes ?? this.notes,
    lastClaudeAnalysis: lastClaudeAnalysis ?? this.lastClaudeAnalysis,
    lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'symbol': symbol, 'name': name,
    'coin_gecko_id': coinGeckoId, 'github_repo': githubRepo,
    'discovered_at': discoveredAt.toIso8601String(),
    'status': status.name,
    'entry_price_target': entryPriceTarget,
    'entry_amount_usdt': entryAmountUsdt,
    'stop_loss_price': stopLossPrice,
    'take_profit_price': takeProfitPrice,
    'actual_entry_price': actualEntryPrice,
    'actual_entry_amount': actualEntryAmount,
    'entry_date': entryDate?.toIso8601String(),
    'exit_price': exitPrice,
    'exit_date': exitDate?.toIso8601String(),
    'thesis': thesis,
    'notes': notes.map((n) => n.toMap()).toList(),
    'last_claude_analysis': lastClaudeAnalysis,
    'last_analysis_date': lastAnalysisDate?.toIso8601String(),
  };

  factory MidTermProject.fromMap(Map<dynamic, dynamic> map) => MidTermProject(
    id: map['id'] as String,
    symbol: map['symbol'] as String,
    name: map['name'] as String,
    coinGeckoId: map['coin_gecko_id'] as String? ?? '',
    githubRepo: map['github_repo'] as String? ?? '',
    discoveredAt: DateTime.parse(map['discovered_at'] as String),
    status: MidTermStatus.values.firstWhere(
      (s) => s.name == (map['status'] as String? ?? 'researching'),
      orElse: () => MidTermStatus.researching,
    ),
    entryPriceTarget: (map['entry_price_target'] as num?)?.toDouble(),
    entryAmountUsdt: (map['entry_amount_usdt'] as num?)?.toDouble(),
    stopLossPrice: (map['stop_loss_price'] as num?)?.toDouble(),
    takeProfitPrice: (map['take_profit_price'] as num?)?.toDouble(),
    actualEntryPrice: (map['actual_entry_price'] as num?)?.toDouble(),
    actualEntryAmount: (map['actual_entry_amount'] as num?)?.toDouble(),
    entryDate: map['entry_date'] != null
        ? DateTime.parse(map['entry_date'] as String) : null,
    exitPrice: (map['exit_price'] as num?)?.toDouble(),
    exitDate: map['exit_date'] != null
        ? DateTime.parse(map['exit_date'] as String) : null,
    thesis: map['thesis'] as String? ?? '',
    notes: (map['notes'] as List<dynamic>? ?? [])
        .map((n) => MidTermNote.fromMap(n as Map<dynamic, dynamic>))
        .toList(),
    lastClaudeAnalysis: map['last_claude_analysis'] as String?,
    lastAnalysisDate: map['last_analysis_date'] != null
        ? DateTime.parse(map['last_analysis_date'] as String) : null,
  );
}

enum MidTermStatus { researching, watching, entered, exited, abandoned }

extension MidTermStatusX on MidTermStatus {
  String get label {
    switch (this) {
      case MidTermStatus.researching: return 'Istra\u017Eivanje';
      case MidTermStatus.watching:    return 'Watchlist';
      case MidTermStatus.entered:     return 'U\u0161ao';
      case MidTermStatus.exited:      return 'Iza\u0161ao';
      case MidTermStatus.abandoned:   return 'Odustao';
    }
  }
  Color get color {
    switch (this) {
      case MidTermStatus.researching: return Colors.orange;
      case MidTermStatus.watching:    return Colors.blue;
      case MidTermStatus.entered:     return Colors.green;
      case MidTermStatus.exited:      return Colors.grey;
      case MidTermStatus.abandoned:   return Colors.red;
    }
  }
}

class MidTermNote {
  final String id;
  final DateTime timestamp;
  final String content;
  final String? claudeSnippet;

  const MidTermNote({
    required this.id,
    required this.timestamp,
    required this.content,
    this.claudeSnippet,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'content': content,
    'claude_snippet': claudeSnippet,
  };

  factory MidTermNote.fromMap(Map<dynamic, dynamic> map) => MidTermNote(
    id: map['id'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
    content: map['content'] as String,
    claudeSnippet: map['claude_snippet'] as String?,
  );
}
