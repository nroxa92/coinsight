import 'package:flutter/material.dart';

class LongTermHolding {
  final String id;
  final String symbol;
  final String name;
  final String coinGeckoId;
  final DateTime firstResearchDate;
  final LongTermStatus status;
  final List<LongTermPurchase> purchases;
  final double targetPriceMin;
  final double targetPriceMax;
  final String investmentThesis;
  final LongTermFundamentals? fundamentals;
  final List<LongTermNote> notes;
  final int? claudeConfidenceScore;

  const LongTermHolding({
    required this.id,
    required this.symbol,
    required this.name,
    this.coinGeckoId = '',
    required this.firstResearchDate,
    required this.status,
    this.purchases = const [],
    required this.targetPriceMin,
    required this.targetPriceMax,
    this.investmentThesis = '',
    this.fundamentals,
    this.notes = const [],
    this.claudeConfidenceScore,
  });

  double get averageEntryPrice {
    if (purchases.isEmpty) return 0;
    final totalCost = purchases.fold<double>(
        0, (sum, p) => sum + p.price * p.quantity);
    final totalQty = totalQuantity;
    return totalQty > 0 ? totalCost / totalQty : 0;
  }

  double get totalInvested =>
      purchases.fold<double>(0, (sum, p) => sum + p.amountUsdt);

  double get totalQuantity =>
      purchases.fold<double>(0, (sum, p) => sum + p.quantity);

  double get potentialReturnMinPercent {
    final avg = averageEntryPrice;
    if (avg <= 0) return 0;
    return ((targetPriceMin - avg) / avg) * 100;
  }

  double get potentialReturnMaxPercent {
    final avg = averageEntryPrice;
    if (avg <= 0) return 0;
    return ((targetPriceMax - avg) / avg) * 100;
  }

  int get daysResearching =>
      DateTime.now().difference(firstResearchDate).inDays;

  LongTermHolding copyWith({
    String? symbol, String? name, String? coinGeckoId,
    LongTermStatus? status, List<LongTermPurchase>? purchases,
    double? targetPriceMin, double? targetPriceMax,
    String? investmentThesis, LongTermFundamentals? fundamentals,
    List<LongTermNote>? notes, int? claudeConfidenceScore,
  }) => LongTermHolding(
    id: id, firstResearchDate: firstResearchDate,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    coinGeckoId: coinGeckoId ?? this.coinGeckoId,
    status: status ?? this.status,
    purchases: purchases ?? this.purchases,
    targetPriceMin: targetPriceMin ?? this.targetPriceMin,
    targetPriceMax: targetPriceMax ?? this.targetPriceMax,
    investmentThesis: investmentThesis ?? this.investmentThesis,
    fundamentals: fundamentals ?? this.fundamentals,
    notes: notes ?? this.notes,
    claudeConfidenceScore: claudeConfidenceScore ?? this.claudeConfidenceScore,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'symbol': symbol, 'name': name, 'coin_gecko_id': coinGeckoId,
    'first_research_date': firstResearchDate.toIso8601String(),
    'status': status.name,
    'purchases': purchases.map((p) => p.toMap()).toList(),
    'target_price_min': targetPriceMin,
    'target_price_max': targetPriceMax,
    'investment_thesis': investmentThesis,
    'fundamentals': fundamentals?.toMap(),
    'notes': notes.map((n) => n.toMap()).toList(),
    'claude_confidence_score': claudeConfidenceScore,
  };

  factory LongTermHolding.fromMap(Map<dynamic, dynamic> map) => LongTermHolding(
    id: map['id'] as String,
    symbol: map['symbol'] as String,
    name: map['name'] as String,
    coinGeckoId: map['coin_gecko_id'] as String? ?? '',
    firstResearchDate: DateTime.parse(map['first_research_date'] as String),
    status: LongTermStatus.values.firstWhere(
      (s) => s.name == (map['status'] as String? ?? 'researching'),
      orElse: () => LongTermStatus.researching,
    ),
    purchases: (map['purchases'] as List<dynamic>? ?? [])
        .map((p) => LongTermPurchase.fromMap(p as Map<dynamic, dynamic>))
        .toList(),
    targetPriceMin: (map['target_price_min'] as num?)?.toDouble() ?? 0,
    targetPriceMax: (map['target_price_max'] as num?)?.toDouble() ?? 0,
    investmentThesis: map['investment_thesis'] as String? ?? '',
    fundamentals: map['fundamentals'] != null
        ? LongTermFundamentals.fromMap(
            map['fundamentals'] as Map<dynamic, dynamic>)
        : null,
    notes: (map['notes'] as List<dynamic>? ?? [])
        .map((n) => LongTermNote.fromMap(n as Map<dynamic, dynamic>))
        .toList(),
    claudeConfidenceScore: (map['claude_confidence_score'] as num?)?.toInt(),
  );
}

