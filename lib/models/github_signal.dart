/// Signal koji dolazi s GitHub Trending i Search API-ja
/// GitHub aktivnost = legitimnost projekta
/// Nagli rast starova/commitova = community interest raste
class GitHubSignal {
  final String repoName;
  final String description;
  final String language;
  final int stars;
  final int starsToday;
  final int forks;
  final int openIssues;
  final DateTime pushedAt;
  final DateTime createdAt;
  final List<String> topics;
  final DateTime detectedAt;

  GitHubSignal({
    required this.repoName,
    required this.description,
    required this.language,
    required this.stars,
    required this.starsToday,
    required this.forks,
    required this.openIssues,
    required this.pushedAt,
    required this.createdAt,
    required this.topics,
    required this.detectedAt,
  });

  int get ageDays => DateTime.now().difference(createdAt).inDays;

  bool get isRecentlyActive =>
      DateTime.now().difference(pushedAt).inDays <= 7;

  double get starVelocity => stars > 0 ? starsToday / stars : 0;

  bool get hasCryptoTopics {
    final cryptoKeywords = [
      'blockchain', 'crypto', 'defi', 'web3', 'token',
      'ethereum', 'solana', 'bitcoin', 'nft', 'dao',
      'smart-contract', 'dex', 'yield', 'staking',
    ];
    final combined = [...topics, description.toLowerCase()].join(' ');
    return cryptoKeywords.any((kw) => combined.contains(kw));
  }

  String toClaudeContext() {
    return '[GITHUB SIGNAL]\n'
        'Repo: $repoName\n'
        'Opis: $description\n'
        'Stars: $stars (danas: +$starsToday)\n'
        'Star velocity: ${(starVelocity * 100).toStringAsFixed(1)}%\n'
        'Zadnji commit: ${pushedAt.toIso8601String()}\n'
        'Starost repoa: $ageDays dana\n'
        'Aktivan: ${isRecentlyActive ? "DA" : "NE"}\n'
        'Topics: ${topics.take(5).join(", ")}\n'
        'Crypto relevantnost: ${hasCryptoTopics ? "VISOKA" : "NISKA"}';
  }

  factory GitHubSignal.fromJson(Map<String, dynamic> json) {
    final topicsRaw = json['topics'] as List<dynamic>? ?? [];
    return GitHubSignal(
      repoName: json['full_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      language: json['language'] as String? ?? '',
      stars: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      starsToday: (json['stars_today'] as num?)?.toInt() ?? 0,
      forks: (json['forks_count'] as num?)?.toInt() ?? 0,
      openIssues: (json['open_issues_count'] as num?)?.toInt() ?? 0,
      pushedAt: DateTime.tryParse(json['pushed_at'] as String? ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
              DateTime.now(),
      topics: topicsRaw.map((t) => t.toString()).toList(),
      detectedAt: DateTime.now(),
    );
  }
}
