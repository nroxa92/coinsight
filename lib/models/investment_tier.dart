import 'package:flutter/material.dart';

enum InvestmentTier { short, mid, long }

extension InvestmentTierX on InvestmentTier {
  String get displayName {
    switch (this) {
      case InvestmentTier.short: return 'SHORT';
      case InvestmentTier.mid:   return 'MID';
      case InvestmentTier.long:  return 'LONG';
    }
  }

  String get emoji {
    switch (this) {
      case InvestmentTier.short: return '\u26A1';
      case InvestmentTier.mid:   return '\uD83D\uDCC8';
      case InvestmentTier.long:  return '\uD83C\uDFDB\uFE0F';
    }
  }

  String get description {
    switch (this) {
      case InvestmentTier.short: return 'Early momentum \u00B7 sati do dani';
      case InvestmentTier.mid:   return 'Value discovery \u00B7 tjedni do mjeseci';
      case InvestmentTier.long:  return 'Fundamental hold \u00B7 mjeseci do godina';
    }
  }

  String get philosophy {
    switch (this) {
      case InvestmentTier.short:
        return 'Uhvati val dok se di\u017Ee. DEX listing \u2192 community buzz \u2192 '
            'CEX listing. Ulaz rano, izlaz s auto stop-lossom.';
      case InvestmentTier.mid:
        return 'Prona\u0111i legitiman projekt koji je jo\u0161 neotkriven. '
            'GitHub tim, tokenomics, whitepaper. Dr\u017Ei dok community otkrije.';
      case InvestmentTier.long:
        return 'Infrastrukturni projekti koji rje\u0161avaju stvaran problem. '
            'Ultra rigorozna due diligence. Akumuliraj na padovima. '
            'Ne prodaje\u0161 ispod ciljne cijene.';
    }
  }

  bool get supportsAutoTrade {
    switch (this) {
      case InvestmentTier.short: return true;
      case InvestmentTier.mid:   return false;
      case InvestmentTier.long:  return false;
    }
  }

  // Primary color per tier
  Color get color {
    switch (this) {
      case InvestmentTier.short: return const Color(0xFF6C63FF); // purple
      case InvestmentTier.mid:   return const Color(0xFF03DAC6); // teal
      case InvestmentTier.long:  return const Color(0xFFFFD700); // gold
    }
  }

  Color get bgColor {
    switch (this) {
      case InvestmentTier.short: return const Color(0xFF6C63FF).withAlpha(30);
      case InvestmentTier.mid:   return const Color(0xFF03DAC6).withAlpha(30);
      case InvestmentTier.long:  return const Color(0xFFFFD700).withAlpha(30);
    }
  }
}