enum LongTermStatus { researching, accumulating, holding, distributing, closed }

extension LongTermStatusX on LongTermStatus {
  String get label {
    switch (this) {
      case LongTermStatus.researching:  return 'Istra\u017Eivanje';
      case LongTermStatus.accumulating: return 'Akumulacija';
      case LongTermStatus.holding:      return 'Holding';
      case LongTermStatus.distributing: return 'Distribucija';
      case LongTermStatus.closed:       return 'Zatvoreno';
    }
  }
  Color get color {
    switch (this) {
      case LongTermStatus.researching:  return Colors.orange;
      case LongTermStatus.accumulating: return const Color(0xFF03DAC6);
      case LongTermStatus.holding:      return const Color(0xFFFFD700);
      case LongTermStatus.distributing: return Colors.blue;
      case LongTermStatus.closed:       return Colors.grey;
    }
  }
}

class LongTermPurchase {
  final String id;
  final DateTime date;
  final double price;
  final double quantity;
  final double amountUsdt;
  final String? note;

  const LongTermPurchase({
    required this.id,
    required this.date,
    required this.price,
    required this.quantity,
    required this.amountUsdt,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'price': price,
    'quantity': quantity,
    'amount_usdt': amountUsdt,
    'note': note,
  };

  factory LongTermPurchase.fromMap(Map<dynamic, dynamic> map) => LongTermPurchase(
    id: map['id'] as String,
    date: DateTime.parse(map['date'] as String),
    price: (map['price'] as num).toDouble(),
    quantity: (map['quantity'] as num).toDouble(),
    amountUsdt: (map['amount_usdt'] as num).toDouble(),
    note: map['note'] as String?,
  );
}

/// Fundamentalna analiza za LONG holding
class LongTermFundamentals {
  final String teamBackground;
  final String investors;
  final String partnerships;
  final String realWorldUseCase;
  final String tokenomics;
  final String competitorAnalysis;
  final String roadmapAssessment;
  final DateTime lastUpdated;

  const LongTermFundamentals({
    this.teamBackground = '',
    this.investors = '',
    this.partnerships = '',
    this.realWorldUseCase = '',
    this.tokenomics = '',
    this.competitorAnalysis = '',
    this.roadmapAssessment = '',
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() => {
    'team_background': teamBackground,
    'investors': investors,
    'partnerships': partnerships,
    'real_world_use_case': realWorldUseCase,
    'tokenomics': tokenomics,
    'competitor_analysis': competitorAnalysis,
    'roadmap_assessment': roadmapAssessment,
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory LongTermFundamentals.fromMap(Map<dynamic, dynamic> map) =>
      LongTermFundamentals(
    teamBackground: map['team_background'] as String? ?? '',
    investors: map['investors'] as String? ?? '',
    partnerships: map['partnerships'] as String? ?? '',
    realWorldUseCase: map['real_world_use_case'] as String? ?? '',
    tokenomics: map['tokenomics'] as String? ?? '',
    competitorAnalysis: map['competitor_analysis'] as String? ?? '',
    roadmapAssessment: map['roadmap_assessment'] as String? ?? '',
    lastUpdated: DateTime.parse(map['last_updated'] as String),
  );
}

class LongTermNote {
  final String id;
  final DateTime timestamp;
  final String content;
  final String noteType;

  const LongTermNote({
    required this.id,
    required this.timestamp,
    required this.content,
    required this.noteType,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'content': content,
    'note_type': noteType,
  };

  factory LongTermNote.fromMap(Map<dynamic, dynamic> map) => LongTermNote(
    id: map['id'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
    content: map['content'] as String,
    noteType: map['note_type'] as String? ?? 'observation',
  );
}
